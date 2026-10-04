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
          final isMini = percentage < 0.2;

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
                    final singerName = hymn?.singer;

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
                              cacheWidth: 100,
                              cacheHeight: 100,
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
                              if (hasSong && singerName != null && singerName.isNotEmpty)
                                Text(
                                  singerName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (hasSong) ...[
                          if (isBuffering)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 30,
                              ),
                              onPressed: () {
                                if (isPlaying) {
                                  Player.pause();
                                } else {
                                  Player.play();
                                }
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 22),
                            onPressed: () => Player.stop(),
                            tooltip: "إيقاف",
                          ),
                        ],
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
