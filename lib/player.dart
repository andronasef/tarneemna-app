import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class Player {
  static RxString currentSongTitle = "".obs;
  static final player = AudioPlayer(); // Create a player
  static RxBool isPlaying = false.obs;

  static playUrl({title, url}) async {
    Player.currentSongTitle.value = title;
    player.setUrl(url);
    player.play();
    Player.isPlaying.value = true;
  }

  static void play() {
    player.play();
    Player.isPlaying.value = true;
  }

  static void stop() {
    Player.isPlaying.value = false;
    player.stop();
  }

  static void forward5() {
    player.seek(Duration(seconds: player.position.inSeconds + 5));
  }

  static void back5() {
    player.seek(Duration(seconds: player.position.inSeconds - 5));
  }
}
