import 'package:flutter/material.dart';

class AppColors {
  // Brand palette
  static const navy = Color(0xFF123C73);
  static const blue = Color(0xFF1689E8);
  static const lightBlue = Color(0xFF63B8F5);
  static const ink = Color(0xFF102A43);
  static const background = Color(0xFFF5F8FC);
  static const surface = Colors.white;

  // Dark palette
  static const darkBackground = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF16213A);
  static const darkCard = Color(0xFF1B2842);
  static const darkInk = Color(0xFFE6EDF7);
  static const darkBorder = Color(0xFF2A3A5C);
}

class AppTheme {
  /// Builds the shared theme pieces (appbar, cards, inputs, typography)
  /// for a given [ColorScheme] / brightness.
  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color border,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary:
          brightness == Brightness.light ? AppColors.navy : AppColors.lightBlue,
      secondary: AppColors.blue,
      surface: surface,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Arial',
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor:
            brightness == Brightness.light ? AppColors.ink : AppColors.darkInk,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border.withValues(alpha: .5),
      ),
    );
  }

  /// Light theme — the default.
  static ThemeData get light => _base(
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        border: Colors.grey.shade200,
      );

  /// Dark theme — full Soultech-compatible dark palette.
  static ThemeData get dark => _base(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkCard,
        border: AppColors.darkBorder,
      );
}
