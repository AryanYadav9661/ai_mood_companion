import 'dart:math' as math;
import 'package:flutter/material.dart';

class OrbWidget extends StatelessWidget {
  final bool listening;
  final bool speaking;
  final AnimationController controller;
  const OrbWidget({super.key, required this.listening, required this.speaking, required this.controller});

  @override
  Widget build(BuildContext context) {
    final beat = Tween<double>(begin: 0.96, end: 1.06).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    return AnimatedBuilder(animation: controller, builder: (context, _) {
      return Transform(transform: Matrix4.identity()..setEntry(3,2,0.002)..rotateX(0.05*math.sin(controller.value*6.28))..rotateY(0.06*math.cos(controller.value*6.28))..scale(beat.value), alignment: Alignment.center, child:
        Container(width:64,height:64, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [listening?const Color(0xFFA7F3D0):(speaking?const Color(0xFF93C5FD):const Color(0xFFE5E7EB)), Colors.white]), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius:18, offset: Offset(0,6)), BoxShadow(color: Color(0x22000000), blurRadius:40, spreadRadius:10)], ), child: Icon(listening?Icons.hearing:(speaking?Icons.waves:Icons.bubble_chart), color: Colors.black54),)
      );
    });
  }
}
