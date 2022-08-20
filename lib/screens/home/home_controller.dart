import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../tarnemma.dart';
import '../../widgets/snackbar.dart';

class HomeController extends GetxController {
  List traneem = <Tarnemma>[].obs;
  TextEditingController songText =
      TextEditingController(text: kDebugMode ? "انا شاعر بيك" : "");
  RxBool loading = false.obs;

  void query(searchQuery) async {
    if (searchQuery.isNotEmpty) {
      loading.value = true;
      traneem.clear();
      traneem = await Tarnemma.search(searchQuery);
      loading.value = false;
    } else {
      showCustomSnackbar(
          "خطأ", "رجاء عدم ابقاء مربع البحث فارغا", Icons.text_snippet);
    }
  }
}
