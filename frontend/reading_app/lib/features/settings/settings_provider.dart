import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_models.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  // ===== THEME =====

  void useDefaultTheme() {
    state = state.copyWith(
      themeStyle: ThemeStyle.defaultTheme,
      clearGhibliPalette: true,
    );
  }

  void setDefaultThemeMode(DefaultThemeMode mode) {
    state = state.copyWith(defaultThemeMode: mode);
  }

  void useGhibliTheme(String paletteId) {
    state = state.copyWith(
      themeStyle: ThemeStyle.ghibli,
      ghibliPaletteId: paletteId,
    );
  }

  // ===== OTHER SETTINGS =====

  void toggleConfirmDelete(bool value) {
    state = state.copyWith(confirmDelete: value);
  }

  void toggleNotifications(bool value) {
    state =
        state.copyWith(notificationsEnabled: value);
  }

  void toggleAutoSync(bool value) {
    state = state.copyWith(autoSync: value);
  }
}

final settingsProvider =
StateNotifierProvider<SettingsNotifier, AppSettings>(
      (ref) => SettingsNotifier(),
);
