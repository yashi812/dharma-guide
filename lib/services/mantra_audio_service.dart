// lib/services/mantra_audio_service.dart
//
// Pure male pandit voice — explicitly selects a male hi-IN voice
// from the device's installed TTS voices.
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

  // ── Known male hi-IN voice names across devices/engines ───────────────────
  // Google TTS installs these on most Android devices.
  // We try each in order until one is found on the device.
  static const _maleHindiVoices = [
    'hi-in-x-hid-local',   // Google Hindi male (most common)
    'hi-in-x-hia-local',   // Google Hindi male variant
    'hi_IN_Male',           // Samsung TTS male
    'hi-IN-Wavenet-B',      // Wavenet male (if installed)
    'hi-IN-Wavenet-C',      // Wavenet male variant
    'hi-IN-Standard-B',     // Standard male
    'hi-IN-Standard-C',     // Standard male variant
  ];

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setVolume(1.0);
    await _selectMaleVoice();
    _ready = true;
  }

  /// Scans installed voices and picks the best male hi-IN voice.
  Future<void> _selectMaleVoice() async {
    try {
      final voices = await _tts.getVoices as List?;
      if (voices == null || voices.isEmpty) return;

      debugPrint('MantraAudioService: available voices:');
      for (final v in voices) {
        debugPrint('  → $v');
      }

      // Try preferred male Hindi voices first
      for (final target in _maleHindiVoices) {
        final match = voices.firstWhere(
          (v) {
            final name = (v['name'] as String? ?? '').toLowerCase();
            return name.contains(target.toLowerCase());
          },
          orElse: () => null,
        );
        if (match != null) {
          debugPrint('MantraAudioService: selected voice → ${match['name']}');
          await _tts.setVoice({
            'name': match['name'] as String,
            'locale': match['locale'] as String? ?? 'hi-IN',
          });
          return;
        }
      }

      // Fallback: any male hi-IN voice
      final anyMaleHindi = voices.firstWhere(
        (v) {
          final name   = (v['name']   as String? ?? '').toLowerCase();
          final locale = (v['locale'] as String? ?? '').toLowerCase();
          return locale.contains('hi') &&
              (name.contains('male') || name.contains('-b') || name.contains('-c'));
        },
        orElse: () => null,
      );
      if (anyMaleHindi != null) {
        debugPrint('MantraAudioService: fallback male Hindi → ${anyMaleHindi['name']}');
        await _tts.setVoice({
          'name':   anyMaleHindi['name']   as String,
          'locale': anyMaleHindi['locale'] as String? ?? 'hi-IN',
        });
        return;
      }

      // Last resort: just set language to hi-IN and hope for male default
      debugPrint('MantraAudioService: no male Hindi voice found, using hi-IN default');
      await _tts.setLanguage('hi-IN');
    } catch (e) {
      debugPrint('MantraAudioService._selectMaleVoice error: $e');
      await _tts.setLanguage('hi-IN');
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> playLine({
    required String lineText,
    required String devanagariText,
    String? romanText,
    void Function()? onDone,
  }) async {
    await stopAll();
    await _ensureReady();

    // Clean text — no elongation tricks, pure Devanagari
    final clean = _cleanDevanagari(lineText);

    // Speak with male pandit settings
    final spoke = await _trySpeak(_Strategy(
      lang:  'hi-IN',
      text:  clean,
      rate:  kIsWeb ? 0.45 : 0.36,
      pitch: 1.0,   // neutral pitch — let the male voice be naturally male
    ));

    // Fallback to Roman if Devanagari failed
    if (!spoke) {
      await _trySpeak(_Strategy(
        lang:  'en-IN',
        text:  romanText ?? lineText,
        rate:  kIsWeb ? 0.48 : 0.38,
        pitch: 1.0,
      ));
    }

    onDone?.call();
  }

  Future<void> stopAll() async {
    try { await _tts.stop(); } catch (_) {}
  }

  void dispose() => _tts.stop();

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _cleanDevanagari(String text) {
    return text
        .replaceAll('ओ३म्', 'ॐ')
        .replaceAll('ऽ', '')
        .replaceAll('\u202F', ' ')
        .replaceAll(RegExp(r' +'), ' ')
        .trim();
  }

  Future<bool> _trySpeak(_Strategy s) async {
    try {
      await _tts.setSpeechRate(s.rate);
      await _tts.setPitch(s.pitch);

      final completer = Completer<void>();
      void finish() { if (!completer.isCompleted) completer.complete(); }

      _tts.setCompletionHandler(finish);
      _tts.setCancelHandler(finish);
      _tts.setErrorHandler((msg) {
        debugPrint('MantraAudioService[${s.lang}] error: $msg');
        finish();
      });

      debugPrint('MantraAudioService: speaking → "${s.text}"');
      final result = await _tts.speak(s.text);

      if (result != 1) {
        debugPrint('MantraAudioService: speak() rejected (result=$result)');
        return false;
      }

      await completer.future.timeout(
        const Duration(seconds: 45),
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
  final double pitch;
  const _Strategy({
    required this.lang,
    required this.text,
    required this.rate,
    required this.pitch,
  });
}