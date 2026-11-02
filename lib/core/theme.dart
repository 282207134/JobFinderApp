import 'package:flutter/material.dart';

abstract final class Palette {
  static const blue = Color(0xFF4BC1F7);
  static const background = Color(0xFFFCFCFE);
  static const ink = Color(0xFF3A3943);
  static const slate = Color(0xFF616E7C);
  static const muted = Color(0xFFC6C5CC);
  static const field = Color(0xFFF4F4F8);
}

ThemeData appTheme({bool dark = false}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: Palette.blue,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: Palette.blue,
    surface: dark ? const Color(0xFF242833) : Colors.white,
    onSurface: dark ? const Color(0xFFF4F4F8) : Palette.ink,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: scheme,
    scaffoldBackgroundColor: dark
        ? const Color(0xFF191D26)
        : Palette.background,
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontSize: 14,
        color: dark ? Colors.white70 : Palette.slate,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: scheme.onSurface),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: dark ? Colors.white : Palette.slate,
      ),
    ),
    splashFactory: InkRipple.splashFactory,
    iconTheme: IconThemeData(color: scheme.onSurface),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Palette.muted,
        disabledForegroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        minimumSize: const Size(double.infinity, 60),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      hintStyle: const TextStyle(color: Palette.muted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Palette.blue,
      thumbColor: Palette.blue,
      trackHeight: 3,
    ),
  );
}
