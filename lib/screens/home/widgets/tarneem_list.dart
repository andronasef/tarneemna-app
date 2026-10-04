import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:tarneemna/features/discovery/presentation/widgets/discovery_header_section.dart';
import 'package:tarneemna/features/search/data/sources/search_history_service.dart';

import '../../../player.dart';
import '../../../tarnemma.dart';
import '../home_controller.dart';

class TraneemList extends StatelessWidget {
  const TraneemList({
    super.key,
    required this.controller,
  });

  final HomeController controller;
  static final SearchHistoryService _searchHistoryService = SearchHistoryService();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(
      // Observe recentSearchTick so changes trigger a rebuild
      final _ = controller.recentSearchTick.value;

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "جاري البحث عن الترانيم...",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        );
      }

      if (controller.traneem.isEmpty) {
        const suggestions = [
          "انا شاعر بيك",
          "يسوع فادي النفس",
          "علمني انتظر الرب",
          "بارك بلادي",
          "يا صاحب الحنان",
        ];

        final recentQueries = _searchHistoryService.getQueries();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 95),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DiscoveryHeaderSection(),
              const SizedBox(height: 10),
              if (recentQueries.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "عمليات البحث الأخيرة:",
                            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => controller.clearRecentSearches(),
                            child: const Text('مسح', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recentQueries.take(6).map((q) {
                          return ActionChip(
                            label: Text(q),
                            avatar: const Icon(Icons.history, size: 16, color: Colors.grey),
                            onPressed: () => controller.query(q),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "اقتراحات سريعة للبحث:",
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.map((s) {
                        return ActionChip(
                          label: Text(s),
                          avatar: const Icon(Icons.search, size: 16),
                          onPressed: () => controller.query(s),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 95),
        physics: const ClampingScrollPhysics(),
        itemCount: controller.traneem.length,
        itemBuilder: (context, index) {
          final t = controller.traneem[index];
          return TraneemTile(tarnemma: t);
        },
      );
    });
  }
}

class TraneemTile extends StatelessWidget {
  final Tarnemma tarnemma;

  const TraneemTile({
    super.key,
    required this.tarnemma,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => tarnemma.play(),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: tarnemma.thumbnail.isNotEmpty
            ? Image.network(
                tarnemma.thumbnail,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                cacheWidth: 120,
                cacheHeight: 120,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.music_note, size: 32),
              )
            : const Icon(Icons.music_note, size: 32),
      ),
      title: Text(
        tarnemma.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        [tarnemma.author, tarnemma.duration].where((s) => s.isNotEmpty).join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Download action
          Obx(() {
            final status = tarnemma.downloadProcess.value;
            if (status == DownloadTaskStatus.complete) {
              return const IconButton(
                icon: Icon(Icons.check_circle, color: Colors.green),
                onPressed: null,
                tooltip: "تم التحميل",
              );
            } else if (status == DownloadTaskStatus.running ||
                status == DownloadTaskStatus.enqueued) {
              final progress = tarnemma.downloadProgress.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: progress > 0
                      ? CircularProgressIndicator(
                          value: progress / 100.0,
                          strokeWidth: 2.5,
                        )
                      : const CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            } else {
              return IconButton(
                onPressed: () => tarnemma.download(),
                icon: const Icon(Icons.download),
                tooltip: "تحميل",
              );
            }
          }),
          // Play / Pause action
          Obx(() {
            final isCurrentSong =
                Player.currentSongId.value == tarnemma.id;
            final isPlaying = isCurrentSong && Player.isPlaying.value;
            final isBuffering =
                (isCurrentSong && Player.isBuffering.value) ||
                tarnemma.isResolvingStream.value;

            if (isBuffering) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            }

            return IconButton(
              onPressed: () => tarnemma.play(),
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_arrow,
                color:
                    isPlaying ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: isPlaying ? "إيقاف مؤقت" : "تشغيل",
            );
          }),
        ],
      ),
    );
  }
}
