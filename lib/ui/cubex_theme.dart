import 'package:flutter/material.dart';

/// Cubex wooden-toy palette (Stitch "Classic Wood" — original, not Block Crush).
class CubexTheme {
  static const Color cream = Color(0xFFFFF4EC);
  static const Color creamDeep = Color(0xFFF7E4D4);
  static const Color boardFill = Color(0xFFFFE8D6);
  static const Color cellEmpty = Color(0xFFFFF8F1);
  static const Color woodInk = Color(0xFF5A3A28);
  static const Color woodMuted = Color(0xFF9A7B68);
  static const Color peach = Color(0xFFFFB37A);
  static const Color peachDeep = Color(0xFFFF8A3A);
  static const Color playGreen = Color(0xFF3DDC84);
  static const Color playGreenDeep = Color(0xFF1DBF68);
  static const Color hudCream = Color(0xFFFFF1E4);
  static const Color chipOrange = Color(0xFFFF9F4A);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: peachDeep,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cream,
    );
  }
}
