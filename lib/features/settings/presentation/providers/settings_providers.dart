import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarneemna/features/settings/data/sources/settings_service.dart';
import 'package:tarneemna/features/settings/domain/models/app_settings.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('settingsServiceProvider must be overridden in ProviderScope');
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(_service.getSettings());

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _service.saveSettings(state);
  }

  Future<void> setAccent(SpiritualAccent accent) async {
    state = state.copyWith(accent: accent);
    await _service.saveSettings(state);
  }

  Future<void> setFontScale(double scale) async {
    final clamped = scale.clamp(0.85, 1.30);
    state = state.copyWith(fontScale: clamped);
    await _service.saveSettings(state);
  }

  Future<void> setGaplessPlayback(bool enabled) async {
    state = state.copyWith(gaplessPlayback: enabled);
    await _service.saveSettings(state);
  }

  Future<void> setAutoDownloadFavoritesWifi(bool enabled) async {
    state = state.copyWith(autoDownloadFavoritesWifi: enabled);
    await _service.saveSettings(state);
  }

  Future<void> setHighContrastText(bool enabled) async {
    state = state.copyWith(highContrastText: enabled);
    await _service.saveSettings(state);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service);
});

ThemeData buildAppTheme({
  required AppThemeMode mode,
  required SpiritualAccent accent,
  bool highContrast = false,
  bool applyCustomFont = true,
}) {
  final primaryColor = accent.color;

  if (mode == AppThemeMode.oled) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
      cardColor: const Color(0xFF0F0F0F),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.black,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSurface: highContrast ? Colors.white : Colors.white70,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: applyCustomFont
          ? GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme)
          : ThemeData.dark().textTheme,
    );
  }

  if (mode == AppThemeMode.dark) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      canvasColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: const Color(0xFF1E293B),
        onPrimary: Colors.white,
        onSurface: highContrast ? Colors.white : Colors.white70,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: applyCustomFont
          ? GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme)
          : ThemeData.dark().textTheme,
    );
  }

  // Light Theme
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    canvasColor: const Color(0xFFF8FAFC),
    cardColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: highContrast ? Colors.black : Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: applyCustomFont
        ? GoogleFonts.cairoTextTheme(ThemeData.light().textTheme)
        : ThemeData.light().textTheme,
  );
}

final activeThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return buildAppTheme(
    mode: settings.themeMode,
    accent: settings.accent,
    highContrast: settings.highContrastText,
  );
});
