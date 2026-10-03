import 'package:flutter/material.dart';

abstract final class HerlyTokens {
  static const rose = Color(0xFFD6336C);
  static const plum = Color(0xFF4A1D3C);
  static const ivory = Color(0xFFFFF9F5);
  static const lavender = Color(0xFFA78BFA);
  static const peach = Color(0xFFFDBA74);
  static const mint = Color(0xFF80B9A5);
  static const gap = 16.0;
  static const radius = 24.0;
  static const motion = Duration(milliseconds: 280);
  static ThemeData theme(Brightness brightness, Color accent) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: dark ? Color.lerp(accent, Colors.white, .3) : accent,
          surface: dark ? const Color(0xFF241D28) : ivory,
          onSurface: dark ? const Color(0xFFF9EDF4) : const Color(0xFF302537),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Manrope',
      fontFamilyFallback: const ['NotoSansSinhala', 'NotoSansTamil'],
      scaffoldBackgroundColor: scheme.surface,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          letterSpacing: -.8,
        ),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, height: 1.55),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: .45),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF322A37) : Colors.white,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: .5),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Manrope',
            fontFamilyFallback: const ['NotoSansSinhala', 'NotoSansTamil'],
            fontSize: 10,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
