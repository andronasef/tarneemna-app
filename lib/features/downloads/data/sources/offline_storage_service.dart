import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';

class OfflineStorageService {
  static const String boxName = 'downloaded_hymns';
  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox(boxName);
    } else {
      _box = Hive.box(boxName);
    }
  }

  Box get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError('OfflineStorageService box not opened. Call init() first.');
    }
    return _box!;
  }

  List<DownloadedHymn> getDownloadedHymns() {
    final values = _safeBox.values;
    final hymns = <DownloadedHymn>[];
    for (final v in values) {
      if (v is Map) {
        try {
          hymns.add(DownloadedHymn.fromMap(v));
        } catch (e) {
          if (kDebugMode) print('Error parsing downloaded hymn: $e');
        }
      }
    }
    hymns.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return hymns;
  }

  DownloadedHymn? getDownloadedHymn(String id) {
    final val = _safeBox.get(id);
    if (val is Map) {
      try {
        return DownloadedHymn.fromMap(val);
      } catch (e) {
        if (kDebugMode) print('Error parsing downloaded hymn $id: $e');
      }
    }
    return null;
  }

  bool isDownloaded(String id) {
    final hymn = getDownloadedHymn(id);
    if (hymn == null) return false;
    final file = File(hymn.localFilePath);
    return file.existsSync();
  }

  Future<void> saveDownloadedHymn(DownloadedHymn hymn) async {
    await _safeBox.put(hymn.id, hymn.toMap());
  }

  Future<void> deleteDownloadedHymn(String id) async {
    final hymn = getDownloadedHymn(id);
    if (hymn != null) {
      try {
        final file = File(hymn.localFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        if (kDebugMode) print('Error deleting audio file: $e');
      }
      await _safeBox.delete(id);
    }
  }

  Future<void> clearAll() async {
    final hymns = getDownloadedHymns();
    for (final hymn in hymns) {
      try {
        final file = File(hymn.localFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        if (kDebugMode) print('Error deleting file: $e');
      }
    }
    await _safeBox.clear();
  }

  int getTotalStorageBytes() {
    final hymns = getDownloadedHymns();
    int total = 0;
    for (final h in hymns) {
      total += h.fileSizeBytes;
    }
    return total;
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb كيلوبايت';
    }
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return '$mb ميجابايت';
  }
}
