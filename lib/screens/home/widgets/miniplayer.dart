import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(
        () {
          final hasSong = Player.currentSongTitle.value.isNotEmpty;
          final isPlaying = Player.isPlaying.value;
          final isBuffering = Player.isBuffering.value;

          return Row(
            children: [
              Expanded(
                child: Text(
                  hasSong
                      ? Player.currentSongTitle.value
                      : "لا توجد ترنيمة قيد التشغيل",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: hasSong ? FontWeight.w600 : FontWeight.normal,
                    color: hasSong ? null : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  iconSize: 32,
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
    );
  }
}
