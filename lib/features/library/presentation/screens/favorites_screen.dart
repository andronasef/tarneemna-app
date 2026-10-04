import 'package:tarneemna/screens/home/widgets/miniplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/library/presentation/providers/library_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesListProvider);
    final audioHandler = ref.watch(audioHandlerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الترانيم المفضلة'),
          actions: [
            if (favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Chip(
                    label: Text('${favorites.length} ترنيمة'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ),
          ],
        ),
        body: favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 72,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد ترانيم في المفضلة بعد',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اضغط على أيقونة القلب في المشغل لإضافة ترنيمتك هنا',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text('تشغيل الكل (${favorites.length})'),
                            onPressed: () => audioHandler.playQueue(favorites, startIndex: 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.shuffle_rounded),
                          tooltip: 'تشغيل عشوائي',
                          onPressed: () {
                            final shuffled = List.of(favorites)..shuffle();
                            audioHandler.playQueue(shuffled, startIndex: 0);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (ctx, idx) {
                        final hymn = favorites[idx];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${idx + 1}'),
                          ),
                          title: Text(
                            hymn.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: hymn.singer != null
                              ? Text(hymn.singer!, maxLines: 1, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            tooltip: 'إزالة من المفضلة',
                            onPressed: () async {
                              await ref
                                  .read(favoritesListProvider.notifier)
                                  .toggleFavorite(hymn);
                            },
                          ),
                          onTap: () => audioHandler.playQueue(favorites, startIndex: idx),
                        );
                      },
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }
}
