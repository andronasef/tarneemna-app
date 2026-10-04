import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/audio/domain/services/ab_repeat_controller.dart';
import 'package:tarneemna/features/audio/domain/services/sleep_timer_service.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/lyrics/presentation/widgets/lyrics_bottom_sheet.dart';
import 'package:tarneemna/features/lyrics/presentation/widgets/sheet_music_modal.dart';
import 'package:tarneemna/features/lyrics/presentation/widgets/quote_card_dialog.dart';

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
    final currentItem = ref.watch(currentMediaItemStreamProvider).asData?.value;
    final isPlaying = ref.watch(isPlayingProvider);
    final isBuffering = ref.watch(isBufferingProvider);
    final position = ref.watch(audioPositionStreamProvider).asData?.value ?? Duration.zero;
    final duration = ref.watch(audioDurationStreamProvider).asData?.value ??
        currentItem?.duration ??
        Duration.zero;
    final currentHymn = ref.watch(currentHymnStreamProvider).asData?.value;
    final sleepState = ref.watch(sleepTimerNotifierProvider);
    final abState = ref.watch(abRepeatNotifierProvider);

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    final double maxSec = duration.inSeconds.toDouble();
    final double currentSec = position.inSeconds.toDouble().clamp(0.0, maxSec > 0 ? maxSec : 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, size: 30),
                      onPressed: onCollapse,
                    ),
                    Text(
                      currentItem.album ?? 'ترانيمنا',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showSpeedSelector(context, audioHandler),
                    ),
                  ],
                ),
                const Spacer(flex: 1),

                // Artwork
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.width * 0.75,
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
                    child: currentItem.artUri != null
                        ? Image.network(
                            currentItem.artUri.toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/icon.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/icon.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const Spacer(flex: 1),

                // Title & Artist
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentItem.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentItem.artist ?? 'ترانيم عربية',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Main Playback Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle, size: 24),
                      onPressed: () {
                        // Toggle shuffle
                        final state = ref.read(playbackStateStreamProvider).asData?.value;
                        final isShuffled = state?.shuffleMode == AudioServiceShuffleMode.all;
                        audioHandler.setShuffleMode(isShuffled
                            ? AudioServiceShuffleMode.none
                            : AudioServiceShuffleMode.all);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, size: 36),
                      onPressed: () => audioHandler.skipToPrevious(),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isBuffering
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                                onPressed: () {
                                  if (isPlaying) {
                                    audioHandler.pause();
                                  } else {
                                    audioHandler.play();
                                  }
                                },
                              ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, size: 36),
                      onPressed: () => audioHandler.skipToNext(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat_rounded, size: 24),
                      onPressed: () {
                        // Toggle repeat
                        final state = ref.read(playbackStateStreamProvider).asData?.value;
                        final currentRepeat = state?.repeatMode ?? AudioServiceRepeatMode.none;
                        final nextRepeat = switch (currentRepeat) {
                          AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
                          AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
                          _ => AudioServiceRepeatMode.none,
                        };
                        audioHandler.setRepeatMode(nextRepeat);
                      },
                    ),
                  ],
                ),
                const Spacer(flex: 1),

                // Utility Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Sleep Timer
                    IconButton(
                      icon: Icon(
                        Icons.bedtime_outlined,
                        color: sleepState.isActive ? Colors.amber : Colors.grey,
                      ),
                      tooltip: 'مؤقت النوم',
                      onPressed: () => _showSleepTimerDialog(context, ref),
                    ),
                    // A-B Repeat Loop
                    IconButton(
                      icon: Icon(
                        Icons.repeat_one_on_outlined,
                        color: abState.isActive ? Colors.greenAccent : Colors.grey,
                      ),
                      tooltip: 'تكرار مقطع (A-B)',
                      onPressed: () => _showAbRepeatDialog(context, ref, position),
                    ),
                    // Lyrics Viewer
                    IconButton(
                      icon: const Icon(Icons.lyrics_outlined, color: Colors.grey),
                      tooltip: 'الكلمات',
                      onPressed: () {
                        if (currentHymn != null) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => LyricsBottomSheet(hymn: currentHymn),
                          );
                        }
                      },
                    ),
                    // Sheet Music & Chords
                    IconButton(
                      icon: const Icon(Icons.music_note_outlined, color: Colors.grey),
                      tooltip: 'نوتة وكوردات',
                      onPressed: () {
                        if (currentHymn != null) {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => SheetMusicModal(hymn: currentHymn),
                          );
                        }
                      },
                    ),
                    // Quote Card Generator
                    IconButton(
                      icon: const Icon(Icons.format_quote_outlined, color: Colors.grey),
                      tooltip: 'مشاركة كبطاقة صورة',
                      onPressed: () {
                        if (currentHymn != null) {
                          showDialog(
                            context: context,
                            builder: (_) => QuoteCardDialog(hymn: currentHymn),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSpeedSelector(BuildContext context, TarneemnaAudioHandler audioHandler) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('سرعة التشغيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              for (final speed in [0.75, 1.0, 1.25, 1.5, 2.0])
                ListTile(
                  title: Text('${speed}x'),
                  trailing: (audioHandler.player.speed == speed) ? const Icon(Icons.check) : null,
                  onTap: () {
                    audioHandler.setSpeed(speed);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sleepTimerNotifierProvider.notifier);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('مؤقت النوم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              ListTile(
                leading: const Icon(Icons.timer_10),
                title: const Text('15 دقيقة'),
                onTap: () {
                  notifier.setTimerMinutes(15);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_3),
                title: const Text('30 دقيقة'),
                onTap: () {
                  notifier.setTimerMinutes(30);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('45 دقيقة'),
                onTap: () {
                  notifier.setTimerMinutes(45);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('60 دقيقة'),
                onTap: () {
                  notifier.setTimerMinutes(60);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_off),
                title: const Text('عند نهاية الترنيمة الحالية'),
                onTap: () {
                  notifier.setEndOfTrack();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: const Text('إيقاف المؤقت', style: TextStyle(color: Colors.red)),
                onTap: () {
                  notifier.cancelTimer();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbRepeatDialog(BuildContext context, WidgetRef ref, Duration position) {
    final abState = ref.read(abRepeatNotifierProvider);
    final notifier = ref.read(abRepeatNotifierProvider.notifier);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تكرار مقطع (A-B)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Text(
                  'النقطة A: ${abState.pointA != null ? _formatDuration(abState.pointA!) : "غير محددة"}\n'
                  'النقطة B: ${abState.pointB != null ? _formatDuration(abState.pointB!) : "غير محددة"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        notifier.setPointA(position);
                        Navigator.pop(ctx);
                      },
                      child: const Text('تحديد A هنا'),
                    ),
                    ElevatedButton(
                      onPressed: abState.hasPointA
                          ? () {
                              notifier.setPointB(position);
                              Navigator.pop(ctx);
                            }
                          : null,
                      child: const Text('تحديد B هنا'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        notifier.clear();
                        Navigator.pop(ctx);
                      },
                      child: const Text('مسح'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
