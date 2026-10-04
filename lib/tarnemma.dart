import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_explode_webview/youtube_explode_webview.dart';

import 'player.dart';
import 'widgets/snackbar.dart';

WebviewEJSSolver? _jsSolver;
YoutubeExplode? _yt;

YoutubeExplode get yt {
  _yt ??= YoutubeExplode(jsSolver: _jsSolver);
  return _yt!;
}

Future<void> initYoutubeExplode() async {
  try {
    _jsSolver = await WebviewEJSSolver.init();
    _yt = YoutubeExplode(jsSolver: _jsSolver);
    if (kDebugMode) print("WebviewEJSSolver initialized successfully!");
  } catch (e) {
    if (kDebugMode) print("Failed to initialize WebviewEJSSolver: $e");
    _yt = YoutubeExplode();
  }
}

class Tarnemma {
  final String title;
  final String duration;
  final String author;
  final String id;
  String? downloadUrl;
  final String thumbnail;
  String? taskId;

  final Rx<DownloadTaskStatus> downloadProcess =
      DownloadTaskStatus.undefined.obs;
  final RxInt downloadProgress = 0.obs;
  final RxBool isResolvingStream = false.obs;

  Tarnemma({
    required this.title,
    required this.duration,
    required this.author,
    required this.id,
    this.downloadUrl,
    required this.thumbnail,
    this.taskId,
  });

  static Future<List<Tarnemma>> search(String query) async {
    final List<Tarnemma> list = [];
    if (query.trim().isEmpty) return list;

    try {
      if (kDebugMode) print("Querying YouTube for: $query");
      final searchList = await yt.search.search(query);

      for (final video in searchList) {
        try {
          final song = Tarnemma(
            title: video.title,
            duration: video.duration?.toString().split('.').first ?? "00:00",
            author: video.author,
            id: video.id.value,
            thumbnail: video.thumbnails.standardResUrl.isNotEmpty
                ? video.thumbnails.standardResUrl
                : video.thumbnails.highResUrl,
          );
          list.add(song);
        } catch (e) {
          if (kDebugMode) print("Error parsing video search result: $e");
        }
      }
    } catch (e) {
      if (kDebugMode) print("Search error: $e");
      rethrow;
    }
    return list;
  }

