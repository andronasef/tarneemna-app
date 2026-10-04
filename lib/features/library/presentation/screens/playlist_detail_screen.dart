import 'package:tarneemna/screens/home/widgets/miniplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/library/domain/entities/playlist.dart';
import 'package:tarneemna/features/library/presentation/providers/library_providers.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsListProvider);
    final currentPlaylist = playlists.firstWhere(
      (p) => p.id == playlist.id,
      orElse: () => playlist,
    );
    final audioHandler = ref.watch(audioHandlerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentPlaylist.name),
        ),
        body: currentPlaylist.hymns.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue_music_outlined,
                      size: 72,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'هذه القائمة فارغة حالياً',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'أضف ترانيم إلى القائمة أثناء الاستماع',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('تشغيل القائمة (${currentPlaylist.hymns.length} ترنيمة)'),
                        onPressed: () {
                          audioHandler.playQueue(currentPlaylist.hymns, startIndex: 0);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentPlaylist.hymns.length,
                      itemBuilder: (ctx, idx) {
                        final hymn = currentPlaylist.hymns[idx];
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
                          subtitle: hymn.singer != null ? Text(hymn.singer!) : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            tooltip: 'حذف من القائمة',
                            onPressed: () async {
                              await ref
                                  .read(playlistsListProvider.notifier)
                                  .removeHymn(currentPlaylist.id, hymn.id);
                            },
                          ),
                          onTap: () => audioHandler.playQueue(currentPlaylist.hymns, startIndex: idx),
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
