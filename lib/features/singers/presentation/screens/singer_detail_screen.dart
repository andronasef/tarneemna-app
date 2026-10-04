import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/downloads/presentation/providers/download_providers.dart';
import 'package:tarneemna/features/taranim_arabia/presentation/providers/taranim_arabia_providers.dart';

class SingerDetailScreen extends ConsumerWidget {
  final String singerId;
  final String singerName;

  const SingerDetailScreen({
    super.key,
    required this.singerId,
    required this.singerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(singerSongsProvider(singerId));
    final audioHandler = ref.watch(audioHandlerProvider);
    final storageService = ref.watch(offlineStorageServiceProvider);
    final downloadManager = ref.watch(downloadManagerServiceProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(singerName),
        ),
        body: songsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('تعذر تحميل ترانيم $singerName', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(singerSongsProvider(singerId)),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (songs) {
            if (songs.isEmpty) {
              return const Center(
                child: Text('لا توجد ترانيم متاحة لهذا المرنم حالياً', style: TextStyle(color: Colors.grey)),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.person, size: 52),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          singerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${songs.length} ترنيمة',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('تشغيل كل الترانيم'),
                            onPressed: () => audioHandler.playQueue(songs, startIndex: 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, idx) {
                      final hymn = songs[idx];
                      final isDownloaded = ref.watch(isHymnDownloadedProvider(hymn.id));

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${idx + 1}'),
                        ),
                        title: Text(hymn.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: hymn.album != null ? Text(hymn.album!) : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDownloaded)
                              const Icon(Icons.check_circle, color: Colors.green, size: 22)
                            else
                              IconButton(
                                icon: const Icon(Icons.download_for_offline_outlined),
                                tooltip: 'تحميل للاستماع بدون إنترنت',
                                onPressed: () async {
                                  try {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('بدأ تحميل «${hymn.title}»...')),
                                    );
                                    await downloadManager.downloadHymn(
                                      hymn,
                                      storageService: storageService,
                                    );
                                    ref.invalidate(downloadedHymnsListProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('تم اكتمال تحميل «${hymn.title}»')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('فشل تحميل «${hymn.title}»')),
                                      );
                                    }
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.play_circle_outline),
                              onPressed: () => audioHandler.playHymn(hymn),
                            ),
                          ],
                        ),
                        onTap: () => audioHandler.playHymn(hymn),
                      );
                    },
                    childCount: songs.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
