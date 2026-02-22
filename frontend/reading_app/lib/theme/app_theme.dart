import 'package:flutter/material.dart';
import 'ghibli/ghibli_theme_data.dart';

class AppTheme {
  /// ===============================
  /// DEFAULT THEME (Light / Dark)
  /// ===============================
  static ThemeData fromScheme(ColorScheme scheme) {
    return ThemeData(
      brightness: scheme.brightness,
      colorScheme: scheme,

      scaffoldBackgroundColor: scheme.background,
      cardColor: scheme.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        elevation: 0,
        foregroundColor: scheme.onBackground,
      ),

      textTheme: TextTheme(
        bodyMedium: TextStyle(color: scheme.onBackground),
        bodySmall: TextStyle(color: scheme.onSurfaceVariant),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      dividerColor: scheme.outlineVariant,
    );
  }

  /// ===============================
  /// GHIBLI THEME (FULL PALETTE)
  /// ===============================
  static ThemeData fromGhibli(GhibliThemeData ghibli) {
    return ThemeData(
      brightness: ghibli.brightness,

      scaffoldBackgroundColor: ghibli.background,
      cardColor: ghibli.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: ghibli.background,
        elevation: 0,
        foregroundColor: ghibli.text,
      ),

      textTheme: TextTheme(
        bodyMedium: TextStyle(color: ghibli.text),
        bodySmall: TextStyle(color: ghibli.textSoft),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ghibli.primary,
          foregroundColor: ghibli.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: ghibli.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      dividerColor: ghibli.divider,
    );
  }
}
