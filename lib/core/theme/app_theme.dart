import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E7D5B);
  static const mint = Color(0xFFA8DCC4);
  static const background = Color(0xFFE3EEE6);
  static const surface = Color(0xFFF4F9F5);
  static const textDark = Color(0xFF1B2B24);
  static const textMuted = Color(0xFF5F7A6C);
  static const error = Color(0xFFB3261E);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    );
    OutlineInputBorder border(Color color, [double width = 0]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: width == 0
              ? BorderSide.none
              : BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(AppColors.primary, 1.5),
        errorBorder: border(AppColors.error, 1.5),
        focusedErrorBorder: border(AppColors.error, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}