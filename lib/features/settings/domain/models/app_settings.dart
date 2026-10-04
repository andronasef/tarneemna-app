import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  oled,
}

enum SpiritualAccent {
  coral(
    label: 'مرجاني (ترانيمنا)',
    color: Color(0xFFFF5432),
  ),
  sky(
    label: 'سماوي (ملائكي)',
    color: Color(0xFF0284C7),
  ),
  gold(
    label: 'ذهبي (ملكي)',
    color: Color(0xFFD97706),
  ),
  purple(
    label: 'بنفسجي (روحي)',
    color: Color(0xFF7C3AED),
  ),
  olive(
    label: 'زيتوني (سلام)',
    color: Color(0xFF15803D),
  );

  final String label;
  final Color color;

  const SpiritualAccent({
    required this.label,
    required this.color,
  });
}

class AppSettings {
  final AppThemeMode themeMode;
  final SpiritualAccent accent;
  final double fontScale;
  final bool gaplessPlayback;
  final bool autoDownloadFavoritesWifi;
  final bool highContrastText;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.accent = SpiritualAccent.coral,
    this.fontScale = 1.0,
    this.gaplessPlayback = true,
    this.autoDownloadFavoritesWifi = false,
    this.highContrastText = false,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    SpiritualAccent? accent,
    double? fontScale,
    bool? gaplessPlayback,
    bool? autoDownloadFavoritesWifi,
    bool? highContrastText,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      fontScale: fontScale ?? this.fontScale,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      autoDownloadFavoritesWifi: autoDownloadFavoritesWifi ?? this.autoDownloadFavoritesWifi,
      highContrastText: highContrastText ?? this.highContrastText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'accent': accent.name,
      'fontScale': fontScale,
      'gaplessPlayback': gaplessPlayback,
      'autoDownloadFavoritesWifi': autoDownloadFavoritesWifi,
      'highContrastText': highContrastText,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const AppSettings();

    final themeModeStr = map['themeMode'] as String? ?? 'system';
    final accentStr = map['accent'] as String? ?? 'coral';
    final fontScaleVal = (map['fontScale'] as num?)?.toDouble() ?? 1.0;
    final gaplessVal = map['gaplessPlayback'] as bool? ?? true;
    final autoDownloadVal = map['autoDownloadFavoritesWifi'] as bool? ?? false;
    final highContrastVal = map['highContrastText'] as bool? ?? false;

    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == themeModeStr,
        orElse: () => AppThemeMode.system,
      ),
      accent: SpiritualAccent.values.firstWhere(
        (e) => e.name == accentStr,
        orElse: () => SpiritualAccent.coral,
      ),
      fontScale: fontScaleVal.clamp(0.85, 1.30),
      gaplessPlayback: gaplessVal,
      autoDownloadFavoritesWifi: autoDownloadVal,
      highContrastText: highContrastVal,
    );
  }
}
