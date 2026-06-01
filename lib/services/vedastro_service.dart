import 'dart:convert';
import 'package:http/http.dart' as http;

/// Categories we care about for spiritual / life-path guidance.
/// We deliberately exclude pure MedicalAstrology tags so we never
/// surface health-scare predictions to the user.
const _kUsefulTags = {
  'Personality', 'General', 'Career', 'Finance', 'Relationships',
  'Marriage', 'Family', 'Education', 'Spirituality', 'Travel',
  'Luck', 'Character', 'Health', 'Mind', 'Intelligence',
};

/// Terms in prediction names that we always skip (sensitive / irrelevant).
const _kBlockList = {
  'Deformity', 'Disease', 'Evil', 'Poison', 'Punishment',
  'Imprisonment', 'Death', 'Accident',
};

class VedAstroService {

  // ── Raw prediction fetch (kept for backwards compat) ───────────────────────
  static Future<Map<String, dynamic>> generateKundli({
    required String location,
    required String time,
    required String date,
  }) async {
    return _fetchPredictions(location: location, time: time, date: date);
  }

  // ── Rich, filtered predictions grouped by life domain ─────────────────────
  /// Returns a human-readable multi-line summary of the user's Kundli,
  /// filtered to life-path relevant predictions and grouped by domain.
  /// Safe to pass directly to an LLM.
  ///
  /// [date]     DD/MM/YYYY  (slashes are intentional — they become URL path separators)
  /// [time]     HH:MM       (24-hour)
  /// [location] City name, e.g. "Mumbai"
  static Future<String> getRichPredictions({
    required String location,
    required String time,
    required String date,
    int maxPerCategory = 4,
    String timezone = '+05:30',
  }) async {
    try {
      final data = await _fetchPredictions(
          location: location, time: time, date: date, timezone: timezone);

      final payload = data['Payload'];
      if (payload == null || payload is! List || payload.isEmpty) {
        return '';
      }

      // Filter & group by first relevant tag
      final Map<String, List<String>> grouped = {};
      for (final item in payload) {
        // Skip low-confidence / unactivated yogas
        final weight = (item['Weight'] as num?)?.toDouble() ?? 0.0;
        if (weight < 0) continue;

        // Skip blocklisted prediction names
        final name = (item['Name'] as String? ?? '');
        if (_kBlockList.any((b) => name.contains(b))) continue;

        final tags = (item['Tags'] as List?)?.cast<String>() ?? <String>[];
        final desc = (item['Description'] as String? ?? '').trim();
        if (desc.isEmpty || desc.length < 20) continue;

        // Find first matching useful tag
        String? bucket;
        for (final t in tags) {
          if (_kUsefulTags.contains(t)) { bucket = t; break; }
        }
        bucket ??= 'General';

        // Cap per category to avoid token bloat
        final list = grouped.putIfAbsent(bucket, () => []);
        if (list.length < maxPerCategory) list.add(desc);
      }

      if (grouped.isEmpty) return '';

      // Format as readable text block
      final buffer = StringBuffer();
      for (final entry in grouped.entries) {
        buffer.writeln('[${entry.key}]');
        for (final d in entry.value) {
          buffer.writeln('- $d');
        }
      }
      return buffer.toString().trim();
    } catch (e) {
      return '';
    }
  }

  // ── Internal HTTP helper ───────────────────────────────────────────────────
  /// IMPORTANT: [date] must be in DD/MM/YYYY format.
  /// The slashes are kept intentionally — the VedAstro REST API uses them
  /// as path-segment separators (not query params), so DD/MM/YYYY becomes
  /// three segments: /DD/MM/YYYY/ in the URL path.
  static Future<Map<String, dynamic>> _fetchPredictions({
    required String location,
    required String time,
    required String date,
    String timezone = '+05:30',
  }) async {
    final encLocation = Uri.encodeComponent(location);

    // Normalise date to DD/MM/YYYY (accept both DD/MM/YYYY and DD-MM-YYYY input)
    final normDate = date.replaceAll('-', '/');

    // Encode timezone: '+05:30' → '%2B05:30' (only encode the + sign)
    final encTz = timezone.replaceAll('+', '%2B');

    final urlStr =
      'https://api.vedastro.org/api/'
      'Calculate/HoroscopePredictions/'
      'Location/$encLocation/'
      'Time/$time/'
      '$normDate/'  // DD/MM/YYYY — slashes become path separators
      '$encTz/'
      'Ayanamsa/RAMAN';

    final url = Uri.parse(urlStr);

    final response = await http.get(url).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('VedAstro ${response.statusCode}: ${response.body}');
    }
  }
}