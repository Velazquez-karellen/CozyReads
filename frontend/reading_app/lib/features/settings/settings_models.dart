enum ThemeStyle {
  defaultTheme,
  ghibli,
}

enum DefaultThemeMode {
  system,
  light,
  dark,
}

class AppSettings {
  final ThemeStyle themeStyle;

  /// Only used when themeStyle == defaultTheme
  final DefaultThemeMode defaultThemeMode;

  /// Only used when themeStyle == ghibli
  final String? ghibliPaletteId;

  final bool confirmDelete;
  final bool notificationsEnabled;
  final bool autoSync;

  const AppSettings({
    this.themeStyle = ThemeStyle.defaultTheme,
    this.defaultThemeMode = DefaultThemeMode.system,
    this.ghibliPaletteId,
    this.confirmDelete = true,
    this.notificationsEnabled = false,
    this.autoSync = true,
  });

  AppSettings copyWith({
    ThemeStyle? themeStyle,
    DefaultThemeMode? defaultThemeMode,
    String? ghibliPaletteId,
    bool clearGhibliPalette = false,
    bool? confirmDelete,
    bool? notificationsEnabled,
    bool? autoSync,
  }) {
    return AppSettings(
      themeStyle: themeStyle ?? this.themeStyle,
      defaultThemeMode:
      defaultThemeMode ?? this.defaultThemeMode,
      ghibliPaletteId: clearGhibliPalette
          ? null
          : ghibliPaletteId ?? this.ghibliPaletteId,
      confirmDelete: confirmDelete ?? this.confirmDelete,
      notificationsEnabled:
      notificationsEnabled ?? this.notificationsEnabled,
      autoSync: autoSync ?? this.autoSync,
    );
  }
}
