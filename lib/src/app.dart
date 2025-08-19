import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_controller.dart';
import 'screens/chat_screen.dart';
import 'screens/mood_screen.dart';

// Root app with animated background, theme toggle and tilt wrapper
class AIMoodApp extends ConsumerStatefulWidget {
  const AIMoodApp({super.key});
  @override
  ConsumerState<AIMoodApp> createState() => _AIMoodAppState();
}

class _AIMoodAppState extends ConsumerState<AIMoodApp> with TickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = ref.watch(themeStyleProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Mood Chat',
      theme: themeFor(themeStyle),
      home: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (context, _) {
          final t = _bgCtrl.value;
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.8 + 0.6 * math.sin(t * math.pi * 2), -1),
                    end: Alignment(1, 0.8 - 0.6 * math.cos(t * math.pi * 2)),
                    colors: const [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Color(0xFFDDE7FA)],
                  ),
                ),
              ),
              Positioned(
                top: 80 + 10 * math.sin(t * 6.28),
                left: -40,
                child: _GlowBlob(size: 160, color: const Color(0xFFB3C7FF).withOpacity(0.5)),
              ),
              Positioned(
                bottom: 100 + 14 * math.cos(t * 6.28),
                right: -30,
                child: _GlowBlob(size: 200, color: const Color(0xFFA5F3FC).withOpacity(0.45)),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text('AI Mood Chat'),
                  elevation: 0,
                  actions: [
                    IconButton(
                      tooltip: 'Theme',
                      onPressed: () {
                        final next = themeStyle == ThemeStyle.glow ? ThemeStyle.classic : ThemeStyle.glow;
                        ref.read(themeStyleProvider.notifier).state = next;
                      },
                      icon: Icon(themeStyle == ThemeStyle.glow ? Icons.light_mode : Icons.blur_on),
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        showModalBottomSheet(context: context, builder: (_) => const SettingsSheet());
                      },
                    ),
                  ],
                ),
                body: _TiltWrapper(
                  child: IndexedStack(
                    index: _index,
                    children: const [
                      ChatScreen(),
                      MoodScreen(),
                    ],
                  ),
                ),
                bottomNavigationBar: NavigationBar(
                  elevation: 0,
                  backgroundColor: Colors.white.withOpacity(0.75),
                  selectedIndex: _index,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
                    NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Mood'),
                  ],
                  onDestinationSelected: (i) => setState(() => _index = i),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size; final Color color;
  const _GlowBlob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 80, spreadRadius: 30)],
      ),
    );
  }
}

class _TiltWrapper extends StatefulWidget {
  final Widget child;
  const _TiltWrapper({required this.child});
  @override
  State<_TiltWrapper> createState() => _TiltWrapperState();
}

class _TiltWrapperState extends State<_TiltWrapper> {
  double _dx = 0, _dy = 0;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (e) {
        setState(() {
          _dx = (e.position.dx / MediaQuery.of(context).size.width - 0.5) * 0.06;
          _dy = (e.position.dy / MediaQuery.of(context).size.height - 0.5) * 0.06;
        });
      },
      onPointerUp: (_) => setState(() { _dx = 0; _dy = 0; }),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_dy)
          ..rotateY(-_dx),
        alignment: FractionalOffset.center,
        child: widget.child,
      ),
    );
  }
}
