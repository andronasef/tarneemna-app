import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';

class DownloadManagerService {
  final ValueNotifier<Map<String, double>> downloadProgress =
      ValueNotifier<Map<String, double>>({});

  bool isDownloading(String id) => downloadProgress.value.containsKey(id);

  double? getProgress(String id) => downloadProgress.value[id];

  Future<DownloadedHymn?> downloadHymn(
    Hymn hymn, {
    required OfflineStorageService storageService,
  }) async {
    if (storageService.isDownloaded(hymn.id)) {
      return storageService.getDownloadedHymn(hymn.id);
    }

    if (isDownloading(hymn.id)) {
      return null;
    }

    _updateProgress(hymn.id, 0.05);

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${docDir.path}/downloads/audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final targetFile = File('${audioDir.path}/${hymn.id}.mp3');

      // 1. Resolve Audio URL
      String? streamUrl = hymn.audioUrl;
      if (streamUrl == null || streamUrl.isEmpty) {
        if (hymn.source == HymnSource.taranimar) {
          streamUrl = 'https://taranimarabia.org/music/${hymn.id}.mp3';
        } else {
          streamUrl = await YouTubeAudioResolver.getAudioUrl(hymn.id);
        }
      }

      if (streamUrl == null || streamUrl.isEmpty) {
        throw Exception('Could not resolve audio stream URL for download');
      }

      _updateProgress(hymn.id, 0.15);

      // 2. Stream download to disk with progress tracking
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(streamUrl));
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final sink = targetFile.openWrite();
      await response.stream.listen(
        (chunk) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            final p = 0.15 + (receivedBytes / totalBytes) * 0.8;
            _updateProgress(hymn.id, p.clamp(0.15, 0.95));
          }
        },
        cancelOnError: true,
      ).asFuture();

      await sink.flush();
      await sink.close();
      client.close();

      final fileSizeBytes = await targetFile.length();

      final downloadedHymn = DownloadedHymn(
        id: hymn.id,
        title: hymn.title,
        singer: hymn.singer,
        album: hymn.album,
        artworkUrl: hymn.artworkUrl,
        localFilePath: targetFile.path,
        fileSizeBytes: fileSizeBytes,
        downloadedAt: DateTime.now(),
        lyrics: hymn.lyrics,
        source: hymn.source,
        duration: hymn.duration,
      );

      await storageService.saveDownloadedHymn(downloadedHymn);
      _removeProgress(hymn.id);
      return downloadedHymn;
    } catch (e) {
      if (kDebugMode) print('Download error for ${hymn.title}: $e');
      _removeProgress(hymn.id);
      rethrow;
    }
  }

  void _updateProgress(String id, double progress) {
    final current = Map<String, double>.from(downloadProgress.value);
    current[id] = progress;
    downloadProgress.value = current;
  }

  void _removeProgress(String id) {
    final current = Map<String, double>.from(downloadProgress.value);
    current.remove(id);
    downloadProgress.value = current;
  }
}
