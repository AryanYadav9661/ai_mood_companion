import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../controllers/chat_controller.dart';
import '../services/ai_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/orb_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  late final OpenAIProvider _provider;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _listening = false;
  String _streamingText = '';
  late final AnimationController _orbCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2500))
    ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _provider = OpenAIProvider();
    _tts.setSpeechRate(0.98);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final ok = await _speech.initialize();
    if (ok) {
      setState(() => _listening = true);
      await _speech.listen(
          onResult: (r) {
            _controller.text = r.recognizedWords;
            if (r.finalResult) setState(() => _listening = false);
          },
          localeId: 'en_IN');
    }
  }

  Future<void> _sendStreaming() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _streamingText = '';
    final notifier = ref.read(chatControllerProvider.notifier);
    await notifier.sendStreaming(_provider, text, () {
      setState(() {});
    }, (chunk) {
      setState(() {
        _streamingText += chunk;
        _tts.speak(chunk);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider);
    final isBusy = ref.read(chatControllerProvider.notifier).isBusy;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  final isUser = m.role == 'user';
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(isUser ? -0.03 : 0.03)
                      ..rotateY(isUser ? 0.02 : -0.02),
                    child: ChatBubble(
                        text: m.text, isUser: isUser, timestamp: m.ts),
                  );
                },
              ),
            ),
            if (isBusy)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    _streamingText.isEmpty ? 'AI is typing…' : _streamingText,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                        onPressed: _toggleListen,
                        icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                        tooltip: 'Voice input'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            hintText: 'Ask anything…',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18)))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                        onPressed: isBusy ? null : _sendStreaming,
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Ask')),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 96,
          child: OrbWidget(
              listening: _listening, speaking: isBusy, controller: _orbCtrl),
        ),
      ],
    );
  }
}
