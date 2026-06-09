// ─────────────────────────────────────────────────────────────────────────────
// guidance_screen.dart  (v5 — adds floating "Show Kundli" pill button)
//
// Changes from v4:
//   • Added _kundliData field + _showKundliSheet() method
//   • _buildInputBar() now has a slim "🪐 Kundli" pill above the text row
//     that is always visible at the bottom of the screen (chat & topic views)
//   • When a chart is loaded the pill turns accent-coloured and shows the
//     Lagna abbreviation so the user knows it is active
//   • Imports kundli_sheet.dart + kundli_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionStatus, PermissionActions, PermissionStatusGetters;
import '../constants/theme.dart';
import '../constants/app_data.dart';
import '../../models/models.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';
import '../../services/supabase_service.dart';
import 'gita_pdf_service.dart';
import 'kundli_sheet.dart';
import 'kundli_service.dart';

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

  // ── Kundli state ────────────────────────────────────────────────────────────
  KundliData? _kundliData;

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

  // ── Init ────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadStoredPdf();
    _speech = stt.SpeechToText();
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
  }

/// Scans chat history for birth detail patterns and returns pre-fill values.
KundliInitialValues _extractBirthDetails() {
  // Collect all user messages into one searchable string
  final userText = _messages
      .where((m) => m.role == 'user')
      .map((m) => m.content)
      .join(' ');

  // ── Name ──────────────────────────────────────────────────────
  // Matches: "my name is Arjun", "I am Priya", "I'm Rahul Sharma"
  String? name;
  final nameMatch = RegExp(
    r"(?:my name is|i am|i'm|naam hai|mera naam)\s+([A-Za-z][A-Za-z\s]{1,30})",
    caseSensitive: false,
  ).firstMatch(userText);
  if (nameMatch != null) {
    name = nameMatch.group(1)?.trim().split(RegExp(r'\s{2,}')).first;
  }

  // ── Date ──────────────────────────────────────────────────────
  // Matches: DD/MM/YYYY  DD-MM-YYYY  DD.MM.YYYY
  //          "15th March 1990"  "March 15 1990"  "15 March 1990"
  DateTime? date;

  final numericDate = RegExp(
    r'\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})\b',
  ).firstMatch(userText);
  if (numericDate != null) {
    final d = int.tryParse(numericDate.group(1)!);
    final m = int.tryParse(numericDate.group(2)!);
    final y = int.tryParse(numericDate.group(3)!);
    if (d != null && m != null && y != null &&
        m >= 1 && m <= 12 && d >= 1 && d <= 31) {
      date = DateTime(y, m, d);
    }
  }

  if (date == null) {
    // "15th March 1990" / "March 15 1990" / "15 March 1990"
    const months = {
      'january': 1, 'jan': 1, 'february': 2, 'feb': 2,
      'march': 3, 'mar': 3, 'april': 4, 'apr': 4,
      'may': 5, 'june': 6, 'jun': 6, 'july': 7, 'jul': 7,
      'august': 8, 'aug': 8, 'september': 9, 'sep': 9, 'sept': 9,
      'october': 10, 'oct': 10, 'november': 11, 'nov': 11,
      'december': 12, 'dec': 12,
    };
    final monthPattern = months.keys.join('|');
    final verbal = RegExp(
      r'\b(\d{1,2})(?:st|nd|rd|th)?\s+(' + monthPattern + r')\s+(\d{4})\b'
      r'|'
      r'\b(' + monthPattern + r')\s+(\d{1,2})(?:st|nd|rd|th)?,?\s+(\d{4})\b',
      caseSensitive: false,
    ).firstMatch(userText);
    if (verbal != null) {
      // group 1-3: "15 March 1990"   group 4-6: "March 15 1990"
      final dayStr   = verbal.group(1) ?? verbal.group(5);
      final monStr   = verbal.group(2) ?? verbal.group(4);
      final yearStr  = verbal.group(3) ?? verbal.group(6);
      final d = int.tryParse(dayStr ?? '');
      final m = monStr != null ? months[monStr.toLowerCase()] : null;
      final y = int.tryParse(yearStr ?? '');
      if (d != null && m != null && y != null) {
        date = DateTime(y, m, d);
      }
    }
  }

  // ── Time ──────────────────────────────────────────────────────
  // Matches: "10:30 AM"  "22:15"  "10:30am"  "10 AM"
  TimeOfDay? time;
  final timeMatch = RegExp(
    r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b',
    caseSensitive: false,
  ).firstMatch(userText);
  if (timeMatch != null) {
    var hour   = int.tryParse(timeMatch.group(1)!) ?? -1;
    final min  = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
    final ampm = timeMatch.group(3)?.toLowerCase();
    if (hour >= 0 && hour <= 23 && min >= 0 && min <= 59) {
      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;
      time = TimeOfDay(hour: hour, minute: min);
    }
  }

  // ── Location ──────────────────────────────────────────────────
  // Matches: "born in Mumbai"  "from New Delhi"  "in Bangalore"
  String? location;
  final locMatch = RegExp(
    r'(?:born in|from|in|place[:\s]+|city[:\s]+|location[:\s]+)'
    r'\s+([A-Za-z][A-Za-z\s,]{2,30})',
    caseSensitive: false,
  ).firstMatch(userText);
  if (locMatch != null) {
    // trim trailing noise words
    location = locMatch.group(1)
        ?.trim()
        .replaceAll(RegExp(r'\s+(and|on|at|the|a|an).*$', caseSensitive: false), '');
  }

  return KundliInitialValues(
    name: name?.isEmpty == true ? null : name,
    date: date,
    time: time,
    location: location?.isEmpty == true ? null : location,
  );
}

  // ── Kundli sheet ─────────────────────────────────────────────────────────
  // AFTER
 Future<void> _showKundliSheet() async {
  final s = widget.state;

  // If chart already loaded → show it directly
  if (_kundliData != null) {
    await KundliSheet.showChart(context, _kundliData!);
    return;
  }

  if (s.hasBirthDetails) {
    await _generateKundliSilently(
      name:  s.birthName ?? s.userName,
      date:  s.birthDate!,
      time:  s.birthTime!,
      place: s.birthPlace!,
    );
    return;
  }

  final kundli = await KundliSheet.show(context);
  if (kundli == null || !mounted) return;

  await s.setBirthDetails(
    name:   kundli.name,
    date:   kundli.date,
    time:   kundli.time,
    place:  kundli.location,
    gender: '',
  );
  _applyKundli(kundli);
}
 
  /// Generates a Kundli in the background with a loading snackbar,
  /// then applies the result — no sheet required.
  Future<void> _generateKundliSilently({
    required String name,
    required String date,   // DD/MM/YYYY
    required String time,   // HH:MM
    required String place,
  }) async {
    if (!mounted) return;
 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Reading your cosmic blueprint…'),
          ],
        ),
        backgroundColor: kAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 30),
      ),
    );
 
    try {
      final kundli = await KundliService.generateKundli(
        name:     name,
        date:     date,
        time:     time,
        location: place,
      );
 
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _applyKundli(kundli);
 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not generate chart — please check your details'),
          backgroundColor: kRust,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Fall back to form — but pre-fill with whatever we have in AppState
      final s = widget.state;
      final kundli = await KundliSheet.show(
        context,
        initialValues: KundliInitialValues(
          name:     s.birthName,
          location: s.birthPlace,
          date:     s.birthDate != null ? _parseDdMmYyyy(s.birthDate!) : null,
          time:     s.birthTime != null ? _parseHhMm(s.birthTime!)     : null,
        ),
      );
      if (kundli == null || !mounted) return;
 
      // Update stored details with whatever the user corrected
      await s.setBirthDetails(
        name:   kundli.name,
        date:   kundli.date,
        time:   kundli.time,
        place:  kundli.location,
        gender: '',
      );
      _applyKundli(kundli);
    }
  }
 
  // ── Parse helpers for pre-filling KundliInitialValues ─────────────────────
  static DateTime? _parseDdMmYyyy(String s) {
    // s is DD/MM/YYYY
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }
 
  static TimeOfDay? _parseHhMm(String s) {
    // s is HH:MM
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
 
  /// Stores the chart in local state + AppState and shows a confirmation.
  void _applyKundli(KundliData kundli) {
    setState(() => _kundliData = kundli);
 
    try {
      widget.state.setKundliData(jsonEncode(kundli.toJson()));
    } catch (_) {}
 
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🪐 Chart loaded · लग्न ${kundli.lagna} · राशि ${kundli.rashi}',
        ),
        backgroundColor: kAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  // ── Voice ──────────────────────────────────────────────────────────────────
  Future<void> _toggleVoice() async {
    if (!kIsWeb) {
      final status = await Permission.microphone.request();
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

    if (!_speech.isAvailable) {
      final available = await _speech.initialize(
        onStatus: (s) => debugPrint('[Voice] status: $s'),
        onError:  (e) => debugPrint('[Voice] error: ${e.errorMsg}'),
      );
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

    await _showVoiceDialog();
  }

  Future<void> _showVoiceDialog() async {
    String recognized = '';
    bool listening = false;
    bool done      = false;
    bool started   = false;
    StateSetter? setDialog;

    void startListening() {
      listening = true;
      setDialog?.call(() {});
      _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) recognized = result.recognizedWords;
          if (result.finalResult) { done = true; listening = false; }
          setDialog?.call(() {});
        },
        onSoundLevelChange: (_) {},
        listenFor:      const Duration(seconds: 60),
        pauseFor:       const Duration(seconds: 5),
        partialResults: true,
        cancelOnError:  false,
      );
    }

    if (!kIsWeb) {
      _speech.statusListener = (status) {
        if ((status == 'notListening' || status == 'done') && !done && started) {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (!done && setDialog != null) startListening();
          });
        }
      };
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          setDialog = setDialogState;
          if (!started) { started = true; Future.microtask(startListening); }

          return AlertDialog(
            backgroundColor: const Color(0xFFFFF8ED),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: listening && !done ? 1.2 : 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? kAccent.withValues(alpha: 0.1) : kRust.withValues(alpha: 0.1),
                      border: Border.all(color: done ? kAccent : kRust, width: 2),
                    ),
                    child: Icon(done ? Icons.check_rounded : Icons.mic_rounded,
                        color: done ? kAccent : kRust, size: 30),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  done ? 'Got it!' : listening ? 'Listening… speak now' : 'Starting…',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      color: done ? kAccent : kRust),
                ),
                const SizedBox(height: 14),
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
                    recognized.isEmpty ? 'Your words will appear here…' : recognized,
                    style: TextStyle(
                      fontSize: 15, height: 1.5,
                      color: recognized.isEmpty ? kDim : kText,
                      fontStyle: recognized.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        side: const BorderSide(color: kBorder),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: kDim, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: recognized.trim().isEmpty ? null : () async {
                        await _speech.stop();
                        if (!kIsWeb) _speech.statusListener = null;
                        Navigator.of(ctx).pop();
                        final existing = _controller.text.trim();
                        _controller.text = existing.isEmpty
                            ? recognized.trim()
                            : '$existing ${recognized.trim()}';
                        _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: _controller.text.length));
                        Future.delayed(const Duration(milliseconds: 200), _sendMessage);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        disabledBackgroundColor: kAccent.withValues(alpha: 0.35),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      child: const Text('Use this',
                          style: TextStyle(color: Colors.white, fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );

    if (!kIsWeb) _speech.statusListener = null;
  }

  // ── PDF helpers ────────────────────────────────────────────────────────────
  Future<void> _loadStoredPdf() async {
    final loaded = await GitaPdfService.isPdfLoaded();
    if (loaded) {
      final text     = await GitaPdfService.getStoredText();
      final filename = await GitaPdfService.getStoredFilename();
      if (mounted) setState(() { _pdfLoaded = true; _pdfText = text; _pdfFilename = filename; });
    }
  }

  Future<void> _uploadPdf() async {
    setState(() => _pdfParsing = true);
    final result = await GitaPdfService.pickAndParsePdf();
    if (!mounted) return;
    setState(() => _pdfParsing = false);
    if (result.isSuccess) {
      final text = await GitaPdfService.getStoredText();
      setState(() { _pdfLoaded = true; _pdfText = text; _pdfFilename = result.filename; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✓ ${result.summaryText}'),
        backgroundColor: kAccent, behavior: SnackBarBehavior.floating,
      ));
    } else if (result.isError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.errorMessage ?? 'Failed to load PDF'),
        backgroundColor: kRust, behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _replacePdf() async {
    await GitaPdfService.clearStoredPdf();
    setState(() { _pdfLoaded = false; _pdfText = null; _pdfFilename = null; });
    await _uploadPdf();
  }

  // ── Topic selection ────────────────────────────────────────────────────────
  Future<void> _pickTopic(Topic t) async {
    setState(() { _topic = t; _messages.clear(); _loading = true; });
    try {
      _sessionId = await GuidanceService.startSession(
          topicId: t.id, topicLabel: t.label, guidanceStyle: widget.state.userStyle);
    } catch (_) {}

    final greeting = _buildOpeningGreeting(t);
    setState(() { _messages.add(_ChatMessage(role: 'assistant', content: greeting)); _loading = false; });
    try {
      if (_sessionId != null) {
        await GuidanceService.appendMessage(sessionId: _sessionId!, role: 'assistant', content: greeting);
      }
    } catch (_) {}
    _scrollToBottom();
  }

  String _buildOpeningGreeting(Topic t) {
    final label = t.label.toLowerCase();
    const gitaLines = [
      '\n\nThe Bhagavad Gita begins in a moment very much like this one — with a person overwhelmed, uncertain, sitting at the edge of something difficult. That is precisely where wisdom has always found its most willing students.',
      '\n\nThe wisdom of the Gita was given to a person in pain, at a crossroads, not sure which way to turn. That is where you are. And that is exactly the right place to begin.',
      '\n\nThe Gita\'s first chapter is called "Arjuna\'s Grief." The text does not begin with triumph — it begins with a man on his knees, bewildered. If that resonates — good. You are in the right place.',
    ];
    final gitaLine = gitaLines[DateTime.now().second % gitaLines.length];
    if (label.contains('decision') || label.contains('difficult')) {
      return 'You have arrived at a crossroads.$gitaLine\n\nWhat is weighing on you?';
    }
    if (label.contains('emotional') || label.contains('pain')) {
      return 'You have come here carrying something.$gitaLine\n\nWhat is weighing on you?';
    }
    if (label.contains('purpose') || label.contains('lack'))
      return 'The search for meaning is one of the most honest things a person can do.$gitaLine\n\nWhat is weighing on you?';
    if (label.contains('relation') || label.contains('trouble'))
      return 'Matters of the heart are never simple.$gitaLine\n\nWhat is weighing on you?';
    if (label.contains('work') || label.contains('career'))
      return 'Something brought you here today.$gitaLine\n\nWhat is weighing on you?';
    return 'Whatever brought you here today — I am glad you came.$gitaLine\n\nWhat is weighing on you?';
  }

  // ── Edge function call ─────────────────────────────────────────────────────
  Future<String> _callEdgeFunction(String userMessage) async {
    final history = _messages.map((m) => {'role': m.role, 'text': m.content}).toList();

    String? kundliString;
    final kundliSource = _kundliData ?? widget.state.kundliData;
    if (kundliSource != null) {
      try {
        if (kundliSource is KundliData) {
          kundliString = kundliSource.toContextString();
        } else if (kundliSource is String) {
          kundliString = kundliSource;
        } else {
          kundliString = jsonEncode(kundliSource);
        }
      } catch (_) {
        kundliString = kundliSource.toString();
      }
    }

    final body = <String, dynamic>{
      'userMessage': userMessage,
      'history': history,
      'topicLabel': _topic?.label,
      if (kundliString != null && kundliString.isNotEmpty) 'kundliData': kundliString,
    };

    final response = await _db.functions.invoke(
      'dharmic-guidance',
      body: body,
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrbHlzemZuYWViYnBreGxtaWx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTI5MDQsImV4cCI6MjA5MTAyODkwNH0.z14EBElS6PeTZQOHkoVLYdPebjIUigRLeHdd4X6bI2I',
      },
    );

    final raw = response.data;
    if (raw == null) throw Exception('Null response from edge function');

    final Map<String, dynamic> json = raw is String
        ? jsonDecode(raw) as Map<String, dynamic>
        : Map<String, dynamic>.from(raw as Map);

    if (json.containsKey('error')) throw Exception('Edge function error: ${json['error']}');
    final text = json['text'] as String?;
    if (text == null || text.trim().isEmpty) throw Exception('Empty text in response');
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

    setState(() { _messages.add(_ChatMessage(role: 'user', content: text)); _loading = true; });
    _scrollToBottom();

    try {
      if (_sessionId != null) {
        await GuidanceService.appendMessage(sessionId: _sessionId!, role: 'user', content: text);
      }
    } catch (_) {}

    String reply;
    try {
      reply = await _callEdgeFunction(text);
    } on FunctionException catch (e) {
      reply = 'Something interrupted the guidance just now. Please take a breath and try again. '
          '(${e.status ?? 'no status'}: ${e.reasonPhrase ?? e.details ?? 'no detail'})';
    } catch (e) {
      reply = 'Something interrupted the guidance just now. Please take a breath and try again. ($e)';
    }

    setState(() { _messages.add(_ChatMessage(role: 'assistant', content: reply)); _loading = false; });
    try {
      if (_sessionId != null) {
        await GuidanceService.appendMessage(sessionId: _sessionId!, role: 'assistant', content: reply);
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
            // ── Kundli pill + input bar share the same bottom container ──
            _buildBottomBar(),
            BottomNav(active: 'guidance', state: widget.state),
          ],
        ),
      ),
    );
  }

  // ── Combined bottom bar (kundli pill + input/placeholder) ─────────────────
  Widget _buildBottomBar() {
    final hasChart = _kundliData != null;

    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Kundli pill row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                // The pill itself
                GestureDetector(
                  onTap: _showKundliSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasChart
                          ? kAccent.withValues(alpha: 0.12)
                          : kAlt,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: hasChart
                            ? kAccent.withValues(alpha: 0.45)
                            : kBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasChart ? '🪐' : '✨',
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          hasChart
                              ? 'Kundli · ${_kundliData!.lagna}'
                              : 'Show Kundli',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: hasChart ? kAccent : kDim,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (hasChart) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined,
                              size: 10, color: kAccent.withValues(alpha: 0.7)),
                        ],
                      ],
                    ),
                  ),
                ),

                // Dim subtitle when chart is loaded
                if (hasChart) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_kundliData!.rashi} · ${_kundliData!.nakshatra}',
                      style: const TextStyle(fontSize: 10, color: kDim),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Input row (only in chat view; hidden on topic list) ────────────
          if (_topic != null)
            _buildInputRow()
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Input row (extracted from old _buildInputBar) ──────────────────────────
  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Row(children: [
        // Mic
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleVoice,
            borderRadius: BorderRadius.circular(100),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? kRust.withValues(alpha: 0.15) : kAlt,
                    border: Border.all(
                      color: _isListening ? kRust.withValues(alpha: 0.8) : kBorder,
                      width: _isListening ? 2.0 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: _isListening
                        ? const Icon(Icons.graphic_eq_rounded, size: 22, color: kRust)
                        : const Icon(Icons.mic_rounded, size: 20, color: kDim),
                  ),
                ),
              ),
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
              hintText: _isListening ? 'Listening… speak now' : 'Share what is on your heart…',
              hintStyle: TextStyle(
                color: _isListening ? kRust.withValues(alpha: 0.6) : kDim,
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor: _isListening ? kRust.withValues(alpha: 0.04) : kAlt,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                      color: _isListening ? kRust.withValues(alpha: 0.4) : kBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                      color: _isListening ? kRust : kAccent, width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                      color: _isListening ? kRust.withValues(alpha: 0.5) : kBorder)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            style: const TextStyle(fontSize: 14, color: kText),
          ),
        ),

        const SizedBox(width: 8),

        // Send
        GestureDetector(
          onTap: _sendMessage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42, height: 42,
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Bhagavad Gita loaded',
                  style: TextStyle(fontSize: 12, color: kAccent, fontWeight: FontWeight.w500)),
              Text(_pdfFilename ?? 'gita.pdf',
                  style: const TextStyle(fontSize: 11, color: kDim),
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          GestureDetector(
            onTap: _replacePdf,
            child: const Text('Replace',
                style: TextStyle(fontSize: 11, color: kDim, decoration: TextDecoration.underline)),
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
          border: Border.all(color: _pdfParsing ? kAccent.withValues(alpha: 0.4) : kBorder),
        ),
        child: Row(children: [
          if (_pdfParsing)
            const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: kAccent))
          else
            const Text('📄', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_pdfParsing ? 'Reading the Gita…' : 'Upload Bhagavad Gita PDF',
                  style: TextStyle(fontSize: 13,
                      color: _pdfParsing ? kDim : kText, fontWeight: FontWeight.w500)),
              Text(_pdfParsing ? 'Extracting wisdom…' : 'Tap to upload once — stored forever on your device',
                  style: const TextStyle(fontSize: 11, color: kDim)),
            ]),
          ),
          if (!_pdfParsing) const Text('›', style: TextStyle(color: kDim, fontSize: 18)),
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
            style: TextStyle(fontSize: 28, color: kText, fontWeight: FontWeight.w400)),
        const Text('Wisdom from the Bhagavad Gita',
            style: TextStyle(fontSize: 13, color: kDim)),
        const SizedBox(height: 20),
        _buildPdfPanel(),

        if (widget.state.streak > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: kAccent.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text('${widget.state.streak}-day streak · Keep your dharma alive',
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
              Expanded(child: Text(t.label,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: kText, fontSize: 15))),
              const Text('›', style: TextStyle(color: kDim, fontSize: 18)),
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
            style: TextStyle(fontSize: 12, color: kDim, fontStyle: FontStyle.italic, height: 1.6),
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
                _topic = null; _messages.clear();
                _sessionId = null; _isListening = false;
                _pulseController.stop(); _pulseController.reset();
              });
            }),
            const SizedBox(width: 12),
            Text(_topic!.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(child: Text(_topic!.label,
                style: const TextStyle(fontSize: 18, color: kText, fontWeight: FontWeight.w400))),
            if (_pdfLoaded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('📖 Gita', style: TextStyle(fontSize: 10, color: kAccent)),
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
          gradient: const LinearGradient(colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kAccent.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: kAccent.withValues(alpha: 0.6))),
          const SizedBox(width: 10),
          const Text('Sitting with your words…',
              style: TextStyle(color: kDim, fontSize: 13, fontStyle: FontStyle.italic)),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(colors: [kAccent, kRust])
              : const LinearGradient(colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: kAccent.withValues(alpha: 0.25)),
        ),
        child: isUser
            ? Text(msg.content, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.6))
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('✨ DHARMA GUIDE',
                    style: TextStyle(fontSize: 9, color: kAccent,
                        letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                Text(msg.content,
                    style: const TextStyle(fontSize: 15, color: kRust, height: 1.85)),
              ]),
      ),
    );
  }
}