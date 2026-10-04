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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.songText,
              textInputAction: TextInputAction.search,
              onChanged: controller.onSearchChanged,
              onSubmitted: (_) => _performSearch(context),
              decoration: InputDecoration(
                hintText: "اكتب اسم الترنيمة...",
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.music_note_rounded),
                suffixIcon: Obx(
                  () => controller.songTextObs.value.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.songText.clear();
                            controller.traneem.clear();
                          },
                          icon: const Icon(Icons.clear),
                          tooltip: "مسح",
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _performSearch(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 20),
                SizedBox(width: 4),
                Text(
                  "بحث",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
