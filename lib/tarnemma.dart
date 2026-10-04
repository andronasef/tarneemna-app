import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tarneemna/features/hymns/data/repositories/hybrid_hymns_repository_impl.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/taranim_arabia/data/repositories/taranim_arabia_repository_impl.dart';
import 'package:tarneemna/features/taranim_arabia/data/sources/taranim_arabia_remote_data_source.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';
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
  final HymnSource source;
  final String? lyrics;

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
    this.source = HymnSource.youtube,
    this.lyrics,
  });

  Hymn toHymn() {
    return Hymn(
      id: id,
      title: title,
      singer: author,
      artworkUrl: thumbnail,
      audioUrl: downloadUrl,
      lyrics: lyrics,
      source: source,
    );
  }

  factory Tarnemma.fromHymn(Hymn hymn) {
    return Tarnemma(
      id: hymn.id,
      title: hymn.title,
      author: hymn.singer ?? (hymn.source == HymnSource.taranimar ? 'ترانيم عربية' : 'غير معروف'),
      thumbnail: hymn.artworkUrl ?? 'https://taranimarabia.org/img/logo.png',
      duration: hymn.duration != null
          ? hymn.duration.toString().split('.').first
          : '03:30',
      downloadUrl: hymn.audioUrl,
      source: hymn.source,
      lyrics: hymn.lyrics,
    );
  }

  /// Performs hybrid search querying both Taranim Arabia and YouTube Explode
  static Future<List<Tarnemma>> search(String query) async {
    final List<Tarnemma> list = [];
    if (query.trim().isEmpty) return list;

    try {
      final hybridRepo = HybridHymnsRepositoryImpl(
        taranimArabiaRepo: TaranimArabiaRepositoryImpl(
          remoteDataSource: TaranimArabiaRemoteDataSource(),
        ),
      );

      final hymns = await hybridRepo.searchHymns(query);
      return hymns.map((h) => Tarnemma.fromHymn(h)).toList();
    } catch (e) {
      if (kDebugMode) print("Hybrid search error, falling back to YouTube: $e");
      return _searchYouTubeOnly(query);
    }
  }

  static Future<List<Tarnemma>> _searchYouTubeOnly(String query) async {
    final List<Tarnemma> list = [];
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
            source: HymnSource.youtube,
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

  static Future<String?> resolveVisionOsAudio(String videoId) async {
    return YouTubeAudioResolver.resolveVisionOsAudio(videoId);
  }

  Future<String?> getAudioUrl() async {
    if (downloadUrl != null && downloadUrl!.isNotEmpty) {
      return downloadUrl;
    }

    if (source == HymnSource.taranimar) {
      downloadUrl = 'https://taranimarabia.org/music/$id.mp3';
      return downloadUrl;
    }

    isResolvingStream.value = true;
    try {
      final vUrl = await YouTubeAudioResolver.getAudioUrl(id);
      if (vUrl != null && vUrl.isNotEmpty) {
        downloadUrl = vUrl;
        return downloadUrl;
      }
    } catch (e) {
      if (kDebugMode) print("Error getting audio URL: $e");
    } finally {
      isResolvingStream.value = false;
    }
    return null;
  }

  Future<void> download() async {
    final hasInternet = await InternetConnectionChecker().hasConnection;
    if (!hasInternet) {
      showCustomSnackbar(
        "لا يوجد اتصال",
        "تأكد من الاتصال بالإنترنت لبدء التحميل",
        Icons.wifi_off,
      );
      return;
    }

    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      showCustomSnackbar(
        "خطأ في الصلاحيات",
        "يرجى منح صلاحية التخزين لحفظ الترانيم",
        Icons.folder_off,
      );
      return;
    }

    downloadProcess.value = DownloadTaskStatus.enqueued;
    downloadProgress.value = 0;

    final url = await getAudioUrl();
    if (url == null || url.isEmpty) {
      downloadProcess.value = DownloadTaskStatus.failed;
      showCustomSnackbar(
        "خطأ في التحميل",
        "تعذر استخراج رابط الصوت للتحميل",
        Icons.error_outline,
      );
      return;
    }

    try {
      final savedDir = await getDownloadPath();
      final dir = Directory(savedDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final fileName = "${sanitizeFileName(title)}.mp3";

      taskId = await FlutterDownloader.enqueue(
        url: url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1',
        },
        savedDir: savedDir,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      if (taskId != null) {
        downloadProcess.value = DownloadTaskStatus.running;
        showCustomSnackbar(
          "بدء التحميل",
          "جاري تحميل ترنيمة: $title",
          Icons.downloading,
        );
      } else {
        downloadProcess.value = DownloadTaskStatus.failed;
        showCustomSnackbar(
          "خطأ",
          "فشل في إضافة مهمة التحميل",
          Icons.error_outline,
        );
      }
    } catch (e) {
      if (kDebugMode) print("Download enqueue error: $e");
      downloadProcess.value = DownloadTaskStatus.failed;
      showCustomSnackbar(
        "خطأ في التحميل",
        "حدث خطأ أثناء بدء التحميل: $e",
        Icons.error_outline,
      );
    }
  }
}
