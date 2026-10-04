import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';

class DownloadManagerService {
  final Set<String> _inFlight = {};

  Future<DownloadedHymn?> downloadHymn(
    Hymn hymn, {
    required OfflineStorageService storageService,
  }) async {
    if (storageService.isDownloaded(hymn.id)) {
      return storageService.getDownloadedHymn(hymn.id);
    }

    if (!_inFlight.add(hymn.id)) return null;

    File? targetFile;
    final client = http.Client();
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${docDir.path}/downloads/audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

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

      final response = await client.send(http.Request('GET', Uri.parse(streamUrl)));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode} downloading ${hymn.id}');
      }

      targetFile = File('${audioDir.path}/${hymn.id}.mp3');
      final sink = targetFile.openWrite();
      try {
        await response.stream.pipe(sink);
      } finally {
        await sink.close();
      }

      final downloadedHymn = DownloadedHymn(
        id: hymn.id,
        title: hymn.title,
        singer: hymn.singer,
        album: hymn.album,
        artworkUrl: hymn.artworkUrl,
        localFilePath: targetFile.path,
        fileSizeBytes: await targetFile.length(),
        downloadedAt: DateTime.now(),
        lyrics: hymn.lyrics,
        source: hymn.source,
        duration: hymn.duration,
      );

      await storageService.saveDownloadedHymn(downloadedHymn);
      return downloadedHymn;
    } catch (e) {
      if (kDebugMode) print('Download error for ${hymn.title}: $e');
      // Don't leave a partial file behind for the disk scan to pick up.
      if (targetFile != null && await targetFile.exists()) await targetFile.delete();
      rethrow;
    } finally {
      client.close();
      _inFlight.remove(hymn.id);
    }
  }
}
