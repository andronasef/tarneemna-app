import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/albums/presentation/screens/album_detail_screen.dart';
import 'package:tarneemna/features/albums/presentation/screens/albums_screen.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/downloads/presentation/screens/storage_manager_screen.dart';
import 'package:tarneemna/features/singers/presentation/screens/singer_detail_screen.dart';
import 'package:tarneemna/features/singers/presentation/screens/singers_screen.dart';
import 'package:tarneemna/features/taranim_arabia/presentation/providers/taranim_arabia_providers.dart';

class DiscoveryHeaderSection extends ConsumerWidget {
  const DiscoveryHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hymnOfDayAsync = ref.watch(hymnOfTheDayProvider);
    final singersAsync = ref.watch(singersListProvider);
    final albumsAsync = ref.watch(albumsListProvider);
    final audioHandler = ref.watch(audioHandlerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Action Chips (Offline Downloads & Storage)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ActionChip(
                  avatar: const Icon(Icons.cloud_download, color: Colors.blueAccent),
                  label: const Text('الترانيم المحملة'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OfflineDownloadsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionChip(
                  avatar: const Icon(Icons.storage, color: Colors.amber),
                  label: const Text('إدارة التخزين'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StorageManagerScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Hymn of the Day Hero Banner
        hymnOfDayAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (hymn) {
            if (hymn == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white12,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hymn.artworkUrl != null
                        ? Image.network(
                            hymn.artworkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset('assets/icon.png', fit: BoxFit.cover),
                          )
                        : Image.asset('assets/icon.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'ترنيمة اليوم',
                              style: TextStyle(
                                color: Colors.amber[200],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hymn.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hymn.singer != null)
                          Text(
                            hymn.singer!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    icon: const Icon(Icons.play_arrow_rounded, size: 30),
                    onPressed: () => audioHandler.playHymn(hymn),
                  ),
                ],
              ),
            );
          },
        ),

        // Featured Singers Carousel
        singersAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (singers) {
            if (singers.isEmpty) return const SizedBox.shrink();
            final topSingers = singers.take(10).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أبرز المرنمين وفرق التسبيح',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SingersScreen()),
                          );
                        },
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 104,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: topSingers.length,
                    itemBuilder: (ctx, idx) {
                      final singer = topSingers[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SingerDetailScreen(
                                singerId: singer.id,
                                singerName: singer.name,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: const Icon(Icons.person, size: 30),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                singer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),

        // Trending Albums Carousel
        albumsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (albums) {
            if (albums.isEmpty) return const SizedBox.shrink();
            final topAlbums = albums.take(8).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أحدث ألبومات الترانيم',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AlbumsScreen()),
                          );
                        },
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 155,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: topAlbums.length,
                    itemBuilder: (ctx, idx) {
                      final album = topAlbums[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlbumDetailScreen(
                                albumId: album.id,
                                albumTitle: album.title,
                                singerName: album.singerName,
                                artworkUrl: album.imageUrl,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 105,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 105,
                                height: 105,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: album.imageUrl != null
                                    ? Image.network(
                                        album.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Image.asset('assets/icon.png', fit: BoxFit.cover),
                                      )
                                    : Image.asset('assets/icon.png', fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                album.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              if (album.singerName != null)
                                Text(
                                  album.singerName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'جميع الترانيم والمقاطع',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
