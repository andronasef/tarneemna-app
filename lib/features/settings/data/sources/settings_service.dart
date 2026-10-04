import 'package:hive_flutter/hive_flutter.dart';
import 'package:tarneemna/features/settings/domain/models/app_settings.dart';

class SettingsService {
  static const String boxName = 'app_settings';
  static const String settingsKey = 'current_settings';

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  AppSettings getSettings() {
    final box = _box;
    if (box == null) return const AppSettings();

    final data = box.get(settingsKey);
    if (data is Map) {
      return AppSettings.fromMap(data);
    }
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = _box;
    if (box == null) return;

    await box.put(settingsKey, settings.toMap());
  }
}
