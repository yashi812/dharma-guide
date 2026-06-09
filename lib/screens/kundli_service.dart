// ─────────────────────────────────────────────────────────────────────────────
// kundli_service.dart
//
// Changes from previous version:
//   • Removed Supabase edge-function call entirely — no more 'generate-kundli'
//   • KundliService.generateKundli() now calls VedAstro directly via http,
//     mirroring the three parallel fetches the edge function was doing:
//       AllPlanetData, AllHouseData, HoroscopePredictions
//   • VedAstroService.getRichPredictions() is used for predictions (already
//     handles filtering / grouping / blocklist).
//   • Geocoding (city → lat/lng) added via Open-Meteo — same free API the
//     edge function used — so AllPlanetData / AllHouseData get a real
//     lat,lng path instead of a raw city string.
//   • All models (KundliData, PlanetData, HouseData) are unchanged so
//     guidance_screen.dart needs zero edits.
//   • _anonKey and SupabaseClient import removed (no longer needed here).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dharma_guide/services/vedastro_service.dart';   // existing file — unchanged

// ═══════════════════════════════════════════════════════════════════════════════
// MODELS  (identical to previous version — no changes)
// ═══════════════════════════════════════════════════════════════════════════════

class PlanetData {
  final String name;
  final String rashi;
  final String degree;
  final int house;
  final bool isRetrograde;
  final String nakshatra;
  final int nakshatraPada;
  final String longitude;

  const PlanetData({
    required this.name,
    required this.rashi,
    required this.degree,
    required this.house,
    required this.isRetrograde,
    required this.nakshatra,
    required this.nakshatraPada,
    required this.longitude,
  });

  factory PlanetData.fromJson(Map<String, dynamic> j) => PlanetData(
        name:          j['name']          as String? ?? '',
        rashi:         j['rashi']         as String? ?? '',
        degree:        j['degree']        as String? ?? '0.00',
        house:         j['house']         as int?    ?? 0,
        isRetrograde:  j['isRetrograde']  as bool?   ?? false,
        nakshatra:     j['nakshatra']     as String? ?? '',
        nakshatraPada: j['nakshatraPada'] as int?    ?? 0,
        longitude:     j['longitude']     as String? ?? '0.0000',
      );
}

class HouseData {
  final int number;
  final String rashi;
  final String degree;
  final String lord;

  const HouseData({
    required this.number,
    required this.rashi,
    required this.degree,
    required this.lord,
  });

  factory HouseData.fromJson(Map<String, dynamic> j) => HouseData(
        number: j['number'] as int?    ?? 0,
        rashi:  j['rashi']  as String? ?? '',
        degree: j['degree'] as String? ?? '0.00',
        lord:   j['lord']   as String? ?? '',
      );
}

class KundliData {
  final String name;
  final String date;
  final String time;
  final String location;
  final String timezone;
  final String lagna;
  final String rashi;
  final String nakshatra;
  final int nakshatraPada;
  final List<PlanetData> planets;
  final List<HouseData> houses;
  final Map<String, List<String>> predictions;
  final DateTime generatedAt;

  const KundliData({
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.timezone,
    required this.lagna,
    required this.rashi,
    required this.nakshatra,
    required this.nakshatraPada,
    required this.planets,
    required this.houses,
    required this.predictions,
    required this.generatedAt,
  });

