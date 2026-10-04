import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tarneemna/features/search/data/sources/search_history_service.dart';

import '../../tarnemma.dart';
import '../../widgets/snackbar.dart';

class HomeController extends GetxController {
  final RxList<Tarnemma> traneem = <Tarnemma>[].obs;
  late final TextEditingController songText;
  final RxString songTextObs = "".obs;
  final RxBool loading = false.obs;
  final RxInt recentSearchTick = 0.obs;
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

  Future<void> clearRecentSearches() async {
    await _searchHistoryService.clearAll();
    recentSearchTick.value++;
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
      await _searchHistoryService.addQuery(queryText);
      recentSearchTick.value++;
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
}
