import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

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
    // Fall back to the box main() already opened, so ad-hoc instances work too.
    final box = _box ?? (Hive.isBoxOpen(boxName) ? _box = Hive.box(boxName) : null);
    if (box == null || !box.isOpen) {
      throw StateError('OfflineStorageService box not opened. Call init() first.');
    }
    return box;
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


  Future<void> syncWithDiskAndDownloader() async {
    // 1. Check flutter_downloader tasks
    try {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks != null) {
        for (final task in tasks) {
          if (task.status == DownloadTaskStatus.complete && task.filename != null) {
            final filePath = '${task.savedDir}/${task.filename}';
            final file = File(filePath);
            if (file.existsSync()) {
              final rawTitle = task.filename!.replaceAll('.mp3', '').replaceAll('.m4a', '');
              final alreadyExists = getDownloadedHymns().any((h) => h.localFilePath == filePath);
              if (!alreadyExists) {
                final hymnId = 'yt_${task.taskId.hashCode.abs()}';
                final downloadedHymn = DownloadedHymn(
                  id: hymnId,
                  title: rawTitle,
                  singer: 'ترانيم محملة',
                  artworkUrl: null,
                  localFilePath: filePath,
                  fileSizeBytes: file.lengthSync(),
                  downloadedAt: DateTime.fromMillisecondsSinceEpoch(task.timeCreated),
                  source: HymnSource.youtube,
                );
                await saveDownloadedHymn(downloadedHymn);
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error syncing with flutter_downloader: $e');
    }

    // 2. Scan our own audio dir only. Never the public Download folder: anything
    // registered here can be deleted from the storage screen.
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final appAudioDir = Directory('${docDir.path}/downloads/audio');
      if (appAudioDir.existsSync()) {
        final known = getDownloadedHymns().map((h) => h.localFilePath).toSet();
        for (final entity in appAudioDir.listSync()) {
          if (entity is File && entity.path.endsWith('.mp3') && !known.contains(entity.path)) {
            final fileName = entity.uri.pathSegments.last;
            final stat = entity.statSync();
            await saveDownloadedHymn(DownloadedHymn(
              id: 'file_${entity.path.hashCode.abs()}',
              title: fileName.replaceAll('.mp3', ''),
              singer: 'ترانيم محملة',
              localFilePath: entity.path,
              fileSizeBytes: stat.size,
              downloadedAt: stat.modified,
              source: HymnSource.youtube,
            ));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error scanning download dir: $e');
    }
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
