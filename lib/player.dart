import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import 'tarnemma.dart';
import 'widgets/snackbar.dart';

class Player {
  static final AudioPlayer player = AudioPlayer();
  static final RxString currentSongTitle = "".obs;
  static final RxString currentSongId = "".obs;
  static final RxBool isPlaying = false.obs;
  static final RxBool isBuffering = false.obs;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    player.playerStateStream.listen((state) {
      final bool playing = state.playing;
      final ProcessingState processingState = state.processingState;

      isBuffering.value = processingState == ProcessingState.buffering ||
          processingState == ProcessingState.loading;

      if (processingState == ProcessingState.completed) {
        isPlaying.value = false;
      } else {
        isPlaying.value = playing;
      }
    }, onError: (Object e) {
      if (kDebugMode) print("Player state stream error: $e");
      isPlaying.value = false;
      isBuffering.value = false;
    });

    player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        if (kDebugMode) print("Playback error: $e");
        isPlaying.value = false;
        isBuffering.value = false;
      },
    );
  }

  static Future<void> playTarnemma(Tarnemma song) async {
    init();

    // Toggle play/pause if tapping the current song
    if (currentSongId.value == song.id && player.audioSource != null) {
      if (isPlaying.value) {
        pause();
      } else {
        play();
      }
      return;
    }

    currentSongTitle.value = song.title;
    currentSongId.value = song.id;
    isBuffering.value = true;
    isPlaying.value = false;

    final url = await song.getAudioUrl();
    if (url == null || url.isEmpty) {
      isBuffering.value = false;
      showCustomSnackbar(
        "خطأ",
        "تعذر استخراج رابط الصوت للتشغيل",
        Icons.error_outline,
      );
      return;
    }

    try {
      await player.stop();
      await player.setUrl(url);
      await player.play();
    } catch (e) {
      if (kDebugMode) print("Error playing audio: $e");
      isBuffering.value = false;
      isPlaying.value = false;
      showCustomSnackbar(
        "خطأ",
        "تعذر تشغيل هذه الترنيمة في الوقت الحالي",
        Icons.error_outline,
      );
    }
  }

  static void play() {
    init();
    if (player.audioSource != null) {
      player.play();
    }
  }

  static void pause() {
    player.pause();
  }

  static void stop() {
    player.stop();
    isPlaying.value = false;
    isBuffering.value = false;
  }

  static void seekTo(Duration position) {
    if (position < Duration.zero) {
      player.seek(Duration.zero);
    } else if (player.duration != null && position > player.duration!) {
      player.seek(player.duration!);
    } else {
      player.seek(position);
    }
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
