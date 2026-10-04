import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:tarneemna/features/audio/presentation/widgets/full_player_view.dart';

import '../../../player.dart';

final MiniplayerController miniplayerController = MiniplayerController();

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Miniplayer(
        controller: miniplayerController,
        minHeight: 72,
        maxHeight: height,
        elevation: 8,
        curve: Curves.easeOutCubic,
        builder: (currentHeight, percentage) {
          final isMini = currentHeight <= 100;

          if (!isMini) {
            return FullPlayerView(
              onCollapse: () {
                miniplayerController.animateToHeight(state: PanelState.MIN);
              },
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (Player.currentSongTitle.value.isNotEmpty) {
                  miniplayerController.animateToHeight(state: PanelState.MAX);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(
                  () {
                    final hasSong = Player.currentSongTitle.value.isNotEmpty;
                    final isPlaying = Player.isPlaying.value;
                    final isBuffering = Player.isBuffering.value;
                    final hymn = Player.currentHymn;

                    return Row(
                      children: [
                        if (hasSong && hymn?.artworkUrl != null)
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              hymn!.artworkUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else if (hasSong)
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.music_note, color: Colors.white70),
                          ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasSong
                                    ? Player.currentSongTitle.value
                                    : "لا توجد ترنيمة قيد التشغيل",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: hasSong ? FontWeight.w600 : FontWeight.normal,
                                  color: hasSong ? null : Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hasSong && hymn?.singer != null)
                                Text(
                                  hymn!.singer!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          iconSize: 26,
                          onPressed: hasSong ? Player.back5 : null,
                          icon: const Icon(Icons.replay_5),
                          tooltip: "إرجاع 5 ثواني",
                        ),
                        if (isBuffering)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          )
                        else
                          IconButton(
                            iconSize: 36,
                            onPressed: hasSong
                                ? () {
                                    if (isPlaying) {
                                      Player.pause();
                                    } else {
                                      Player.play();
                                    }
                                  }
                                : null,
                            icon: Icon(
                              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              color: hasSong
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            tooltip: isPlaying ? "إيقاف مؤقت" : "تشغيل",
                          ),
                        IconButton(
                          iconSize: 26,
                          onPressed: hasSong ? Player.forward5 : null,
                          icon: const Icon(Icons.forward_5),
                          tooltip: "تقديم 5 ثواني",
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