  static Future<String> getDownloadPath() async {
    if (Platform.isAndroid) {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (downloadsDir.existsSync()) {
        return downloadsDir.path;
      }
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir.path;
      }
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  static String sanitizeFileName(String input) {
    return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  static Future<bool> checkAndRequestPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        await Permission.storage.request();
      }

      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        await Permission.notification.request();
      }
    } catch (e) {
      if (kDebugMode) print("Permission request error: $e");
    }

    return true;
  }

  Future<void> play() async {
    await Player.playTarnemma(this);
  }

  /// Resolves the stream using Innertube VISIONOS client (same method used by pytubefix).
  /// This yields playable URLs with no 403 or 1MB stream throttling.
  static Future<String?> resolveVisionOsAudio(String videoId) async {
    final client = HttpClient();
    try {
      // 1. Fetch visitorData from WEB client
      final webPayload = jsonEncode({
        'context': {
          'client': {
            'clientName': 'WEB',
            'clientVersion': '2.20240105.01.00',
            'hl': 'en',
            'gl': 'US',
          }
        },
        'videoId': videoId,
      });

      final req1 = await client.postUrl(
        Uri.parse('https://www.youtube.com/youtubei/v1/player?prettyPrint=false'),
      );
      req1.headers.set('Content-Type', 'application/json');
      req1.headers.set('User-Agent', 'Mozilla/5.0');
      req1.write(webPayload);
      final resp1 = await req1.close();
      final body1 = await resp1.transform(utf8.decoder).join();
      final data1 = jsonDecode(body1) as Map<String, dynamic>;
      final visitorData = data1['responseContext']?['visitorData'] as String?;

      // 2. Query player with VISIONOS client
      final visionPayload = jsonEncode({
        'context': {
          'client': {
            'clientName': 'VISIONOS',
            'clientVersion': '1.02',
            'deviceMake': 'Apple',
            'platform': 'MOBILE',
            'osName': 'visionOS',
            'osVersion': '26.5.23O471',
            'deviceModel': 'RealityDevice17,1',
            'hl': 'en',
            'timeZone': 'UTC',
            'utcOffsetMinutes': 0,
            if (visitorData != null) 'visitorData': visitorData,
          }
        },
        'videoId': videoId,
      });

      final req2 = await client.postUrl(
        Uri.parse(
          'https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false',
        ),
      );
      req2.headers.set('Content-Type', 'application/json');
      req2.headers.set(
        'User-Agent',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15',
      );
      req2.headers.set('X-Youtube-Client-Name', '101');
      req2.write(visionPayload);
      final resp2 = await req2.close();
      final body2 = await resp2.transform(utf8.decoder).join();
      final data2 = jsonDecode(body2) as Map<String, dynamic>;

      final streamingData = data2['streamingData'] as Map<String, dynamic>?;
      final formats =
          (streamingData?['adaptiveFormats'] as List<dynamic>?) ?? [];

      // Prefer itag 140 (AAC 128kbps m4a)
      for (final f in formats) {
        if (f['itag'] == 140 && f['url'] != null) {
          return f['url'] as String;
        }
      }

      // Fallback to any audio stream
      for (final f in formats) {
        final mime = (f['mimeType'] as String? ?? '');
        if (mime.contains('audio') && f['url'] != null) {
          return f['url'] as String;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error in resolveVisionOsAudio: $e");
    } finally {
      client.close();
    }
    return null;
  }

  Future<String?> getAudioUrl() async {
    if (downloadUrl != null && downloadUrl!.isNotEmpty) {
      return downloadUrl;
    }

    isResolvingStream.value = true;
    try {
      // 1. Primary: Use pytubefix-based VISIONOS Innertube stream resolution
      final vUrl = await resolveVisionOsAudio(id);
      if (vUrl != null && vUrl.isNotEmpty) {
        downloadUrl = vUrl;
        if (kDebugMode) print("Resolved VisionOS audio stream URL: $downloadUrl");
        return downloadUrl;
      }

      // 2. Fallback: youtube_explode_dart
      if (kDebugMode) print("Fallback to youtube_explode_dart for $id");
      StreamManifest manifest;
      try {
        manifest = await yt.videos.streamsClient.getManifest(
          id,
          ytClients: [YoutubeApiClient.androidSdkless],
          requireWatchPage: false,
        );
      } catch (e) {
        manifest = await yt.videos.streamsClient.getManifest(
          id,
          requireWatchPage: false,
        );
      }

      final audioStreams = manifest.audioOnly;
      if (audioStreams.isNotEmpty) {
        final mp4Streams =
            audioStreams.where((s) => s.container.name.toLowerCase() == 'mp4');
        final bestAudio = mp4Streams.isNotEmpty
            ? mp4Streams.withHighestBitrate()
            : audioStreams.withHighestBitrate();

        downloadUrl = bestAudio.url.toString();
        if (kDebugMode) print("Resolved audio stream URL from fallback: $downloadUrl");
        return downloadUrl;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching stream manifest for $id: $e");
    } finally {
      isResolvingStream.value = false;
    }
    return null;
  }

  Future<void> download() async {
    if (downloadProcess.value == DownloadTaskStatus.running ||
        downloadProcess.value == DownloadTaskStatus.enqueued) {
      return;
    }

    final hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      showCustomSnackbar(
        "خطأ",
        "لا يوجد اتصال بالانترنت",
        Icons.wifi_off_rounded,
      );
      return;
    }

    await checkAndRequestPermissions();

    downloadProcess.value = DownloadTaskStatus.running;

    final url = await getAudioUrl();
    if (url == null || url.isEmpty) {
      downloadProcess.value = DownloadTaskStatus.failed;
      showCustomSnackbar(
        "خطأ",
        "تعذر استخراج ملف الصوت للتحميل",
        Icons.error_outline,
      );
      return;
    }

    try {
      final saveDir = await getDownloadPath();
      final cleanName = "${sanitizeFileName(title)}.m4a";

      taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: saveDir,
        fileName: cleanName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      showCustomSnackbar(
        "بدأ التحميل",
        title,
        Icons.downloading,
      );
    } catch (e) {
      if (kDebugMode) print("Download error: $e");
      downloadProcess.value = DownloadTaskStatus.failed;
      showCustomSnackbar(
        "خطأ",
        "فشل بدء التحميل",
        Icons.error_outline,
      );
    }
  }

  void pause() {
    if (taskId != null) {
      FlutterDownloader.pause(taskId: taskId!);
    }
  }

  void resume() {
    if (taskId != null) {
      FlutterDownloader.resume(taskId: taskId!);
    }
  }

  void cancel() {
    if (taskId != null) {
      FlutterDownloader.cancel(taskId: taskId!);
      downloadProcess.value = DownloadTaskStatus.canceled;
      downloadProgress.value = 0;
    }
  }
}
