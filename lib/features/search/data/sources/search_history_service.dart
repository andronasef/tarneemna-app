import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchHistoryService {
  static const String boxName = 'search_history';
  static const int maxHistory = 20;

  Box get _box {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    throw StateError('Search history box is not opened yet');
  }

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  ValueListenable<Box> get listenable => _box.listenable();

  List<String> getQueries() {
    if (!Hive.isBoxOpen(boxName)) return [];
    final raw = _box.get('recent_queries');
    if (raw != null && raw is List) {
      return List<String>.from(raw);
    }
    return [];
  }

  Future<void> addQuery(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    final list = getQueries();
    list.removeWhere((item) => item.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    if (list.length > maxHistory) {
      list.removeRange(maxHistory, list.length);
    }
    await _box.put('recent_queries', list);
  }

  Future<void> removeQuery(String query) async {
    final list = getQueries();
    list.removeWhere((item) => item == query);
    await _box.put('recent_queries', list);
  }

  Future<void> clearAll() async {
    await _box.delete('recent_queries');
  }

  /// Normalizes Arabic text by removing Tashkeel, unifying Alef, Yaa, and Taa Marbouta.
  static String normalizeArabic(String input) {
    var text = input;
    // Remove Tashkeel diacritics
    text = text.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');
    // Standardize Alef forms (أ, إ, آ, ٱ) -> ا
    text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    // Standardize Yaa forms (ى, ئ) -> ي
    text = text.replaceAll(RegExp(r'[ىئ]'), 'ي');
    // Standardize Taa Marbouta (ة) -> ه
    text = text.replaceAll('ة', 'ه');
    // Standardize Persian/Urdu variants
    text = text.replaceAll('ك', 'ك');
    return text.toLowerCase().trim();
  }

  static bool fuzzyArabicMatch(String target, String query) {
    final normTarget = normalizeArabic(target);
    final normQuery = normalizeArabic(query);
    if (normQuery.isEmpty) return true;
    return normTarget.contains(normQuery);
  }
}
