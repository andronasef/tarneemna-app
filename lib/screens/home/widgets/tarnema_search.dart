import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class TarnemaSearch extends StatelessWidget {
  const TarnemaSearch({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  void _performSearch(BuildContext context) {
    FocusScope.of(context).unfocus();
    controller.query(controller.songText.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOled = theme.scaffoldBackgroundColor == Colors.black;

    // Distinct container background for high visibility across all themes
    final fillColor = isOled
        ? const Color(0xFF161616)
        : isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9);

    final borderColor = isOled
        ? Colors.white.withValues(alpha: 0.16)
        : isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.black.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller.songText,
              textInputAction: TextInputAction.search,
              onChanged: controller.onSearchChanged,
              onSubmitted: (_) => _performSearch(context),
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "اكتب اسم الترنيمة...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black45,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.music_note_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                suffixIcon: Obx(
                  () => controller.songTextObs.value.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.songText.clear();
                            controller.traneem.clear();
                          },
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          tooltip: "مسح",
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.8,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: isDark ? 0 : 1,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _performSearch(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_rounded, size: 20),
                SizedBox(width: 4),
                Text(
                  "بحث",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
