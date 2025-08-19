import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/ai_provider.dart';
import '../services/file_storage.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) => ChatController(ref));

class ChatController extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  ChatController(this.ref) : super([]) { _load(); }

  static const _file = 'chat_history.json';
  bool _busy = false;
  bool get isBusy => _busy;

  Future<void> _load() async {
    final items = await FileStorage.readItems(_file);
    state = items.map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<void> _persist() async {
    await FileStorage.writeItems(_file, state.map((e) => e.toJson()).toList());
  }

  Future<void> clearHistory() async { state = []; await _persist(); }

  String _id() => DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString();

  Future<String> send(String text, AIProvider provider) async {
    if (_busy || text.trim().isEmpty) return '';
    _busy = true;
    final userMsg = ChatMessage(id: _id(), role: 'user', text: text.trim(), ts: DateTime.now());
    state = [...state, userMsg];
    await _persist();
    final replyText = await provider.reply(history: state);
    final botMsg = ChatMessage(id: _id(), role: 'assistant', text: replyText, ts: DateTime.now());
    state = [...state, botMsg];
    await _persist();
    _busy = false;
    return replyText;
  }

  Future<String> sendStreaming(AIProvider provider, String text, void Function() onStart, void Function(String chunk) onChunk) async {
    if (_busy || text.trim().isEmpty) return '';
    _busy = true;
    onStart();
    final userMsg = ChatMessage(id: _id(), role: 'user', text: text.trim(), ts: DateTime.now());
    state = [...state, userMsg];
    await _persist();

    final id = _id();
    String acc = '';
    state = [...state, ChatMessage(id: id, role: 'assistant', text: '', ts: DateTime.now())];
    await _persist();

    await for (final chunk in provider.replyStream(history: state)) {
      acc += chunk;
      onChunk(chunk);
      final idx = state.lastIndexWhere((m) => m.id == id);
      if (idx >= 0) {
        final updated = ChatMessage(id: id, role: 'assistant', text: acc, ts: state[idx].ts);
        state = [...state]..[idx] = updated;
      }
    }
    await _persist();
    _busy = false;
    return acc;
  }
}
