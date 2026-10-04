import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/albums/presentation/screens/album_detail_screen.dart';
import 'package:tarneemna/features/albums/presentation/screens/albums_screen.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/downloads/presentation/screens/storage_manager_screen.dart';
import 'package:tarneemna/features/library/presentation/screens/favorites_screen.dart';
import 'package:tarneemna/features/library/presentation/screens/history_screen.dart';
import 'package:tarneemna/features/library/presentation/screens/playlists_screen.dart';
import 'package:tarneemna/features/settings/presentation/screens/settings_screen.dart';
import 'package:tarneemna/features/singers/presentation/screens/singer_detail_screen.dart';
import 'package:tarneemna/features/singers/presentation/screens/singers_screen.dart';
import 'package:tarneemna/features/taranim_arabia/presentation/providers/taranim_arabia_providers.dart';

class DiscoveryHeaderSection extends ConsumerWidget {
  const DiscoveryHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hymnOfDayAsync = ref.watch(hymnOfTheDayProvider);
    final singersAsync = ref.watch(randomizedSingersProvider);
    final albumsAsync = ref.watch(randomizedAlbumsProvider);
    final audioHandler = ref.watch(audioHandlerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Action Chips (Personal Library, Downloads & Settings)
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            children: [
              ActionChip(
                avatar: const Icon(Icons.favorite,
                    color: Colors.redAccent, size: 18),
                label: const Text('المفضلة'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.queue_music,
                    color: Colors.deepPurpleAccent, size: 18),
                label: const Text('قوائم التشغيل'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlaylistsScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.history, color: Colors.teal, size: 18),
                label: const Text('سجل الاستماع'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.cloud_download,
                    color: Colors.blueAccent, size: 18),
                label: const Text('الترانيم المحملة'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OfflineDownloadsScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar:
                    const Icon(Icons.storage, color: Colors.amber, size: 18),
                label: const Text('إدارة التخزين'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StorageManagerScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.palette_outlined,
                    color: Colors.indigoAccent, size: 18),
                label: const Text('المظهر والإعدادات'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ModernSettingsScreen()),
                  );
                },
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
            final hasArtwork =
                hymn.artworkUrl != null && hymn.artworkUrl!.trim().isNotEmpty;
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
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4)),
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
                    child: hasArtwork
                        ? Image.network(
                            hymn.artworkUrl!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) =>
                                _buildMusicNotePlaceholder(),
                          )
                        : _buildMusicNotePlaceholder(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "ترنيمة مختارة",
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
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
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
            final topSingers = singers;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أبرز المرنمين وفرق التسبيح',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SingersScreen()),
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
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: const Icon(Icons.person, size: 30),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                singer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
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

        // Browse Albums Carousel (Randomized)
        albumsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (displayedAlbums) {
            if (displayedAlbums.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'تصفح الألبومات',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AlbumsScreen()),
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
                    itemCount: displayedAlbums.length,
                    itemBuilder: (ctx, idx) {
                      final album = displayedAlbums[idx];
                      final hasAlbumImage = album.imageUrl != null &&
                          album.imageUrl!.trim().isNotEmpty;
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
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2)),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: hasAlbumImage
                                    ? Image.network(
                                        album.imageUrl!,
                                        fit: BoxFit.cover,
                                        cacheWidth: 200,
                                        cacheHeight: 200,
                                        errorBuilder: (_, __, ___) =>
                                            _buildAlbumMusicNotePlaceholder(),
                                      )
                                    : _buildAlbumMusicNotePlaceholder(),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                album.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              if (album.singerName != null)
                                Text(
                                  album.singerName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
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

  Widget _buildMusicNotePlaceholder() {
    return Container(
      color: Colors.white10,
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        size: 34,
        color: Colors.amber,
      ),
    );
  }

  Widget _buildAlbumMusicNotePlaceholder() {
    return Container(
      color: Colors.white10,
      alignment: Alignment.center,
      child: const Icon(
        Icons.album_rounded,
        size: 36,
        color: Colors.white54,
      ),
    );
  }
}
