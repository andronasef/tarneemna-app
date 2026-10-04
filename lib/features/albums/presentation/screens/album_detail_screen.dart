import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/downloads/presentation/providers/download_providers.dart';
import 'package:tarneemna/features/taranim_arabia/presentation/providers/taranim_arabia_providers.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final String albumId;
  final String albumTitle;
  final String? singerName;
  final String? artworkUrl;

  const AlbumDetailScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
    this.singerName,
    this.artworkUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(albumSongsProvider(albumId));
    final audioHandler = ref.watch(audioHandlerProvider);
    final storageService = ref.watch(offlineStorageServiceProvider);
    final downloadManager = ref.watch(downloadManagerServiceProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(albumTitle),
        ),
        body: songsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('تعذر تحميل ترانيم ألبوم $albumTitle', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(albumSongsProvider(albumId)),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (songs) {
            if (songs.isEmpty) {
              return const Center(
                child: Text('لا توجد ترانيم متاحة لهذا الألبوم', style: TextStyle(color: Colors.grey)),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: artworkUrl != null
                              ? Image.network(
                                  artworkUrl!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 600,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/icon.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset('assets/icon.png', fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          albumTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        if (singerName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            singerName!,
                            style: const TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${songs.length} ترنيمة',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('تشغيل الألبوم كاملاً'),
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
