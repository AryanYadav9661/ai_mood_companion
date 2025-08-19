import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  const ChatBubble({super.key, required this.text, required this.isUser, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(18),
    );

    return Column(crossAxisAlignment: align, children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.95),
          borderRadius: radius,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0,8))],
        ),
        child: Text(text),
      ),
      Padding(padding: const EdgeInsets.only(left:8,right:8), child: Text(timeString(timestamp), style: const TextStyle(fontSize:11, color: Colors.black54)))
    ]);
  }

  String timeString(DateTime t) {
    final local = t.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2,'0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '\$h:\$m \$ampm';
  }
}
