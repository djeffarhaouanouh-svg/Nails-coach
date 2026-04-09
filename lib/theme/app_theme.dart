import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFF496F9);
  static const Color accent = Color(0xFFD060D8);
  static const Color background = Color(0xFFFFF5F7);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF8E8E9A);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          background: background,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: 'SF Pro Display',
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFFFAD0FC),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: Color(0xFFF496F9));
            }
            return const IconThemeData(color: Color(0xFF8E8E9A));
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF496F9),
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E9A),
            );
          }),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
      );
}
