// ─────────────────────────────────────────────────────────────────────────────
// guidance_screen.dart  (v4 — calls dharmic-guidance Supabase edge function)
//
// Changes from v3:
//   • Removed LocalWisdomEngine dependency entirely
//   • _sendMessage() calls _callEdgeFunction() instead of _engine.generateResponse()
//   • _callEdgeFunction() invokes 'dharmic-guidance' via supabase_flutter's
//     functions.invoke(), forwarding:
//       - userMessage  : the latest user text
//       - history      : prior turns as [{role, text}] (edge function format)
//       - kundliData   : serialised from widget.state.kundliData (if present)
//       - topicLabel   : _topic!.label
//   • Edge function returns { text, theme, subType } — we use text as reply
//   • Falls back to a gentle error message on network/function failure
//   • All other v3 behaviour preserved (PDF, voice, auto-send, topic lock)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart' show Permission, PermissionStatus, PermissionActions, PermissionStatusGetters;
import '../constants/theme.dart';
import '../constants/app_data.dart';
import '../../models/models.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';
import '../../services/supabase_service.dart';
import 'gita_pdf_service.dart';

// ── Internal message model ────────────────────────────────────────────────────
class _ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  _ChatMessage({required this.role, required this.content});
}

// ═══════════════════════════════════════════════════════════════════════════════
// GUIDANCE SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class GuidanceScreen extends StatefulWidget {
  final AppState state;
  const GuidanceScreen({super.key, required this.state});

  @override
  State<GuidanceScreen> createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen>
    with TickerProviderStateMixin {
  Topic? _topic;
  String? _sessionId;
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  // PDF state
  bool _pdfLoaded = false;
  String? _pdfFilename;
  String? _pdfText;
  bool _pdfParsing = false;

  // Voice state
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  String _voiceBuffer = '';
  final String _voiceBase = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  SupabaseClient get _db => Supabase.instance.client;

  // ── Speech init ────────────────────────────────────────────────────────────
@override
void initState() {
  super.initState();
  _loadStoredPdf();
  _speech = stt.SpeechToText();          // ← initialise here, not in _initSpeech
  _initSpeech();

  _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true);
  _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
  );
  _pulseController.stop();
}

Future<void> _initSpeech() async {
  _speechAvailable = await _speech.initialize(
    onStatus: (s) => debugPrint('[Voice] status: $s'),
    onError:  (e) => debugPrint('[Voice] error: ${e.errorMsg}'),
  );
  debugPrint('[Voice] initialized: $_speechAvailable');
}

  // ── Toggle voice ───────────────────────────────────────────────────────────
  // ── Toggle voice — opens dialog ────────────────────────────────────────────
// ── Toggle voice ───────────────────────────────────────────────────────────
Future<void> _toggleVoice() async {
  debugPrint('[Voice] mic tapped, kIsWeb=$kIsWeb');

  // ── Permission: skip on web (browser handles its own prompt) ──
  if (!kIsWeb) {
    final status = await Permission.microphone.request();
    debugPrint('[Voice] permission: $status');
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Microphone permission needed for voice input'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
  }

  // ── Initialize speech engine if not ready ─────────────────────
  if (!_speech.isAvailable) {
    debugPrint('[Voice] initializing speech engine...');
    final available = await _speech.initialize(
      onStatus: (s) => debugPrint('[Voice] status: $s'),
      onError:  (e) => debugPrint('[Voice] error: ${e.errorMsg}'),
    );
    debugPrint('[Voice] initialize returned: $available');
    if (mounted) setState(() => _speechAvailable = available);

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Speech recognition not available on this device'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
  }

  debugPrint('[Voice] opening dialog');
  await _showVoiceDialog();
}

