import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class StreakConfetti extends StatefulWidget {
  final int streak;
  const StreakConfetti({super.key, required this.streak});
  @override
  State<StreakConfetti> createState() => _StreakConfettiState();
}

class _StreakConfettiState extends State<StreakConfetti> {
  late final ConfettiController controller;
  @override
  void initState() {
    super.initState();
    controller = ConfettiController(duration: const Duration(seconds: 2));
    if ([7,30,100].contains(widget.streak)) controller.play();
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(confettiController: controller, blastDirectionality: BlastDirectionality.explosive, shouldLoop: false, colors: const [Colors.pink, Colors.blue, Colors.orange, Colors.green]);
  }
}
