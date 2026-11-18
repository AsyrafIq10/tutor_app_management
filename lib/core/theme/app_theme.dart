import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E7D5B);
  static const mint = Color(0xFFA8DCC4);
  static const mintSoft = Color(0xFFDDF1E7);
  static const background = Color(0xFFE3EEE6);
  static const surface = Color(0xFFF4F9F5);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1B2B24);
  static const textMuted = Color(0xFF5F7A6C);
  static const error = Color(0xFFB3261E);
  static const warning = Color(0xFF9A5B00);
  static const warningSoft = Color(0xFFFFEFD6);
  static const neutralSoft = Color(0xFFE6EAE8);
}

class AppTheme {
  static const cardRadius = 16.0;

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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
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
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.mint,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card,
        shape: StadiumBorder(),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
