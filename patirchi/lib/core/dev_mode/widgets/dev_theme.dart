import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/models/log_entry.dart';

/// DevMode debugger uchun professional qorong'i tema.
///
/// Barcha debugger widgetlari shu renklar va stillardan foydalanishi shart.
class DevTheme {
  DevTheme._();

  // ---------------------------------------------------------------------------
  // Fon ranglari
  // ---------------------------------------------------------------------------

  static const Color bgPrimary = Color(0xFF0A0A0F);
  static const Color bgSecondary = Color(0xFF111118);
  static const Color bgTertiary = Color(0xFF18181F);
  static const Color bgCard = Color(0xFF1E1E28);

  // ---------------------------------------------------------------------------
  // Chegara
  // ---------------------------------------------------------------------------

  static const Color borderSubtle = Color(0xFF2A2A35);

  // ---------------------------------------------------------------------------
  // Matn ranglari
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFAAABBA);
  static const Color textTertiary = Color(0xFF6B6C7E);

  // ---------------------------------------------------------------------------
  // Aksent ranglari
  // ---------------------------------------------------------------------------

  static const Color accent = Color(0xFF7C9EFF);
  static const Color accentDim = Color(0xFF3D5ACC);

  // ---------------------------------------------------------------------------
  // Holat ranglari
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // ---------------------------------------------------------------------------
  // HTTP method ranglari
  // ---------------------------------------------------------------------------

  static Color methodColor(String method) => switch (method.toUpperCase()) {
        'GET' => const Color(0xFF4CAF82),
        'POST' => const Color(0xFF42A5F5),
        'PUT' => const Color(0xFFFFB74D),
        'DELETE' => const Color(0xFFEF5350),
        'PATCH' => const Color(0xFFCE93D8),
        _ => const Color(0xFF9E9E9E),
      };

  /// Method uchun background rangi (ochroq).
  static Color methodBgColor(String method) => switch (method.toUpperCase()) {
        'GET' => const Color(0xFF1A3028),
        'POST' => const Color(0xFF162035),
        'PUT' => const Color(0xFF2E2010),
        'DELETE' => const Color(0xFF2E1010),
        'PATCH' => const Color(0xFF261830),
        _ => const Color(0xFF202020),
      };

  // ---------------------------------------------------------------------------
  // HTTP status ranglari
  // ---------------------------------------------------------------------------

  static Color statusColor(int? code) {
    if (code == null) return const Color(0xFF9E9E9E);
    if (code >= 200 && code < 300) return const Color(0xFF4CAF82);
    if (code >= 300 && code < 400) return const Color(0xFF42A5F5);
    if (code >= 400 && code < 500) return const Color(0xFFFFB74D);
    if (code >= 500) return const Color(0xFFEF5350);
    return const Color(0xFF9E9E9E);
  }

  // ---------------------------------------------------------------------------
  // Log level ranglari
  // ---------------------------------------------------------------------------

  static Color logLevelColor(LogLevel level) => switch (level) {
        LogLevel.debug => const Color(0xFF9E9E9E),
        LogLevel.info => const Color(0xFF42A5F5),
        LogLevel.warn => const Color(0xFFFFB74D),
        LogLevel.error => const Color(0xFFEF5350),
      };

  // ---------------------------------------------------------------------------
  // Shrift nomi
  // ---------------------------------------------------------------------------

  static const String monoFont = 'monospace';

  // ---------------------------------------------------------------------------
  // Matn stillari
  // ---------------------------------------------------------------------------

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: textPrimary,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: textSecondary,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  // ---------------------------------------------------------------------------
  // ThemeData
  // ---------------------------------------------------------------------------

  static ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgPrimary,
        colorScheme: const ColorScheme.dark(
          surface: bgSecondary,
          primary: accent,
          onPrimary: bgPrimary,
          onSurface: textPrimary,
          error: error,
        ),
        dividerColor: borderSubtle,
        cardColor: bgCard,
        appBarTheme: const AppBarTheme(
          backgroundColor: bgSecondary,
          foregroundColor: textPrimary,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: bgTertiary,
          selectedColor: accentDim,
          labelStyle: TextStyle(color: textPrimary, fontSize: 12),
          side: BorderSide(color: borderSubtle),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: bgTertiary,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent),
          ),
          hintStyle: TextStyle(color: textTertiary),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );
}
