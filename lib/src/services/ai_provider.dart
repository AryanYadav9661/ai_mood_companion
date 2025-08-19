import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';

abstract class AIProvider {
  Future<String> reply({required List<ChatMessage> history});
  Stream<String> replyStream({required List<ChatMessage> history});
}

class OpenAIProvider implements AIProvider {
  final Dio _dio = Dio();
  final String baseUrl;
  final String model;
  final String apiKey;

  OpenAIProvider({String? baseUrl, String? model, String? apiKey})
      : baseUrl = baseUrl ?? 'https://api.openai.com/v1/chat/completions',
        model = model ?? (dotenv.maybeGet('OPENAI_MODEL') ?? 'gpt-4o-mini'),
        apiKey = apiKey ?? (dotenv.maybeGet('OPENAI_API_KEY') ?? '');

  List<Map<String,String>> _toMessages(List<ChatMessage> history) =>
      history.take(20).map((m) => {'role': m.role, 'content': m.text}).toList();

  @override
  Future<String> reply({required List<ChatMessage> history}) async {
    if (apiKey.isEmpty) return '⚠️ Missing OPENAI_API_KEY.';
    final body = {'model': model, 'messages': [
      {'role':'system','content':'You are a friendly concise AI companion. Respond helpfully.'},
      ..._toMessages(history)
    ], 'temperature':0.7, 'stream': false};
    try {
      final resp = await _dio.post(baseUrl, data: jsonEncode(body), options: Options(headers: {'Content-Type':'application/json','Authorization':'Bearer \$apiKey'}, receiveTimeout: const Duration(seconds:30)));
      if (resp.statusCode == 200) {
        final data = resp.data is Map<String,dynamic> ? resp.data : jsonDecode(resp.data);
        final choices = data['choices'] as List?;
        return choices != null && choices.isNotEmpty ? (choices[0]['message']['content'] as String).trim() : 'No reply.';
      } else {
        return 'API error: \${resp.statusCode}';
      }
    } catch (e) {
      return 'Network error: \$e';
    }
  }

  @override
  Stream<String> replyStream({required List<ChatMessage> history}) async* {
    if (apiKey.isEmpty) {
      yield '⚠️ Missing OPENAI_API_KEY.';
      return;
    }
    final body = {'model': model, 'messages': [
      {'role':'system','content':'You are a friendly concise AI companion. Respond helpfully.'},
      ..._toMessages(history)
    ], 'temperature':0.7, 'stream': true};

    final resp = await _dio.post(baseUrl, data: jsonEncode(body), options: Options(headers: {'Content-Type':'application/json','Authorization':'Bearer \$apiKey','Accept':'text/event-stream'}, responseType: ResponseType.stream, validateStatus: (s) => s != null && s < 500));
    if (resp.statusCode != 200 || resp.data == null) {
      yield 'API error: \${resp.statusCode}';
      return;
    }
    final stream = resp.data.stream as Stream<List<int>>;
    final transformer = stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in transformer) {
      if (line.startsWith('data: ')) {
        final d = line.substring(6).trim();
        if (d == '[DONE]') break;
        try {
          final j = jsonDecode(d) as Map<String,dynamic>;
          final delta = j['choices'][0]['delta'];
          final piece = (delta?['content'] ?? '') as String;
          if (piece.isNotEmpty) yield piece;
        } catch (_) {}
      }
    }
  }
}
