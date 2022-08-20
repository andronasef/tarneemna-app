import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            const BoxDecoration(border: Border(top: BorderSide(width: .5))),
        height: 70,
        child: Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      Player.currentSongTitle.value.isEmpty
                          ? "لا يوجد ترنيمة قيد التشغيل"
                          : Player.currentSongTitle.value,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  const MIcon(Icons.forward_5, Player.forward5),
                  MIcon(Player.isPlaying.value ? Icons.pause : Icons.play_arrow,
                      Player.isPlaying.value ? Player.stop : Player.play),
                  const MIcon(Icons.replay_5, Player.back5),
                  // const SizedBox(
                  //   width: 10,
                  // )
                ],
              ),
            )));
  }
}

class MIcon extends StatelessWidget {
  final VoidCallback function;
  final IconData iconData;

  const MIcon(
    this.iconData,
    this.function, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
          iconSize: 26,
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          constraints: const BoxConstraints(),
          onPressed: Player.currentSongTitle.value.isEmpty ? null : function,
          icon: Icon(iconData)),
    );
  }
}