  factory KundliData.fromJson(Map<String, dynamic> j) {
    final rawPlanets = j['planets'] as List<dynamic>? ?? [];
    final rawHouses  = j['houses']  as List<dynamic>? ?? [];
    final rawPreds   = j['predictions'] as Map<String, dynamic>? ?? {};

    return KundliData(
      name:          j['name']          as String? ?? '',
      date:          j['date']          as String? ?? '',
      time:          j['time']          as String? ?? '',
      location:      j['location']      as String? ?? '',
      timezone:      j['timezone']      as String? ?? '+05:30',
      lagna:         j['lagna']         as String? ?? '',
      rashi:         j['rashi']         as String? ?? '',
      nakshatra:     j['nakshatra']     as String? ?? '',
      nakshatraPada: j['nakshatraPada'] as int?    ?? 0,
      planets: rawPlanets
          .map((p) => PlanetData.fromJson(p as Map<String, dynamic>))
          .toList(),
      houses: rawHouses
          .map((h) => HouseData.fromJson(h as Map<String, dynamic>))
          .toList(),
      predictions: rawPreds.map((k, v) => MapEntry(
            k,
            (v as List<dynamic>).map((s) => s as String).toList(),
          )),
      generatedAt: DateTime.tryParse(j['generatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name':          name,
        'date':          date,
        'time':          time,
        'location':      location,
        'timezone':      timezone,
        'lagna':         lagna,
        'rashi':         rashi,
        'nakshatra':     nakshatra,
        'nakshatraPada': nakshatraPada,
        'planets': planets.map((p) => {
              'name':          p.name,
              'rashi':         p.rashi,
              'degree':        p.degree,
              'house':         p.house,
              'isRetrograde':  p.isRetrograde,
              'nakshatra':     p.nakshatra,
              'nakshatraPada': p.nakshatraPada,
            }).toList(),
        'houses': houses.map((h) => {
              'number': h.number,
              'rashi':  h.rashi,
              'lord':   h.lord,
            }).toList(),
        'predictions': predictions,
        'generatedAt': generatedAt.toIso8601String(),
      };

  String toContextString() {
    final sb = StringBuffer();
    sb.writeln('[Birth Chart for $name | $date $time | $location]');
    sb.writeln('Lagna: $lagna | Rashi: $rashi | Nakshatra: $nakshatra Pada $nakshatraPada');
    sb.writeln('');
    sb.writeln('Planetary Positions:');
    for (final p in planets) {
      sb.write('  ${p.name}: ${p.rashi} (House ${p.house})');
      if (p.isRetrograde) sb.write(' [R]');
      if (p.nakshatra.isNotEmpty) sb.write(' · ${p.nakshatra}');
      sb.writeln();
    }
    if (predictions.isNotEmpty) {
      sb.writeln('');
      sb.writeln('Key Indications:');
      for (final entry in predictions.entries.take(4)) {
        sb.writeln('[${entry.key}]');
        for (final d in entry.value.take(2)) {
          sb.writeln('  - $d');
        }
      }
    }
    return sb.toString().trim();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INTERNAL HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

const _kVedAstroBase = 'https://api.vedastro.org/api';

const _kPlanetOrder = [
  'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus',
  'Saturn', 'Rahu', 'Ketu', 'Ascendant',
];

// ── Geocode city → lat,lng (Open-Meteo, free, no key) ─────────────────────────
Future<({double lat, double lng, String resolvedName})> _geocodeCity(
    String city) async {
  final uri = Uri.parse(
    'https://geocoding-api.open-meteo.com/v1/search'
    '?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
  );
  final res = await http.get(uri).timeout(const Duration(seconds: 10));
  if (res.statusCode != 200) {
    throw Exception('Geocoding failed: ${res.statusCode}');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  final results = data['results'] as List<dynamic>?;
  if (results == null || results.isEmpty) {
    throw Exception('City not found: "$city". Try a larger nearby city.');
  }
  final r = results.first as Map<String, dynamic>;
  return (
    lat: (r['latitude'] as num).toDouble(),
    lng: (r['longitude'] as num).toDouble(),
    resolvedName: '${r['name']}, ${r['country']}',
  );
}

List<dynamic> _toList(dynamic p) {
  if (p == null) return [];
  if (p is List) return p;
  if (p is Map) return p.values.toList();
  return [];
}
// ── Build the shared time-path segment used by both AllPlanetData and AllHouseData
// Input date: DD/MM/YYYY (KundliSheet format)
// VedAstro expects: Location/LAT,LNG/Time/HH:MM/DD-MM-YYYY/TZ/Ayanamsa/RAMAN
String _buildTimePath({
  required double lat,
  required double lng,
  required String time,      // HH:MM
  required String date,      // DD/MM/YYYY
  required String timezone,  // +05:30
}) {
  // DD/MM/YYYY → DD-MM-YYYY (just swap separator, no digit reordering)
  final dashDate = date.replaceAll('/', '-');
  final encTz = timezone.replaceAll('+', '%2B');
  return 'Location/$lat,$lng/Time/$time/$dashDate/$encTz/Ayanamsa/RAMAN';
}

// ── GET with timeout ───────────────────────────────────────────────────────────
Future<Map<String, dynamic>> _vedAstroGet(String path) async {
  final uri = Uri.parse('$_kVedAstroBase/$path');
  final res = await http.get(uri).timeout(const Duration(seconds: 40));
  final body = res.body;
  if (res.statusCode != 200 || body.trimLeft().startsWith('<')) {
    throw Exception('VedAstro ${res.statusCode}: ${body.substring(0, body.length.clamp(0, 300))}');
  }
  return jsonDecode(body) as Map<String, dynamic>;
}

// ── Fetch and parse one planet at a time ─────────────────────────────────────
Future<PlanetData?> _fetchOnePlanet(String planetName, String timePath) async {
  try {
    final data = await _vedAstroGet(
      'Calculate/AllPlanetData/PlanetName/$planetName/$timePath',
    );
    final p = data['Payload']?['AllPlanetData'] as Map<String, dynamic>?;
    if (p == null) return null;

    final rasiSign = p['PlanetRasiD1Sign'] as Map<String, dynamic>?;
    final rashi = rasiSign?['Name'] as String? ?? '';

    final degMap = rasiSign?['DegreesIn'] as Map<String, dynamic>?;
    final degreeRaw = degMap?['TotalDegrees'];
    final degree = degreeRaw != null
        ? double.tryParse(degreeRaw.toString())?.toStringAsFixed(2) ?? '0.00'
        : '0.00';

    final houseStr = p['HousePlanetOccupiesBasedOnSign'] as String? ?? 'House0';
    final house = int.tryParse(houseStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final retro = p['IsPlanetRetrograde'];
    final isRetrograde = retro is bool ? retro : retro?.toString() == 'True';

    final constStr = p['PlanetConstellation'] as String? ?? '';
    final conParts = constStr.split(' - ');
    final nakshatra = conParts.isNotEmpty ? conParts[0].trim() : '';
    final pada = conParts.length > 1 ? int.tryParse(conParts[1].trim()) ?? 0 : 0;

    final longMap = p['PlanetNirayanaLongitude'] as Map<String, dynamic>?;
    final longRaw = longMap?['TotalDegrees'];
    final longitude = longRaw != null
        ? double.tryParse(longRaw.toString())?.toStringAsFixed(4) ?? '0.0000'
        : '0.0000';

    return PlanetData(
      name: planetName,
      rashi: rashi,
      degree: degree,
      house: house,
      isRetrograde: isRetrograde,
      nakshatra: nakshatra,
      nakshatraPada: pada,
      longitude: longitude,
    );
  } catch (e) {
    debugPrint('Planet fetch error ($planetName): $e');
    return null;
  }
}

// ── Parse AllHouseData payload ────────────────────────────────────────────────
List<HouseData> _parseHouses(List<dynamic> payload) {
  return payload
      .map((item) {
        final h = item as Map<String, dynamic>;
        final houseNum = ((h['HouseNumber'] ?? h['Number'] ?? 0) as num).toInt();
        if (houseNum == 0) return null;
        return HouseData(
          number: houseNum,
          rashi:  h['Rashi']   as String? ?? h['Sign']          as String? ?? '',
          degree: ((h['Degrees'] ?? h['DegreesInSign'] ?? 0) as num).toStringAsFixed(2),
          lord:   h['Lord']    as String? ?? '',
        );
      })
      .whereType<HouseData>()
      .toList()
    ..sort((a, b) => a.number.compareTo(b.number));
}

// ── Extract lagna/rashi/nakshatra from planet list ────────────────────────────
({String lagna, String rashi, String nakshatra, int nakshatraPada})
    _extractKeyPoints(List<PlanetData> planets) {
  final asc  = planets.firstWhere((p) => p.name == 'Ascendant',
      orElse: () => const PlanetData(
          name: '', rashi: '', degree: '', house: 0,
          isRetrograde: false, nakshatra: '', nakshatraPada: 0, longitude: ''));
  final moon = planets.firstWhere((p) => p.name == 'Moon',
      orElse: () => const PlanetData(
          name: '', rashi: '', degree: '', house: 0,
          isRetrograde: false, nakshatra: '', nakshatraPada: 0, longitude: ''));
  return (
    lagna:         asc.rashi,
    rashi:         moon.rashi,
    nakshatra:     moon.nakshatra,
    nakshatraPada: moon.nakshatraPada,
  );
}

// ── Parse grouped predictions from getRichPredictions text → Map ──────────────
// VedAstroService.getRichPredictions already returns a formatted string.
// We re-parse it into Map<String,List<String>> so KundliData stays strongly typed.
Map<String, List<String>> _parseRichPredictions(String richText) {
  final result = <String, List<String>>{};
  if (richText.isEmpty) return result;
  String? currentBucket;
  for (final line in richText.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      currentBucket = trimmed.substring(1, trimmed.length - 1);
      result.putIfAbsent(currentBucket, () => []);
    } else if (trimmed.startsWith('- ') && currentBucket != null) {
      result[currentBucket]!.add(trimmed.substring(2));
    }
  }
  return result;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SERVICE
// ═══════════════════════════════════════════════════════════════════════════════

class KundliService {
  /// Generates a full Kundli by calling VedAstro directly from the client.
  /// No Supabase edge function involved.
  ///
  /// [date]     DD/MM/YYYY  (KundliSheet format)
  /// [time]     HH:MM       (24-hour)
  /// [location] City name — geocoded to lat/lng via Open-Meteo
  static Future<KundliData> generateKundli({
  required String name,
  required String date,
  required String time,
  required String location,
  String timezone = '+05:30',
}) async {
  // ── Step 1: Geocode ────────────────────────────────────────────────────────
  final geo = await _geocodeCity(location);
  final timePath = _buildTimePath(
    lat: geo.lat,
    lng: geo.lng,
    time: time,
    date: date,
    timezone: timezone,
  );

  // ── Step 2: Fetch planets individually + houses + predictions ──────────────
  const planetNames = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter',
    'Venus', 'Saturn', 'Rahu', 'Ketu', 'Ascendant',
  ];

  final allResults = await Future.wait([
    ...planetNames.map((n) => _fetchOnePlanet(n, timePath)),
    _vedAstroGet('Calculate/AllHouseData/$timePath')
        .catchError((_) => <String, dynamic>{}),
    VedAstroService.getRichPredictions(
      location: location,
      time: time,
      date: date,
      timezone: timezone,
    ).catchError((_) => ''),
  ]);

  // ── Step 3: Parse ──────────────────────────────────────────────────────────
  final planets = allResults
      .sublist(0, planetNames.length)
      .whereType<PlanetData>()
      .toList();

  if (planets.isEmpty) {
    throw Exception(
      'Could not fetch planetary data from VedAstro. '
      'Check the date/time/location and try again.',
    );
  }

  final housePayload = _toList(
    (allResults[planetNames.length] as Map<String, dynamic>)['Payload'],
  );
  final richText = allResults[planetNames.length + 1] as String;

  final houses      = _parseHouses(housePayload);
  final predictions = _parseRichPredictions(richText);
  final kp          = _extractKeyPoints(planets);

  return KundliData(
    name:          name,
    date:          date,
    time:          time,
    location:      geo.resolvedName,
    timezone:      timezone,
    lagna:         kp.lagna,
    rashi:         kp.rashi,
    nakshatra:     kp.nakshatra,
    nakshatraPada: kp.nakshatraPada,
    planets:       planets,
    houses:        houses,
    predictions:   predictions,
    generatedAt:   DateTime.now(),
  );
}
}