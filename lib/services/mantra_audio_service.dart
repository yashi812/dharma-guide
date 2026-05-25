// lib/services/mantra_audio_service.dart
//
// Speaks mantra lines correctly for ALL mantras by trying multiple voices:
//
//   1. hi-IN  with Devanagari text  (best for Gayatri, most Vedic mantras)
//   2. en-IN  with Roman text       (best for Om Namah Shivaya, Hare Krishna etc.)
//   3. en-US  with Roman text       (universal fallback)
//
// Call playLine() with BOTH texts — the service picks what sounds best.
//
// pubspec.yaml:
//   flutter_tts: ^4.0.2

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MantraAudioService {
  MantraAudioService._();
  static final instance = MantraAudioService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.88);
    _ready = true;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Speak a mantra line then call [onDone].
  ///
  /// [lineText]      — mantra.lines[i]  (Devanagari, e.g. "ॐ नमः शिवाय")
  /// [romanText]     — mantra.tr[i]     (Roman,      e.g. "Om namah shivaya")
  ///
  /// The service tries hi-IN + Devanagari first, then en-IN + Roman.
  /// Pass both so every mantra sounds correct.
  Future<void> playLine({
    required String lineText,   // Devanagari
    String? romanText,          // Roman transliteration — used as fallback voice
    void Function()? onDone, required String devanagariText,
  }) async {
    await stopAll();
    await _ensureReady();

    // Try each voice strategy in order until one succeeds
    final strategies = [
      _Strategy(lang: 'hi-IN', text: lineText,              rate: kIsWeb ? 0.50 : 0.38),
      _Strategy(lang: 'en-IN', text: romanText ?? lineText, rate: kIsWeb ? 0.52 : 0.40),
      _Strategy(lang: 'en-US', text: romanText ?? lineText, rate: kIsWeb ? 0.55 : 0.42),
    ];

    for (final s in strategies) {
      final ok = await _trySpeak(s);
      if (ok) break;
    }

    onDone?.call();
  }

  Future<void> stopAll() async {
    try { await _tts.stop(); } catch (_) {}
  }

  void dispose() => _tts.stop();

  // ── Private ────────────────────────────────────────────────────────────────

  /// Attempts to speak [s.text] with [s.lang].
  /// Returns true if speech completed (or timed out naturally).
  /// Returns false if TTS rejected the call immediately.
  Future<bool> _trySpeak(_Strategy s) async {
    try {
      await _tts.setLanguage(s.lang);
      await _tts.setSpeechRate(s.rate);

      final completer = Completer<void>();
      void finish() { if (!completer.isCompleted) completer.complete(); }

      _tts.setCompletionHandler(finish);
      _tts.setCancelHandler(finish);
      _tts.setErrorHandler((msg) {
        debugPrint('MantraAudioService[${s.lang}] error: $msg');
        finish();
      });

      debugPrint('MantraAudioService: trying ${s.lang} → "${s.text}"');
      final result = await _tts.speak(s.text);

      if (result != 1) {
        debugPrint('MantraAudioService: ${s.lang} rejected (result=$result)');
        return false;
      }

      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: finish,
      );
      return true;
    } catch (e) {
      debugPrint('MantraAudioService._trySpeak error: $e');
      return false;
    }
  }
}

class _Strategy {
  final String lang;
  final String text;
  final double rate;
  const _Strategy({required this.lang, required this.text, required this.rate});
}