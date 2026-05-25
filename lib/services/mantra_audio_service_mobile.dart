// lib/services/mantra_audio_service_mobile.dart
//
// Mobile (Android / iOS) implementation.
// Downloads the gTTS mp3 and caches it so subsequent plays work offline.
//
// This file is selected by the conditional import in mantra_audio_service.dart
// on all non-web platforms.

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads the Google Translate TTS audio for [text]/[lang] and caches it.
/// Returns the local file path of the cached mp3.
/// Throws if the download fails.
Future<String> fetchOrCache({
  required String text,
  required String lang,
  required Uri uri,
  required Map<String, String> headers,
  required String cacheKey,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/mantra_${lang}_$cacheKey.mp3');

  // Return cached file if it looks valid
  if (await file.exists() && await file.length() > 1000) {
    return file.path;
  }

  final response = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 18));

  if (response.statusCode == 200 && response.bodyBytes.length > 1000) {
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  // Delete any partial/corrupt file
  if (await file.exists()) await file.delete();

  throw Exception(
    'gTTS[$lang] HTTP ${response.statusCode}, '
    'size: ${response.bodyBytes.length}',
  );
}