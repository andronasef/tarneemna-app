import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/hymn.dart';

final localHymnCacheProvider = Provider<LocalHymnCache>((ref) {
  return LocalHymnCache();
});

class LocalHymnCache {
  static const String boxName = 'hymns_cache';
  Box? _box;

  Box get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('LocalHymnCache has not been initialized. Call init() first.');
    }
    return _box!;
  }

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(boxName);
    }
  }

  Future<void> cacheHymn(Hymn hymn) async {
    await box.put(hymn.id, hymn.toMap());
  }

  Future<void> cacheHymns(List<Hymn> hymns) async {
    final Map<String, dynamic> entries = {
      for (final hymn in hymns) hymn.id: hymn.toMap(),
    };
    await box.putAll(entries);
  }

  Hymn? getHymn(String id) {
    final data = box.get(id);
    if (data == null) return null;
    try {
      final map = Map<String, dynamic>.from(data as Map);
      return Hymn.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  List<Hymn> getCachedHymns() {
    final List<Hymn> results = [];
    for (final key in box.keys) {
      final hymn = getHymn(key.toString());
      if (hymn != null) results.add(hymn);
    }
    return results;
  }

  Future<void> deleteHymn(String id) async {
    await box.delete(id);
  }

  Future<void> clearCache() async {
    await box.clear();
  }
}
