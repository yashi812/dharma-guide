import 'package:dharma_guide/constants/theme.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';
import '../../services/voice_service.dart';
import '../../services/mantra_audio_service.dart'; // ← adjust path to match where you placed the file
import 'pronounciation_scorer.dart';

enum PujaState { idle, speaking, listening, processing, success, retry, done }

class PujaSessionScreen extends StatefulWidget {
  final AppState state;
  const PujaSessionScreen({super.key, required this.state});

  @override
  State<PujaSessionScreen> createState() => _PujaSessionScreenState();
}

class _PujaSessionScreenState extends State<PujaSessionScreen>
    with SingleTickerProviderStateMixin {
  PujaState _ps = PujaState.idle;
  int _idx = 0;
  String _partialSpoken = '';
  String _finalSpoken = '';
  double _score = 0;
  int _retries = 0;
  bool _voiceReady = false;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  static const double _passThreshold = 0.62;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _initVoice();
  }

  Future<void> _initVoice() async {
    await VoiceService.instance.init();
    if (!mounted) return;
    setState(() {
      _voiceReady = true;
      _ps = PujaState.speaking;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    // Go straight to line 0 — gTTS will speak just that line
    if (mounted) _doSpeak(0);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    VoiceService.instance.stopSpeaking();
    VoiceService.instance.stopListening();
    MantraAudioService.instance.stopAll();
    super.dispose();
  }

  // ── Core flow ─────────────────────────────────────────────────────────────

  void _doSpeak(int i) {
    if (!mounted) return;
    setState(() {
      _ps = PujaState.speaking;
      _partialSpoken = '';
      _finalSpoken = '';
      _idx = i;
    });

    VoiceService.instance.stopSpeaking();
    final mantra = widget.state.selectedMantra!;

    // Speak ONLY this line via TTS — user then repeats just this line
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      MantraAudioService.instance.playLine(
        lineText: mantra.lines[i],
        devanagariText: mantra.lines[i],
        onDone: () {
          if (mounted) _doListen(i);
        },
      );
    });
  }

  void _doListen(int i) {
    if (!mounted) return;
    setState(() {
      _ps = PujaState.listening;
      _partialSpoken = '';
    });

    if (!VoiceService.instance.sttAvailable) {
      _doEval(i, widget.state.selectedMantra!.tr[i]);
      return;
    }

    VoiceService.instance.startListening(
      onPartial: (text) {
        if (mounted) setState(() => _partialSpoken = text);
      },
      onFinal: (text) => _doEval(i, text),
    );
  }

  void _doEval(int i, String recognised) {
    if (!mounted) return;
    final expected = widget.state.selectedMantra!.tr[i];
    final sc = PronunciationScorer.score(recognised, expected);

    setState(() {
      _ps = PujaState.processing;
      _finalSpoken = recognised;
      _score = sc;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final pass = sc >= _passThreshold;
      final mantra = widget.state.selectedMantra!;

      if (pass) {
        setState(() => _ps = PujaState.success);
        final next = i + 1;
        if (next >= mantra.lines.length) {
          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted) return;
            setState(() => _ps = PujaState.done);
            Future.delayed(const Duration(milliseconds: 800),
                () => widget.state.nav('puja_complete'));
          });
        } else {
          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted) return;
            setState(() => _retries = 0);
            _doSpeak(next);
          });
        }
      } else {
        setState(() {
          _retries++;
          _ps = PujaState.retry;
        });
      }
    });
  }

  // ── Colours / labels ──────────────────────────────────────────────────────

  Color get _stateColor => {
        PujaState.speaking: const Color(0xFF3A8BC4),
        PujaState.listening: kAccent,
        PujaState.processing: kDim,
        PujaState.success: kGreen,
        PujaState.retry: kRust,
        PujaState.done: kGreen,
        PujaState.idle: kDim,
      }[_ps]!;

  String get _stateIcon => {
        PujaState.speaking: '🔊',
        PujaState.listening: '🎙',
        PujaState.processing: '⌛',
        PujaState.success: '✓',
        PujaState.retry: '↺',
        PujaState.done: '🙏',
        PujaState.idle: '○',
      }[_ps]!;

  String get _stateMsg => {
        PujaState.speaking: 'Listen carefully…',
        PujaState.listening: 'Now repeat the line',
        PujaState.processing: 'Evaluating…',
        PujaState.success: 'Well done! 🙏',
        PujaState.retry: 'Try again slowly',
        PujaState.done: 'Complete!',
        PujaState.idle: 'Getting ready…',
      }[_ps]!;

  // ── Pandit hint helpers ───────────────────────────────────────────────────

  String _panditHint(String tr) {
    return tr
        .replaceAll('bhu', 'BHOO')
        .replaceAll('bha', 'BHA')
        .replaceAll('bhi', 'BHI')
        .replaceAll('bho', 'BHO')
        .replaceAll('dha', 'DHA')
        .replaceAll('dhi', 'DHI')
        .replaceAll('dho', 'DHO')
        .replaceAll('gha', 'GHA')
        .replaceAll('sha', 'SHA')
        .replaceAll('shi', 'SHI')
        .replaceAll('shu', 'SHU')
        .replaceAll('shri', 'SHRI')
        .replaceAll('ksh', 'KSHA')
        .replaceAll('aa', 'AA')
        .replaceAll('ii', 'EE')
        .replaceAll('uu', 'OO')
        .replaceAll('ai', 'AI')
        .replaceAll('au', 'OU')
        .replaceAll('aum', 'OM')
        .replaceAll('om', 'OM')
        .replaceAll('namah', 'NA-mah')
        .replaceAll('namaha', 'NA-ma-ha')
        .replaceAll('swaha', 'SVA-ha')
        .replaceAll('svaha', 'SVA-ha')
        .replaceAll('devasya', 'DE-vas-ya')
        .replaceAll('vareṇyam', 'va-REN-yam')
        .replaceAll('dhimahi', 'DHEE-ma-hi')
        .replaceAll('prachodayat', 'pra-CHO-da-yaat')
        .toUpperCase();
  }

  String _pronounceGuide(String tr) {
    final guides = <String, String>{
      'om bhur bhuvah svah':
          'ओम् भूर् भुवः स्वः — बोलें: OM  BHOOR  BHOO-vah  SVAH',
      'tat savitur varenyam':
          'तत् सवितुर् वरेण्यम् — बोलें: tat  SA-vi-tur  va-REN-yam',
      'bhargo devasya dhimahi':
          'भर्गो देवस्य धीमहि — बोलें: BHAR-go  DE-vas-ya  DHEE-ma-hi',
      'dhiyo yo nah prachodayat':
          'धियो यो नः प्रचोदयात् — बोलें: DHI-yo  yo  nah  pra-CHO-da-yaat',
      'om namah shivaya':
          'ओम् नमः शिवाय — बोलें: OM  NA-mah  shi-VAA-ya',
      'om namo bhagavate':
          'ओम् नमो भगवते — बोलें: OM  NA-mo  BHA-ga-va-te',
      'om mani padme hum':
          'ओम् मणि पद्मे हुम् — बोलें: OM  MA-ni  PAD-me  HUM',
      'hare krishna hare krishna': 'हरे कृष्ण हरे कृष्ण — बोलें: HA-re  KRISH-na',
      'hare rama hare rama': 'हरे राम हरे राम — बोलें: HA-re  RAA-ma',
    };

    final lower = tr.toLowerCase().trim();
    for (final key in guides.keys) {
      if (lower.contains(key)) return guides[key]!;
    }
    return 'बोलें: ${tr.replaceAll(' ', '  ·  ')}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mantra = widget.state.selectedMantra;
    if (mantra == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.state.nav('puja_select'));
      return const SizedBox();
    }

    final progress = (_idx + 1) / mantra.lines.length;
    final isListening = _ps == PujaState.listening;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    VoiceService.instance.stopSpeaking();
                    VoiceService.instance.stopListening();
                    MantraAudioService.instance.stopAll();
                    widget.state.nav('puja_select');
                  },
                  child: const Text('✕',
                      style: TextStyle(fontSize: 22, color: kDim)),
                ),
                const SizedBox(width: 12),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(mantra.name,
                      style: const TextStyle(fontSize: 19, color: kText)),
                  Text('Line ${_idx + 1} of ${mantra.lines.length}',
                      style: const TextStyle(fontSize: 12, color: kDim)),
                ]),
              ]),
            ),

            // ── Progress bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.04, 1.0),
                  backgroundColor: kBorder,
                  valueColor: const AlwaysStoppedAnimation(kAccent),
                  minHeight: 3,
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      mantra.lines[_idx],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28,
                          color: kRust,
                          height: 1.7,
                          letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      mantra.tr[_idx],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          color: kDim,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.4),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8ED),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: kAccent.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PANDIT PRONUNCIATION',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: kAccent,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            _panditHint(mantra.tr[_idx]),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 17,
                                color: kRust,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                                height: 1.6),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _pronounceGuide(mantra.tr[_idx]),
                            style: const TextStyle(
                                fontSize: 11, color: kDim, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) {
                      final scale = isListening ? _pulseAnim.value : 1.0;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _stateColor, width: 2.5),
                        color: _stateColor.withOpacity(0.09),
                      ),
                      child: Center(
                          child: Text(_stateIcon,
                              style: const TextStyle(fontSize: 34))),
                    ),
                  ),
                  const SizedBox(height: 12),

                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                        fontSize: 14,
                        color: _stateColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3),
                    child: Text(_stateMsg),
                  ),

                  if (isListening && _partialSpoken.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                          color: kAlt,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '"$_partialSpoken"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: kText, height: 1.7),
                      ),
                    ),
                  ],

                  if (_ps == PujaState.retry && _finalSpoken.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                          color: kAlt,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        Text(
                          '"$_finalSpoken"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: kText, height: 1.7),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Match: ${(_score * 100).round()}% · Need ${(_passThreshold * 100).round()}% to pass',
                          style: const TextStyle(
                              fontSize: 11, color: kDim),
                        ),
                      ]),
                    ),
                  ],

                  if (_ps == PujaState.retry) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(children: [
                        Expanded(
                            child: DharmaBtn(
                                label: 'Try Again',
                                onTap: () {
                                  setState(() => _partialSpoken = '');
                                  _doSpeak(_idx);
                                })),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DharmaBtn(
                            label: 'Skip',
                            variant: 'secondary',
                            onTap: () {
                              final next = _idx + 1;
                              if (next >= mantra.lines.length) {
                                setState(() => _ps = PujaState.done);
                                Future.delayed(
                                    const Duration(milliseconds: 800),
                                    () => widget.state
                                        .nav('puja_complete'));
                              } else {
                                setState(() => _retries = 0);
                                _doSpeak(next);
                              }
                            },
                          ),
                        ),
                      ]),
                    ),
                  ],

                  if (_voiceReady && !VoiceService.instance.sttAvailable) ...[
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '⚠️ Microphone not available — running in listen-only mode',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: kDim),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mantra.lines.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _idx
                          ? kGreen
                          : i == _idx
                              ? kAccent
                              : kBorder,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}