import 'package:dharma_guide/theme.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';

// NOTE: Full TTS/STT requires these plugins in pubspec.yaml:
//   flutter_tts: ^4.0.0
//   speech_to_text: ^6.6.0
// Integration hooks are clearly marked with TODO comments below.

enum PujaState { idle, speaking, listening, processing, success, retry, done }

class PujaSessionScreen extends StatefulWidget {
  final AppState state;
  const PujaSessionScreen({super.key, required this.state});

  @override
  State<PujaSessionScreen> createState() => _PujaSessionScreenState();
}

class _PujaSessionScreenState extends State<PujaSessionScreen> {
  PujaState _ps = PujaState.idle;
  int _idx = 0;
  String _spoken = '';
  double _score = 0;
  int _retries = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () => _doSpeak(0));
  }

  void _doSpeak(int i) {
    if (!mounted) return;
    setState(() {
      _ps = PujaState.speaking;
      _spoken = '';
      _idx = i;
    });

    // TODO: Replace simulated delay with flutter_tts:
    // final tts = FlutterTts();
    // await tts.setLanguage("en-US");
    // await tts.setSpeechRate(0.7);
    // await tts.speak(widget.state.selectedMantra!.tr[i]);
    // tts.setCompletionHandler(() => _doListen(i));
    Future.delayed(const Duration(seconds: 3), () => _doListen(i));
  }

  void _doListen(int i) {
    if (!mounted) return;
    setState(() => _ps = PujaState.listening);

    // TODO: Replace simulated delay with speech_to_text:
    // final stt = SpeechToText();
    // await stt.initialize();
    // await stt.listen(
    //   onResult: (result) {
    //     if (result.finalResult) _doEval(i, result.recognizedWords);
    //     else setState(() => _spoken = result.recognizedWords);
    //   },
    //   localeId: "en_US",
    // );
    // Future.delayed(const Duration(seconds: 6), () => stt.stop());
    Future.delayed(const Duration(seconds: 4),
        () => _doEval(i, widget.state.selectedMantra!.tr[i]));
  }

  void _doEval(int i, String recognized) {
    if (!mounted) return;
    setState(() {
      _ps = PujaState.processing;
      _spoken = recognized;
      _score = 0.85; // TODO: replace with fuzzyScore(recognized, mantra.tr[i])
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      const pass = true; // TODO: replace with _score >= 0.62
      final mantra = widget.state.selectedMantra!;
      if (pass) {
        setState(() => _ps = PujaState.success);
        final next = i + 1;
        if (next >= mantra.lines.length) {
          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted) return;
            setState(() => _ps = PujaState.done);
            Future.delayed(const Duration(seconds: 1),
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
        PujaState.speaking: 'Listen carefully...',
        PujaState.listening: 'Now repeat the line',
        PujaState.processing: 'Evaluating...',
        PujaState.success: 'Well done! 🙏',
        PujaState.retry: 'Try again slowly',
        PujaState.done: 'Complete!',
        PujaState.idle: '',
      }[_ps]!;

  @override
  Widget build(BuildContext context) {
    final mantra = widget.state.selectedMantra;
    if (mantra == null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.state.nav('puja_select'));
      return const SizedBox();
    }

    final progress = _idx / mantra.lines.length;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => widget.state.nav('puja_select'),
                  child: const Text('✕',
                      style: TextStyle(fontSize: 22, color: kDim)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mantra.name,
                      style: const TextStyle(fontSize: 19, color: kText)),
                  Text('Line ${_idx + 1} of ${mantra.lines.length}',
                      style: const TextStyle(fontSize: 12, color: kDim)),
                ]),
              ]),
            ),

            // Progress bar
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

            // Main content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Devanagari line
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      mantra.lines[_idx],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, color: kRust, height: 1.7, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Transliteration
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
                  const SizedBox(height: 24),

                  // State bubble
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _stateColor, width: 2.5),
                      color: _stateColor.withOpacity(0.09),
                    ),
                    child: Center(
                        child:
                            Text(_stateIcon, style: const TextStyle(fontSize: 34))),
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

                  // Spoken preview
                  if (_spoken.isNotEmpty &&
                      _ps != PujaState.success &&
                      _ps != PujaState.done) ...[
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                          color: kAlt,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('"$_spoken"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: kText, height: 1.7)),
                    ),
                  ],

                  // Retry controls
                  if (_ps == PujaState.retry) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(children: [
                        Expanded(
                            child: DharmaBtn(
                                label: 'Try Again',
                                onTap: () => _doSpeak(_idx))),
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
                                    () => widget.state.nav('puja_complete'));
                              } else {
                                setState(() => _retries = 0);
                                _doSpeak(next);
                              }
                            },
                          ),
                        ),
                      ]),
                    ),
                    if (_retries > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                          'Match: ${(_score * 100).round()}% · Need 62% to pass',
                          style: const TextStyle(fontSize: 12, color: kDim)),
                    ],
                  ],
                ],
              ),
            ),

            // Dot indicators
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
