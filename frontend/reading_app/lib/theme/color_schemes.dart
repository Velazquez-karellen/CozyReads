import 'package:flutter/material.dart';

class CozyColorSchemes {
  static ColorScheme defaultScheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const ColorScheme.light(
        background: Colors.white,
        surface: Colors.white,
        primary: Colors.black,
        onPrimary: Colors.white,
        onBackground: Colors.black,
        onSurface: Colors.black,
        outlineVariant: Color(0xFFE6E6E6),
        surfaceVariant: Color(0xFFF5F5F5),
        onSurfaceVariant: Color(0xFF333333),
      );
    }

    return const ColorScheme.dark(
      background: Colors.black,
      surface: Color(0xFF121212),
      primary: Colors.white,
      onPrimary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
      outlineVariant: Color(0xFF2A2A2A),
      surfaceVariant: Color(0xFF1A1A1A),
      onSurfaceVariant: Color(0xFFDDDDDD),
    );
  }
}
