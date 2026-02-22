import 'package:flutter/material.dart';

@immutable
class GhibliThemeData {
  final Brightness brightness;

  final Color background;
  final Color surface;

  final Color primary;
  final Color onPrimary;

  final Color secondary;
  final Color accent;

  final Color text;
  final Color textSoft;

  final Color divider;

  const GhibliThemeData({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.textSoft,
    required this.divider,
  });
}