Future<void> _showVoiceDialog() async {
  String recognized = '';
  bool listening = false;
  bool done      = false;
  bool started   = false;
  StateSetter? setDialog;

  // ── startListening: platform-aware ────────────────────────────
  void startListening() {
  listening = true;
  setDialog?.call(() {});

  _speech.listen(
    onResult: (result) {
      debugPrint('[Voice] words="${result.recognizedWords}" final=${result.finalResult}');
      if (result.recognizedWords.isNotEmpty) {
        recognized = result.recognizedWords;
      }
      if (result.finalResult) {
        done      = true;
        listening = false;
      }
      setDialog?.call(() {});
    },
    onSoundLevelChange: (level) {
      debugPrint('[Voice] sound level: $level'); // if this never prints, mic is blocked
    },
    listenFor:      const Duration(seconds: 60),
    pauseFor:       const Duration(seconds: 5),
    partialResults: true,
    cancelOnError:  false,
  );
}

  // ── Android auto-stop restart (native only) ────────────────────
  // Chrome manages its own lifecycle — restarting breaks it
  if (!kIsWeb) {
    _speech.statusListener = (status) {
      debugPrint('[Voice] statusListener: $status');
      if ((status == 'notListening' || status == 'done') && !done && started) {
        debugPrint('[Voice] Android stopped early — restarting');
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!done && setDialog != null) {
            startListening();
          }
        });
      }
    };
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          setDialog = setDialogState;

          if (!started) {
            started = true;
            Future.microtask(startListening);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFFFFF8ED),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),

                // ── Pulsing mic / check ──────────────────────────
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 1.0,
                    end: listening && !done ? 1.2 : 1.0,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? kAccent.withValues(alpha: 0.1)
                          : kRust.withValues(alpha: 0.1),
                      border: Border.all(
                        color: done ? kAccent : kRust,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      done ? Icons.check_rounded : Icons.mic_rounded,
                      color: done ? kAccent : kRust,
                      size: 30,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Status text ──────────────────────────────────
                Text(
                  done
                      ? 'Got it!'
                      : listening
                          ? 'Listening… speak now'
                          : 'Starting…',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: done ? kAccent : kRust,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Live transcript ──────────────────────────────
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 70),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text(
                    recognized.isEmpty
                        ? 'Your words will appear here…'
                        : recognized,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: recognized.isEmpty ? kDim : kText,
                      fontStyle: recognized.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Buttons ──────────────────────────────────────
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _speech.stop();
                        if (!kIsWeb) _speech.statusListener = null;
                        Navigator.of(ctx).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        side: const BorderSide(color: kBorder),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: kDim, fontSize: 14)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: recognized.trim().isEmpty
                          ? null
                          : () async {
                              await _speech.stop();
                              if (!kIsWeb) _speech.statusListener = null;
                              Navigator.of(ctx).pop();

                              final existing = _controller.text.trim();
                              _controller.text = existing.isEmpty
                                  ? recognized.trim()
                                  : '$existing ${recognized.trim()}';
                              _controller.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _controller.text.length),
                              );

                              Future.delayed(
                                const Duration(milliseconds: 200),
                                _sendMessage,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        disabledBackgroundColor:
                            kAccent.withValues(alpha: 0.35),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      child: const Text('Use this',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ],
            ),
          );
        },
      );
    },
  );

  // ── Cleanup ────────────────────────────────────────────────────
  if (!kIsWeb) _speech.statusListener = null;
}
  // ── PDF helpers ────────────────────────────────────────────────────────────
  Future<void> _loadStoredPdf() async {
    final loaded = await GitaPdfService.isPdfLoaded();
    if (loaded) {
      final text = await GitaPdfService.getStoredText();
      final filename = await GitaPdfService.getStoredFilename();
      if (mounted) {
        setState(() {
          _pdfLoaded = true;
          _pdfText = text;
          _pdfFilename = filename;
        });
      }
    }
  }

  Future<void> _uploadPdf() async {
    setState(() => _pdfParsing = true);
    final result = await GitaPdfService.pickAndParsePdf();
    if (!mounted) return;
    setState(() => _pdfParsing = false);

    if (result.isSuccess) {
      final text = await GitaPdfService.getStoredText();
      setState(() {
        _pdfLoaded = true;
        _pdfText = text;
        _pdfFilename = result.filename;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${result.summaryText}'),
          backgroundColor: kAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to load PDF'),
          backgroundColor: kRust,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _replacePdf() async {
    await GitaPdfService.clearStoredPdf();
    setState(() {
      _pdfLoaded = false;
      _pdfText = null;
      _pdfFilename = null;
    });
    await _uploadPdf();
  }

  // ── Topic selection ────────────────────────────────────────────────────────
  Future<void> _pickTopic(Topic t) async {
    setState(() {
      _topic = t;
      _messages.clear();
      _loading = true;
    });

    try {
      _sessionId = await GuidanceService.startSession(
        topicId: t.id,
        topicLabel: t.label,
        guidanceStyle: widget.state.userStyle,
      );
    } catch (_) {}

    final greeting = _buildOpeningGreeting(t);

    setState(() {
      _messages.add(_ChatMessage(role: 'assistant', content: greeting));
      _loading = false;
    });

    try {
      if (_sessionId != null) {
        await GuidanceService.appendMessage(
          sessionId: _sessionId!,
          role: 'assistant',
          content: greeting,
        );
      }
    } catch (_) {}

    _scrollToBottom();
  }

  // ── Opening greeting (local — no edge function cost for the first message) ─
  String _buildOpeningGreeting(Topic t) {
    final label = t.label.toLowerCase();

    const gitaLines = [
      '\n\nThe Bhagavad Gita begins in a moment very much like this one — with a person overwhelmed, uncertain, sitting at the edge of something difficult. That is precisely where wisdom has always found its most willing students.',
      '\n\nThe wisdom of the Gita was given to a person in pain, at a crossroads, not sure which way to turn. That is where you are. And that is exactly the right place to begin.',
      '\n\nThe Gita\'s first chapter is called "Arjuna\'s Grief." The text does not begin with triumph — it begins with a man on his knees, bewildered. If that resonates — good. You are in the right place.',
    ];
    final gitaLine = gitaLines[DateTime.now().second % gitaLines.length];

    if (label.contains('decision') || label.contains('difficult')) {
      return 'You have arrived at a crossroads. Something in you brought you here — to this moment of needing to look at a difficult choice honestly. I am glad you came.$gitaLine\n\nWhat is weighing on you? Tell me in your own words — or simply speak, and I will listen.';
    }
    if (label.contains('emotional') || label.contains('pain')) {
      return 'You have come here carrying something. Whatever it is — you do not have to name it perfectly. You only have to begin.$gitaLine\n\nWhat is weighing on you? Tell me in your own words — or simply speak, and I will listen.';
    }
    if (label.contains('purpose') || label.contains('lack')) {
      return 'The search for meaning is one of the most honest things a person can do. The fact that you feel its absence tells me something — it tells me you are someone who wants to live deliberately.$gitaLine\n\nWhat is weighing on you? Tell me in your own words — or simply speak, and I will listen.';
    }
    if (label.contains('relation') || label.contains('trouble')) {
      return 'Matters of the heart are never simple. And yet here you are — willing to look at something that is hurting you. That willingness is a quiet form of courage.$gitaLine\n\nWhat is weighing on you? Tell me in your own words — or simply speak, and I will listen.';
    }
    if (label.contains('work') || label.contains('career')) {
      return 'Something brought you here today, to this particular question about your path in the world of work. Whatever it is — the uncertainty, the frustration, the waiting — I am ready to sit with you in it.$gitaLine\n\nWhat is weighing on you? Tell me in your own words — or simply speak, and I will listen.';
    }
    return 'Whatever brought you here today — I am glad you came. Something in you knew that you needed a moment to stop, to be heard, to think. That instinct was right.$gitaLine\n\nWhat is weighing on you? Tell me in your own words — or simply speak, and I will listen.';
  }

  // ── Call the dharmic-guidance edge function ────────────────────────────────
  Future<String> _callEdgeFunction(String userMessage) async {
    // ── Session diagnostics ──────────────────────────────────────
  final session = Supabase.instance.client.auth.currentSession;
  debugPrint('[GuidanceScreen] session null: ${session == null}');
  debugPrint('[GuidanceScreen] access token: ${session?.accessToken.substring(0, 20)}...');

  // Edge function uses anon key — no user session required
if (session == null) {
  debugPrint('[GuidanceScreen] No session — proceeding with anon key');
}
  final history = _messages
      .map((m) => {'role': m.role, 'text': m.content})
      .toList();

  String? kundliString;
  if (widget.state.kundliData != null) {
    try {
      kundliString = jsonEncode(widget.state.kundliData);
    } catch (_) {
      kundliString = widget.state.kundliData.toString();
    }
  }

  final body = <String, dynamic>{
    'userMessage': userMessage,
    'history': history,
    'topicLabel': _topic?.label,
    if (kundliString != null && kundliString.isNotEmpty)
      'kundliData': kundliString,
  };

  // ── Log exactly what we're sending ──────────────────────────
  debugPrint('[GuidanceScreen] Invoking dharmic-guidance');
  debugPrint('[GuidanceScreen] body keys: ${body.keys.toList()}');

  final response = await _db.functions.invoke(
  'dharmic-guidance',
  body: body,
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrbHlzemZuYWViYnBreGxtaWx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTI5MDQsImV4cCI6MjA5MTAyODkwNH0.z14EBElS6PeTZQOHkoVLYdPebjIUigRLeHdd4X6bI2I',
  },
);
  // ── Log the raw response ─────────────────────────────────────
  debugPrint('[GuidanceScreen] response.data: ${response.data}');
  debugPrint('[GuidanceScreen] response.status: ${response.status}');  // if exposed

  final raw = response.data;
  if (raw == null) {
    throw Exception('Null response from edge function — check deployment and GEMINI_API_KEY secret');
  }

  final Map<String, dynamic> json = raw is String
      ? jsonDecode(raw) as Map<String, dynamic>
      : Map<String, dynamic>.from(raw as Map);

  if (json.containsKey('error')) {
    throw Exception('Edge function error: ${json['error']} | detail: ${json['detail']}');
  }

  final text = json['text'] as String?;
  if (text == null || text.trim().isEmpty) {
    throw Exception('Empty text in response: $json');
  }
  return text.trim();
}

  // ── Send message ───────────────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _pulseController.stop();
      _pulseController.reset();
    }

    _controller.clear();
    _voiceBuffer = '';

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _loading = true;
    });
    _scrollToBottom();

    try {
      if (_sessionId != null) {
        await GuidanceService.appendMessage(
          sessionId: _sessionId!,
          role: 'user',
          content: text,
        );
      }
    } catch (_) {}

    String reply;
