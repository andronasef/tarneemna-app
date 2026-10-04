import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/audio/domain/services/ab_repeat_controller.dart';
import 'package:tarneemna/features/audio/domain/services/sleep_timer_service.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/library/presentation/providers/library_providers.dart';
import 'package:tarneemna/features/lyrics/presentation/widgets/lyrics_bottom_sheet.dart';
import 'package:tarneemna/features/lyrics/presentation/widgets/quote_card_dialog.dart';
import 'package:tarneemna/features/lyrics/presentation/widgets/sheet_music_modal.dart';

class FullPlayerView extends ConsumerWidget {
  final VoidCallback? onCollapse;

  const FullPlayerView({super.key, this.onCollapse});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final mediaItemAsync = ref.watch(currentMediaItemStreamProvider);
    final playbackStateAsync = ref.watch(playbackStateStreamProvider);
    final positionAsync = ref.watch(audioPositionStreamProvider);

    final currentItem = mediaItemAsync.value;
    final playbackState = playbackStateAsync.value;
    final currentPosition = positionAsync.value ?? Duration.zero;

    if (currentItem == null) {
      return const Scaffold(
        body: Center(child: Text('لا توجد ترنيمة قيد التشغيل حالياً')),
      );
    }

    final totalDuration = currentItem.duration ?? Duration.zero;
    final isPlaying = playbackState?.playing ?? false;
    final maxSec = totalDuration.inSeconds.toDouble();
    final currentSec = currentPosition.inSeconds.toDouble().clamp(0.0, maxSec > 0 ? maxSec : 1.0);
    final isFavorite = ref.watch(isFavoriteProvider(currentItem.id));
    final currentHymn = TarneemnaAudioHandler.mediaItemToHymn(currentItem);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Column(
                        children: [
                          // Top App Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                                tooltip: 'تصغير المشغل',
                                onPressed: onCollapse ?? () => Navigator.of(context).maybePop(),
                              ),
                              Text(
                                'المشغل الموسيقي',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.speed_rounded),
                                tooltip: 'سرعة التشغيل',
                                onPressed: () => _showSpeedSelector(context, audioHandler),
                              ),
                            ],
                          ),
                          const Spacer(flex: 1),

                          // Artwork
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.72,
                              height: MediaQuery.of(context).size.width * 0.72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: (currentItem.artUri != null && currentItem.artUri.toString().isNotEmpty)
                                  ? Image.network(
                                      currentItem.artUri.toString(),
                                      fit: BoxFit.cover,
                                      cacheWidth: 600,
                                      cacheHeight: 600,
                                      errorBuilder: (_, __, ___) => _buildArtworkFallback(context),
                                    )
                                  : _buildArtworkFallback(context),
                            ),
                          ),
                          const Spacer(flex: 1),

                          // Title, Artist, Favorite & Playlist Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentItem.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentItem.artist ?? 'ترانيم عربية',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[400],
                                            fontSize: 15,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                  size: 28,
                                ),
                                tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                                onPressed: () async {
                                  await ref.read(favoritesListProvider.notifier).toggleFavorite(currentHymn);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.playlist_add, size: 28),
                                tooltip: 'إضافة لقائمة تشغيل',
                                onPressed: () => _showAddToPlaylistDialog(context, ref, currentHymn),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Seeker Bar
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            ),
                            child: Slider(
                              value: currentSec,
                              min: 0.0,
                              max: maxSec > 0 ? maxSec : 1.0,
                              onChanged: (val) {
                                audioHandler.seek(Duration(seconds: val.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(currentPosition),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  _formatDuration(totalDuration),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 1),

                          // Main Playback Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Shuffle
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  color: playbackState?.shuffleMode == AudioServiceShuffleMode.all
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  final next = playbackState?.shuffleMode == AudioServiceShuffleMode.all
                                      ? AudioServiceShuffleMode.none
                                      : AudioServiceShuffleMode.all;
                                  audioHandler.setShuffleMode(next);
                                },
                              ),
                              // Skip Previous
                              IconButton(
                                icon: const Icon(Icons.skip_previous_rounded, size: 36),
                                onPressed: () => audioHandler.skipToPrevious(),
                              ),
                              // Play / Pause FAB
                              FloatingActionButton.large(
                                elevation: 4,
                                onPressed: () {
                                  if (isPlaying) {
                                    audioHandler.pause();
                                  } else {
                                    audioHandler.play();
                                  }
                                },
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 42,
                                ),
                              ),
                              // Skip Next
                              IconButton(
                                icon: const Icon(Icons.skip_next_rounded, size: 36),
                                onPressed: () => audioHandler.skipToNext(),
                              ),
                              // Repeat Mode
                              IconButton(
                                icon: Icon(
                                  playbackState?.repeatMode == AudioServiceRepeatMode.one
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_rounded,
                                  color: playbackState?.repeatMode != AudioServiceRepeatMode.none
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  final mode = playbackState?.repeatMode;
                                  final next = mode == AudioServiceRepeatMode.none
                                      ? AudioServiceRepeatMode.all
                                      : mode == AudioServiceRepeatMode.all
                                          ? AudioServiceRepeatMode.one
                                          : AudioServiceRepeatMode.none;
                                  audioHandler.setRepeatMode(next);
                                },
                              ),
                            ],
                          ),
                          const Spacer(flex: 1),

                          // Secondary Tools Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Sleep Timer
                              IconButton(
                                icon: const Icon(Icons.bedtime_outlined),
                                tooltip: 'مؤقت النوم',
                                onPressed: () => _showSleepTimerSheet(context, ref),
                              ),
                              // A-B Repeat
                              IconButton(
                                icon: const Icon(Icons.loop_rounded),
                                tooltip: 'تكرار مقطع (A-B)',
                                onPressed: () => _showAbRepeatDialog(context, ref, currentPosition),
                              ),
                              // Interactive Lyrics
                              IconButton(
                                icon: const Icon(Icons.lyrics_outlined),
                                tooltip: 'كلمات الترنيمة',
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => LyricsBottomSheet(hymn: currentHymn),
                                  );
                                },
                              ),
                              // Sheet Music / Chords
                              IconButton(
                                icon: const Icon(Icons.music_note_outlined),
                                tooltip: 'النوتة الموسيقية والكوردات',
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) => SheetMusicModal(hymn: currentHymn),
                                  );
                                },
                              ),
                              // Quote Card Generator
                              IconButton(
                                icon: const Icon(Icons.format_quote_rounded),
                                tooltip: 'بطاقة اقتباس',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => QuoteCardDialog(hymn: currentHymn),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/icon.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.music_note_rounded,
          size: 64,
          color: Colors.amber,
        ),
      ),
    );
  }

  void _showSpeedSelector(BuildContext context, TarneemnaAudioHandler audioHandler) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('سرعة التشغيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ...speeds.map((s) => ListTile(
                    title: Text('${s}x', textAlign: TextAlign.center),
                    onTap: () {
                      audioHandler.setSpeed(s);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showSleepTimerSheet(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(sleepTimerNotifierProvider);
    final timerNotifier = ref.read(sleepTimerNotifierProvider.notifier);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('مؤقت النوم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (timerState.isActive)
                ListTile(
                  leading: const Icon(Icons.timer_off, color: Colors.red),
                  title: Text(
                    'إلغاء المؤقت (متبقي ${timerState.remainingTime != null ? (timerState.remainingTime!.inSeconds / 60).ceil() : 0} دقيقة)',
                  ),
                  onTap: () {
                    timerNotifier.cancelTimer();
                    Navigator.pop(ctx);
                  },
                ),
              ...[15, 30, 45, 60].map(
                (mins) => ListTile(
                  leading: const Icon(Icons.timer),
                  title: Text('$mins دقيقة'),
                  onTap: () {
                    timerNotifier.setTimerMinutes(mins);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAbRepeatDialog(BuildContext context, WidgetRef ref, Duration currentPos) {
    final abState = ref.watch(abRepeatNotifierProvider);
    final abNotifier = ref.read(abRepeatNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تكرار مقطع (A-B)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نقطة البداية A: ${abState.pointA != null ? _formatDuration(abState.pointA!) : "غير محددة"}'),
            const SizedBox(height: 8),
            Text('نقطة النهاية B: ${abState.pointB != null ? _formatDuration(abState.pointB!) : "غير محددة"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              abNotifier.setPointA(currentPos);
              Navigator.pop(ctx);
            },
            child: const Text('تعيين A هنا'),
          ),
          TextButton(
            onPressed: () {
              abNotifier.setPointB(currentPos);
              Navigator.pop(ctx);
            },
            child: const Text('تعيين B هنا'),
          ),
          TextButton(
            onPressed: () {
              abNotifier.clear();
              Navigator.pop(ctx);
            },
            child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref, Hymn currentHymn) {
    final playlists = ref.watch(playlistsListProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة لقائمة تشغيل'),
        content: SizedBox(
          width: double.maxFinite,
          child: playlists.isEmpty
              ? const Text('لا توجد قوائم تشغيل حالياً، يمكنك إنشاء قائمة من شاشة قوائم التشغيل.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (_, idx) {
                    final p = playlists[idx];
                    return ListTile(
                      leading: const Icon(Icons.queue_music),
                      title: Text(p.name),
                      subtitle: Text('${p.hymns.length} ترنيمة'),
                      onTap: () async {
                        await ref.read(playlistsListProvider.notifier).addHymn(p.id, currentHymn);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تمت إضافة "${currentHymn.title}" إلى "${p.name}"')),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
