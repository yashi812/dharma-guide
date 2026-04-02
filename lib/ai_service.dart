import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> aiCall(String system, String userMsg, {int tokens = 160}) async {
  try {
    final r = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': tokens,
        'system': system,
        'messages': [
          {'role': 'user', 'content': userMsg}
        ],
      }),
    );
    final d = jsonDecode(r.body);
    return d['content']?[0]?['text'];
  } catch (_) {
    return null;
  }
}
