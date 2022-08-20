import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar(String title, String message, IconData icon) {
  if (!Get.isSnackbarOpen) {
    Get.snackbar(title, message,
        duration: 3.seconds,
        backgroundColor: Get.context!.theme.colorScheme.primary,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        boxShadows: [
          const BoxShadow(
              blurRadius: 5,
              color: Colors.black26,
              offset: Offset(3, 5),
              spreadRadius: 1)
        ],
        colorText: Colors.white,
        margin: const EdgeInsets.only(bottom: 20),
        padding: null,
        shouldIconPulse: false,
        maxWidth: Get.context!.width * .9,
        snackPosition: SnackPosition.BOTTOM);
  }
}
