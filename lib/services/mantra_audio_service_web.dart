// lib/services/mantra_audio_service_web.dart
//
// Web stub — selected by the conditional import in mantra_audio_service.dart
// when compiled for the browser.
//
// On web, MantraAudioService uses UrlSource directly, so fetchOrCache
// is never actually called. This stub just satisfies the import so the
// web build compiles without dart:io / path_provider.


/// Never called on web — MantraAudioService uses UrlSource instead.
Future<String> fetchOrCache({
  required String text,
  required String lang,
  required Uri uri,
  required Map<String, String> headers,
  required String cacheKey,
}) async {
  throw UnsupportedError(
    'fetchOrCache is not available on web — use UrlSource directly.',
  );
}