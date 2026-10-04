import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

import 'tarnemma.dart';

class Player {
  static TarneemnaAudioHandler? _audioHandler;

  static TarneemnaAudioHandler get audioHandler {
    _audioHandler ??= TarneemnaAudioHandler();
    return _audioHandler!;
  }

  static set audioHandler(TarneemnaAudioHandler handler) {
    _audioHandler = handler;
  }

  static AudioPlayer get player => audioHandler.player;

  static final RxString currentSongTitle = "".obs;
  static final RxString currentSongId = "".obs;
  static final RxBool isPlaying = false.obs;
  static final RxBool isBuffering = false.obs;
  static Hymn? currentHymn;
  static bool _initialized = false;

  static void init([TarneemnaAudioHandler? handler]) {
    if (handler != null) {
      _audioHandler = handler;
    }
    if (_initialized) return;
    _initialized = true;

    audioHandler.playbackState.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == AudioProcessingState.buffering ||
          state.processingState == AudioProcessingState.loading;
    });

    audioHandler.mediaItem.listen((item) {
      if (item != null) {
        currentSongTitle.value = item.title;
        currentSongId.value = item.id;
        currentHymn = TarneemnaAudioHandler.mediaItemToHymn(item);
      } else {
        currentSongTitle.value = "";
        currentSongId.value = "";
        currentHymn = null;
      }
    });
  }

  static Future<void> playHymn(Hymn hymn) async {
    init();
    await audioHandler.playHymn(hymn);
  }

  static Future<void> playTarnemma(Tarnemma song) async {
    await playHymn(song.toHymn());
  }

  static void play() {
    init();
    audioHandler.play();
  }

  static void pause() {
    audioHandler.pause();
  }

  static void stop() {
    audioHandler.stop();
  }

  static void seekTo(Duration position) {
    audioHandler.seek(position);
  }

  static void back5() {
    seekTo(player.position - const Duration(seconds: 5));
  }

  static void forward5() {
    seekTo(player.position + const Duration(seconds: 5));
  }

  static void seekForward() {
    seekTo(player.position + const Duration(seconds: 10));
  }

  static void seekBackward() {
    seekTo(player.position - const Duration(seconds: 10));
  }
}
