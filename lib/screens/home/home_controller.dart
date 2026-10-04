import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

import '../../tarnemma.dart';
import '../../widgets/snackbar.dart';

class HomeController extends GetxController {
  final RxList<Tarnemma> traneem = <Tarnemma>[].obs;
  late final TextEditingController songText;
  final RxString songTextObs = "".obs;
  final RxBool loading = false.obs;
  Timer? _debounceTimer;

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
        break;
      }
    }
  }
}
