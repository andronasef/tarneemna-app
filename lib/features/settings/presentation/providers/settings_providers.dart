import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/sources/settings_service.dart';
import '../../domain/models/app_settings.dart';

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
        surfaceContainerHighest: const Color(0xFF1E1E1E),
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSurface: highContrast ? Colors.white : Colors.white70,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF161616),
        hintStyle: TextStyle(
          color: highContrast ? Colors.white70 : Colors.white38,
          fontSize: 14,
        ),
        prefixIconColor: primaryColor,
        suffixIconColor: Colors.white54,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
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
        surfaceContainerHighest: const Color(0xFF283548),
        onPrimary: Colors.white,
        onSurface: highContrast ? Colors.white : Colors.white70,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        hintStyle: TextStyle(
          color: highContrast ? Colors.white70 : Colors.white38,
          fontSize: 14,
        ),
        prefixIconColor: primaryColor,
        suffixIconColor: Colors.white54,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
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
      surfaceContainerHighest: const Color(0xFFE2E8F0),
      onPrimary: Colors.white,
      onSurface: highContrast ? Colors.black : Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      hintStyle: TextStyle(
        color: highContrast ? Colors.black87 : Colors.black45,
        fontSize: 14,
      ),
      prefixIconColor: primaryColor,
      suffixIconColor: Colors.black54,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    ),
    textTheme: applyCustomFont
        ? GoogleFonts.cairoTextTheme(ThemeData.light().textTheme)
        : ThemeData.light().textTheme,
  );
}

final lightThemeProvider = Provider<ThemeData>((ref) {
  final s = ref.watch(settingsNotifierProvider);
  return buildAppTheme(mode: AppThemeMode.light, accent: s.accent, highContrast: s.highContrastText);
});

/// OLED when chosen, otherwise the regular dark theme (used by "system" too).
final darkThemeProvider = Provider<ThemeData>((ref) {
  final s = ref.watch(settingsNotifierProvider);
  return buildAppTheme(
    mode: s.themeMode == AppThemeMode.oled ? AppThemeMode.oled : AppThemeMode.dark,
    accent: s.accent,
    highContrast: s.highContrastText,
  );
});
