import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/settings/domain/models/app_settings.dart';
import 'package:tarneemna/features/settings/presentation/providers/settings_providers.dart';

void main() {
  group('Settings & Theming Tests', () {
    test('AppSettings defaults to system theme, coral accent and 1.0 font scale', () {
      const settings = AppSettings();
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.accent, SpiritualAccent.coral);
      expect(settings.fontScale, 1.0);
    });

    test('AppSettings serializes and deserializes accurately', () {
      const settings = AppSettings(
        themeMode: AppThemeMode.oled,
        accent: SpiritualAccent.gold,
        fontScale: 1.15,
        highContrastText: true,
      );

      final map = settings.toMap();
      expect(map['themeMode'], 'oled');
      expect(map['accent'], 'gold');
      expect(map['fontScale'], 1.15);
      expect(map['highContrastText'], isTrue);

      final restored = AppSettings.fromMap(map);
      expect(restored.themeMode, AppThemeMode.oled);
      expect(restored.accent, SpiritualAccent.gold);
      expect(restored.fontScale, 1.15);
      expect(restored.highContrastText, isTrue);
    });

    test('AppSettings clamps font scale between 0.85 and 1.30', () {
      final low = AppSettings.fromMap({'fontScale': 0.5});
      expect(low.fontScale, 0.85);

      final high = AppSettings.fromMap({'fontScale': 2.0});
      expect(high.fontScale, 1.30);
    });

    test('buildAppTheme for OLED produces true black background', () {
      final oledTheme = buildAppTheme(
        mode: AppThemeMode.oled,
        accent: SpiritualAccent.sky,
        applyCustomFont: false,
      );

      expect(oledTheme.scaffoldBackgroundColor, Colors.black);
      expect(oledTheme.brightness, Brightness.dark);
      expect(oledTheme.colorScheme.surface, Colors.black);
      expect(oledTheme.colorScheme.primary, const Color(0xFF0284C7));
    });

    test('buildAppTheme for Dark and Light produces expected surfaces and primary colors', () {
      final darkTheme = buildAppTheme(
        mode: AppThemeMode.dark,
        accent: SpiritualAccent.purple,
        applyCustomFont: false,
      );
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF0F172A));
      expect(darkTheme.colorScheme.primary, const Color(0xFF7C3AED));

      final lightTheme = buildAppTheme(
        mode: AppThemeMode.light,
        accent: SpiritualAccent.olive,
        applyCustomFont: false,
      );
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFF8FAFC));
      expect(lightTheme.colorScheme.primary, const Color(0xFF15803D));
    });
  });
}
