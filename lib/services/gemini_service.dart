// lib/services/gemini_service.dart
// ─────────────────────────────────────────────────────────────
// DHARMA GUIDE — Gemini Service (via Supabase Edge Function)
// ─────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const _kSupabaseUrl = 'https://bklyszfnaebbpkxlmilw.supabase.co';
const _kAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrbHlzemZuYWViYnBreGxtaWx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTI5MDQsImV4cCI6MjA5MTAyODkwNH0.z14EBElS6PeTZQOHkoVLYdPebjIUigRLeHdd4X6bI2I';

/// Returns the best available auth token:
/// - logged-in user's JWT, or
/// - anon key as fallback (for anonymous sessions)
String _authToken() {
  final session = Supabase.instance.client.auth.currentSession;
  return session?.accessToken ?? _kAnonKey;
}

Future<Map<String, dynamic>?> _invokeFunction(
  String functionName,
  Map<String, dynamic> body,
) async {
  final url = Uri.parse('$_kSupabaseUrl/functions/v1/$functionName');
  try {
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_authToken()}',
            'apikey': _kAnonKey,
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 35));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    debugPrint('[Gemini] HTTP ${response.statusCode}: ${response.body}');
    return null;
  } catch (e) {
    debugPrint('[Gemini] invoke error: $e');
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// GENERIC CALL — drop-in replacement for old aiCall()
// Used for kundli profile generation in home_screen
// ─────────────────────────────────────────────────────────────
Future<String?> aiCall(
  String systemPrompt,
  String userMessage, {
  int tokens = 1000,
}) async {
  final data = await _invokeFunction('dharmic-guidance', {
    'systemPrompt': systemPrompt,
    'userMessage': userMessage,
    'tokens': tokens,
  });
  final text = data?['text'] as String?;
  debugPrint('[Gemini] aiCall OK — ${text?.length ?? 0} chars');
  return text?.trim();
}

// ─────────────────────────────────────────────────────────────
// GUIDANCE CALL — multi-turn dharmic conversation
// ─────────────────────────────────────────────────────────────
Future<String> getGuidanceResponse({
  required String userMessage,
  List<Map<String, String>> history = const [],
  String? kundliData,
  String? topicLabel,
}) async {
  final body = <String, dynamic>{
    'userMessage': userMessage,
    'history': history,
    if (kundliData != null && kundliData.isNotEmpty) 'kundliData': kundliData,
    if (topicLabel != null) 'topicLabel': topicLabel,
  };

  final data = await _invokeFunction('dharmic-guidance', body);
  final text = data?['text'] as String?;

  if (text != null && text.trim().isNotEmpty) {
    debugPrint('[Gemini] guidance OK — ${text.length} chars');
    return text.trim();
  }
  return _fallback();
}

String _fallback() =>
    'Something interrupted our conversation — perhaps even silence has its '
    'wisdom. Take a breath, and share again when you are ready. I am here.';