try {
  reply = await _callEdgeFunction(text);
} on FunctionException catch (e) {
  debugPrint('[GuidanceScreen] FunctionException: status=${e.status} reason=${e.reasonPhrase} details=${e.details}');
  reply = 'Something interrupted the guidance just now. '
      'Please take a breath and try again. '
      '(${e.status ?? 'no status'}: ${e.reasonPhrase ?? e.details ?? 'no detail'})';
} catch (e, stack) {
  debugPrint('[GuidanceScreen] Edge function error: $e');
  debugPrint('[GuidanceScreen] Stack: $stack');
  reply = 'Something interrupted the guidance just now. '
      'Please take a breath and try again. ($e)';
}
    setState(() {
      _messages.add(_ChatMessage(role: 'assistant', content: reply));
      _loading = false;
    });

    try {
      if (_sessionId != null) {
        await GuidanceService.appendMessage(
          sessionId: _sessionId!,
          role: 'assistant',
          content: reply,
        );
      }
    } catch (_) {}

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _topic == null ? _buildTopicList() : _buildChat(),
            ),
            BottomNav(active: 'guidance', state: widget.state),
          ],
        ),
      ),
    );
  }

  // ── PDF panel ──────────────────────────────────────────────────────────────
  Widget _buildPdfPanel() {
    if (_pdfLoaded) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: kAccent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kAccent.withValues(alpha: 0.18)),
        ),
        child: Row(children: [
          const Text('📖', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bhagavad Gita loaded',
                    style: TextStyle(
                        fontSize: 12,
                        color: kAccent,
                        fontWeight: FontWeight.w500)),
                Text(_pdfFilename ?? 'gita.pdf',
                    style: const TextStyle(fontSize: 11, color: kDim),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          GestureDetector(
            onTap: _replacePdf,
            child: const Text('Replace',
                style: TextStyle(
                    fontSize: 11,
                    color: kDim,
                    decoration: TextDecoration.underline)),
          ),
        ]),
      );
    }

    return GestureDetector(
      onTap: _pdfParsing ? null : _uploadPdf,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _pdfParsing
                  ? kAccent.withValues(alpha: 0.4)
                  : kBorder),
        ),
        child: Row(children: [
          if (_pdfParsing)
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: kAccent))
          else
            const Text('📄', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _pdfParsing
                        ? 'Reading the Gita…'
                        : 'Upload Bhagavad Gita PDF',
                    style: TextStyle(
                        fontSize: 13,
                        color: _pdfParsing ? kDim : kText,
                        fontWeight: FontWeight.w500)),
                Text(
                    _pdfParsing
                        ? 'Extracting wisdom…'
                        : 'Tap to upload once — stored forever on your device',
                    style: const TextStyle(fontSize: 11, color: kDim)),
              ],
            ),
          ),
          if (!_pdfParsing)
            const Text('›', style: TextStyle(color: kDim, fontSize: 18)),
        ]),
      ),
    );
  }

  // ── Topic list ─────────────────────────────────────────────────────────────
  Widget _buildTopicList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      children: [
        const Text('Dharmic Guidance',
            style: TextStyle(
                fontSize: 28, color: kText, fontWeight: FontWeight.w400)),
        const Text('Wisdom from the Bhagavad Gita',
            style: TextStyle(fontSize: 13, color: kDim)),
        const SizedBox(height: 20),
        _buildPdfPanel(),

        if (widget.state.streak > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: kAccent.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                      '${widget.state.streak}-day streak · Keep your dharma alive',
                      style: const TextStyle(fontSize: 11, color: kAccent)),
                ]),
              ),
            ]),
          ),

        const Text('What calls for guidance today?',
            style: TextStyle(color: kDim, fontSize: 14)),
        const SizedBox(height: 8),

        ...kTopics.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DharmaCard(
                onTap: () => _pickTopic(t),
                child: Row(children: [
                  Text(t.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Text(t.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: kText,
                              fontSize: 15))),
                  const Text('›',
                      style: TextStyle(color: kDim, fontSize: 18)),
                ]),
              ),
            )),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: const Text(
            '"You have a right to perform your duties, but not to the fruits of your actions." — Bhagavad Gita, 2.47',
            style: TextStyle(
                fontSize: 12,
                color: kDim,
                fontStyle: FontStyle.italic,
                height: 1.6),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ── Chat UI ────────────────────────────────────────────────────────────────
  Widget _buildChat() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(children: [
            BackBtn(onTap: () {
              if (_isListening) _speech.stop();
              setState(() {
                _topic = null;
                _messages.clear();
                _sessionId = null;
                _isListening = false;
                _pulseController.stop();
                _pulseController.reset();
              });
            }),
            const SizedBox(width: 12),
            Text(_topic!.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(_topic!.label,
                    style: const TextStyle(
                        fontSize: 18,
                        color: kText,
                        fontWeight: FontWeight.w400))),
            if (_pdfLoaded)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('📖 Gita',
                    style: TextStyle(fontSize: 10, color: kAccent)),
              ),
          ]),
        ),

        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _messages.length) return _buildTypingBubble();
              return _buildMessageBubble(_messages[i]);
            },
          ),
        ),

        _buildInputBar(),
      ],
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kAccent.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: kAccent.withValues(alpha: 0.6))),
          const SizedBox(width: 10),
          const Text('Sitting with your words…',
              style: TextStyle(
                  color: kDim, fontSize: 13, fontStyle: FontStyle.italic)),
        ]),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(colors: [kAccent, kRust])
              : const LinearGradient(
                  colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
          borderRadius: BorderRadius.circular(16),
          border: isUser
              ? null
              : Border.all(color: kAccent.withValues(alpha: 0.25)),
        ),
        child: isUser
            ? Text(msg.content,
                style: const TextStyle(
                    fontSize: 15, color: Colors.white, height: 1.6))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✨ DHARMA GUIDE',
                      style: TextStyle(
                          fontSize: 9,
                          color: kAccent,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  Text(msg.content,
                      style: const TextStyle(
                          fontSize: 15, color: kRust, height: 1.85)),
                ],
              ),
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(children: [

        // Mic button
       
  Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: _toggleVoice,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? kRust.withValues(alpha: 0.15)
                          : kAlt,
                      border: Border.all(
                        color: _isListening
                            ? kRust.withValues(alpha: 0.8)
                            : kBorder,
                        width: _isListening ? 2.0 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: _isListening
                          ? const Icon(Icons.graphic_eq_rounded,
                              size: 22, color: kRust)
                          : const Icon(Icons.mic_rounded,
                              size: 20, color: kDim),
                    ),
                  ),
                );
              },
            ),
          ),
  ),

         const SizedBox(width: 8),

        // Text field
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (_) => _sendMessage(),
            maxLines: null,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: _isListening
                  ? 'Listening… speak now'
                  : 'Share what is on your heart…',
              hintStyle: TextStyle(
                color: _isListening
                    ? kRust.withValues(alpha: 0.6)
                    : kDim,
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor:
                  _isListening ? kRust.withValues(alpha: 0.04) : kAlt,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                      color: _isListening
                          ? kRust.withValues(alpha: 0.4)
                          : kBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                      color: _isListening ? kRust : kAccent, width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                      color: _isListening
                          ? kRust.withValues(alpha: 0.5)
                          : kBorder)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            style: const TextStyle(fontSize: 14, color: kText),
          ),
        ),

        const SizedBox(width: 8),

        // Send button
        GestureDetector(
          onTap: _sendMessage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (_loading || _isListening)
                  ? kAccent.withValues(alpha: 0.35)
                  : kAccent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _loading ? '…' : '↑',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}