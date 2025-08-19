import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeStyle { classic, glow }

final themeStyleProvider = StateProvider<ThemeStyle>((ref) => ThemeStyle.glow);

ThemeData themeFor(ThemeStyle style) {
  switch (style) {
    case ThemeStyle.glow:
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: Colors.transparent,
        cardTheme: const CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          elevation: 10,
          shadowColor: Color(0x22000000),
        ),
      );
    case ThemeStyle.classic:
    default:
      return ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        cardTheme: const CardTheme(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))),
      );
  }
}
