import 'package:flutter/material.dart';
import '../ghibli_theme_data.dart';

class GhibliPalette {
  final String id;
  final String label;

  final GhibliThemeData light;
  final GhibliThemeData dark;

  const GhibliPalette({
    required this.id,
    required this.label,
    required this.light,
    required this.dark,
  });

  GhibliThemeData themeFor(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  /// Para previews rápidos en tiles/grids
  Color seedFor(Brightness brightness) {
    final t = themeFor(brightness);
    return t.primary;
  }
}
