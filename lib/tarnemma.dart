
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tarneemna/features/downloads/data/sources/download_manager_service.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/features/hymns/data/repositories/hybrid_hymns_repository_impl.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/taranim_arabia/data/repositories/taranim_arabia_repository_impl.dart';
import 'package:tarneemna/features/taranim_arabia/data/sources/taranim_arabia_remote_data_source.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';

import 'player.dart';
import 'widgets/snackbar.dart';

class Tarnemma {
  final String title;
  final String duration;
  final String author;
  final String id;
  String? downloadUrl;
  final String thumbnail;
  final HymnSource source;
  final String? lyrics;

  static final DownloadManagerService _downloads = DownloadManagerService();

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
    this.source = HymnSource.youtube,
    this.lyrics,
  }) {
    try {
      if (OfflineStorageService().isDownloaded(id)) downloadProcess.value = DownloadTaskStatus.complete;
    } catch (_) {} // storage box not open (e.g. in tests)
  }

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
      duration: hymn.duration != null ? formatDuration(hymn.duration!) : '',
      downloadUrl: hymn.audioUrl,
      source: hymn.source,
      lyrics: hymn.lyrics,
    );
  }

  /// "0:03:30" -> "03:30"; keeps hours when present.
  static String formatDuration(Duration d) {
    final s = d.toString().split('.').first;
    return s.startsWith('0:') ? s.substring(2) : s;
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

  /// Offline search: only downloaded hymns can play without a connection.
  static List<Tarnemma> filterDownloaded(List<DownloadedHymn> downloaded, String query) {
    final q = HybridHymnsRepositoryImpl.normalizeTitle(query);
    return [
      for (final d in downloaded)
        if (HybridHymnsRepositoryImpl.normalizeTitle('${d.title} ${d.singer ?? ''}').contains(q))
          Tarnemma.fromHymn(d.toHymn()),
    ];
  }

  static Future<List<Tarnemma>> _searchYouTubeOnly(String query) async {
    final hymns = await YouTubeAudioResolver.searchVideos(query);
    return hymns.map(Tarnemma.fromHymn).toList();
  }

  static String sanitizeFileName(String input) {
    return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  Future<void> play() async {
    await Player.playTarnemma(this);
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

  /// Same in-app download as the album / singer / player screens, so the file
  /// lands in app storage and shows up under "الترانيم المحملة".
  Future<void> download() async {
    final status = downloadProcess.value;
    if (status == DownloadTaskStatus.running || status == DownloadTaskStatus.enqueued) return;

    final hasInternet = await InternetConnectionChecker().hasConnection;
    if (!hasInternet) {
      showCustomSnackbar(
        "لا يوجد اتصال",
        "تأكد من الاتصال بالإنترنت لبدء التحميل",
        Icons.wifi_off,
      );
      return;
    }

    downloadProcess.value = DownloadTaskStatus.running;
    showCustomSnackbar("بدء التحميل", "جاري تحميل ترنيمة: $title", Icons.downloading);
    try {
      await _downloads.downloadHymn(toHymn(), storageService: OfflineStorageService());
      downloadProcess.value = DownloadTaskStatus.complete;
      showCustomSnackbar("تم التحميل", "تم تحميل ترنيمة: $title", Icons.check_circle_outline);
    } catch (e) {
      if (kDebugMode) print("Download error: $e");
      downloadProcess.value = DownloadTaskStatus.failed;
      showCustomSnackbar("خطأ في التحميل", "تعذر تحميل ترنيمة: $title", Icons.error_outline);
    }
  }
}
