import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin wrapper around flutter_tts + speech_to_text.
/// Exposes simple async helpers used by PujaSessionScreen.
class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _sttAvailable = false;
  bool _sttActive = false;

  // ── Initialisation ───────────────────────────────────────────────────────

  Future<void> init() async {
    // TTS setup
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.55); // slightly slower for mantra recitation
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    // STT setup
    _sttAvailable = await _stt.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
  }

  // ── TTS ──────────────────────────────────────────────────────────────────

  /// Speak [text] and call [onDone] when finished.
  Future<void> speak(String text, {required VoidCallback onDone}) async {
    await _tts.stop();
    _tts.setCompletionHandler(onDone);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async => _tts.stop();

  // ── STT ──────────────────────────────────────────────────────────────────

  /// Start listening.
  /// [onPartial] fires continuously with interim results.
  /// [onFinal] fires once with the final recognised string.
  /// Automatically stops after [listenDuration].
  Future<void> startListening({
    required void Function(String) onPartial,
    required void Function(String) onFinal,
    Duration listenDuration = const Duration(seconds: 7),
  }) async {
    if (!_sttAvailable || _sttActive) return;
    _sttActive = true;

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          _sttActive = false;
          onFinal(result.recognizedWords);
        } else {
          onPartial(result.recognizedWords);
        }
      },
      listenFor: listenDuration,
      pauseFor: const Duration(seconds: 3),
      localeId: 'hi_IN',
      cancelOnError: true,
    );

    // Safety net: if STT never fires finalResult, call onFinal with whatever
    // partial text we have after listenDuration + a small buffer.
    Future.delayed(listenDuration + const Duration(seconds: 1), () {
      if (_sttActive) {
        _sttActive = false;
        _stt.stop();
        onFinal(_stt.lastRecognizedWords);
      }
    });
  }

  Future<void> stopListening() async {
    if (_sttActive) {
      _sttActive = false;
      await _stt.stop();
    }
  }

  bool get sttAvailable => _sttAvailable;

  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}

// Convenient re-export so callers don't need a dart:ui import
typedef VoidCallback = void Function();