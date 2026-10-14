import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tarneemna/features/search/data/sources/search_history_service.dart';

import 'package:tarneemna/core/connectivity.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';

import '../../tarnemma.dart';
import '../../widgets/snackbar.dart';

class HomeController extends GetxController {
  final RxList<Tarnemma> traneem = <Tarnemma>[].obs;
  late final TextEditingController songText;
  final RxString songTextObs = "".obs;
  final RxBool loading = false.obs;
  final RxInt recentSearchTick = 0.obs;
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
    songText.dispose();
    super.onClose();
  }

  Future<void> clearRecentSearches() async {
    await _searchHistoryService.clearAll();
    recentSearchTick.value++;
  }

  Future<void> query(String searchQuery) async {
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
      await _searchHistoryService.addQuery(queryText);
      recentSearchTick.value++;
      final offline = !Net.online.value;
      final results = offline
          ? Tarnemma.filterDownloaded(OfflineStorageService().getDownloadedHymns(), queryText)
          : await Tarnemma.search(queryText);
      if (offline && results.isEmpty) {
        showCustomSnackbar(
          "لا يوجد اتصال",
          "لا توجد نتائج بين الترانيم المحملة، اتصل بالإنترنت للبحث",
          Icons.wifi_off,
        );
      }
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
}
