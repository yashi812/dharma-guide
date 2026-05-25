import 'dart:convert';
import 'package:http/http.dart' as http;

const _kOpenAiKey = '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'; // ← paste your real key

Future<String?> aiCall(String system, String userMsg, {int tokens = 160}) async {
  try {
    final r = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_kOpenAiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'max_tokens': tokens,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': userMsg},
        ],
      }),
    );
    print('STATUS: ${r.statusCode}');
    print('BODY: ${r.body}');
    final d = jsonDecode(r.body);
    return d['choices']?[0]?['message']?['content'];
  } catch (e) {
    print('aiCall ERROR: $e');
    return null;
  }
}