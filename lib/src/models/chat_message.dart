class ChatMessage {
  final String id;
  final String role;
  final String text;
  final DateTime ts;
  ChatMessage({required this.id, required this.role, required this.text, required this.ts});
  factory ChatMessage.fromJson(Map<String,dynamic> j) => ChatMessage(id: j['id'], role: j['role'], text: j['text'], ts: DateTime.parse(j['ts']));
  Map<String,dynamic> toJson() => {'id': id,'role': role,'text': text,'ts': ts.toIso8601String()};
}
