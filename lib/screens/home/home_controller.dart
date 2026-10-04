import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/features/search/data/sources/search_history_service.dart';

import '../../tarnemma.dart';
import '../../widgets/snackbar.dart';

class HomeController extends GetxController {
  final RxList<Tarnemma> traneem = <Tarnemma>[].obs;
  late final TextEditingController songText;
  final RxString songTextObs = "".obs;
  final RxBool loading = false.obs;
  Timer? _debounceTimer;
  final SearchHistoryService _searchHistoryService = SearchHistoryService();

  @override
  void onInit() {
    super.onInit();
    songText = TextEditingController();
    songText.addListener(() {
      songTextObs.value = songText.text;
    });
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    songText.dispose();
    super.onClose();
  }

  void onSearchChanged(String text) {
    _debounceTimer?.cancel();
    final queryText = text.trim();
    if (queryText.isEmpty) {
      traneem.clear();
      return;
    }
    if (queryText.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        query(queryText);
      });
    }
  }

  Future<void> query(String searchQuery) async {
    _debounceTimer?.cancel();
    final queryText = searchQuery.trim();
    if (queryText.isEmpty) {
      showCustomSnackbar(
        "تنبيه",
        "يرجى كتابة اسم الترنيمة للبحث",
        Icons.search,
      );
      return;
    }

    if (songText.text != queryText) {
      songText.text = queryText;
    }

    loading.value = true;
    try {
      if (kDebugMode) print("Querying YouTube for: $queryText");
      // Record query in search history
      _searchHistoryService.addQuery(queryText);
      final results = await Tarnemma.search(queryText);
      if (kDebugMode) print("Results received: ${results.length}");
      traneem.assignAll(results);
    } catch (e) {
      if (kDebugMode) print("Query error: $e");
      showCustomSnackbar(
        "خطأ",
        "تعذر استرجاع نتائج البحث، يرجى المحاولة مرة أخرى",
        Icons.error_outline,
      );
    } finally {
      loading.value = false;
    }
  }

  void updateDownloadStatus(
    String taskId,
    DownloadTaskStatus status,
    int progress,
  ) {
    for (final t in traneem) {
      if (t.taskId == taskId) {
        t.downloadProcess.value = status;
        t.downloadProgress.value = progress;
        if (status == DownloadTaskStatus.complete) {
          _registerCompletedDownload(t);
        }
        break;
      }
    }
  }

  Future<void> _registerCompletedDownload(Tarnemma t) async {
    try {
      final savedDir = await Tarnemma.getDownloadPath();
      final fileName = "${Tarnemma.sanitizeFileName(t.title)}.mp3";
      final filePath = '$savedDir/$fileName';
      final file = File(filePath);
      final size = file.existsSync() ? file.lengthSync() : 0;

      Duration? dur;
      if (t.duration.isNotEmpty) {
        final parts = t.duration.split(':').map((e) => int.tryParse(e) ?? 0).toList();
        if (parts.length == 2) {
          dur = Duration(minutes: parts[0], seconds: parts[1]);
        } else if (parts.length == 3) {
          dur = Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
        }
      }

      final hymn = DownloadedHymn(
        id: t.id,
        title: t.title,
        singer: t.author,
        album: null,
        artworkUrl: t.thumbnail,
        localFilePath: filePath,
        fileSizeBytes: size,
        downloadedAt: DateTime.now(),
        lyrics: t.lyrics,
        source: t.source,
        duration: dur,
      );
      final storageService = OfflineStorageService();
      await storageService.saveDownloadedHymn(hymn);
    } catch (e) {
      if (kDebugMode) print('Error registering completed download: $e');
    }
  }
}
