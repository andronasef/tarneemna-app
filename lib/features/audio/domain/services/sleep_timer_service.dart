import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';

enum SleepTimerMode { none, minutes }

class SleepTimerState {
  final SleepTimerMode mode;
  final Duration? remainingTime;
  final int? initialMinutes;

  const SleepTimerState({
    this.mode = SleepTimerMode.none,
    this.remainingTime,
    this.initialMinutes,
  });

  bool get isActive => mode != SleepTimerMode.none;

  SleepTimerState copyWith({
    SleepTimerMode? mode,
    Duration? remainingTime,
    int? initialMinutes,
  }) {
    return SleepTimerState(
      mode: mode ?? this.mode,
      remainingTime: remainingTime ?? this.remainingTime,
      initialMinutes: initialMinutes ?? this.initialMinutes,
    );
  }
}

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  final TarneemnaAudioHandler _audioHandler;
  Timer? _ticker;

  SleepTimerNotifier(this._audioHandler) : super(const SleepTimerState());

  void setTimerMinutes(int minutes) {
    cancelTimer();
    final duration = Duration(minutes: minutes);
    state = SleepTimerState(
      mode: SleepTimerMode.minutes,
      remainingTime: duration,
      initialMinutes: minutes,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.remainingTime;
      if (current == null || current.inSeconds <= 1) {
        _expireTimer();
      } else {
        state = state.copyWith(
          remainingTime: current - const Duration(seconds: 1),
        );
      }
    });
  }

  Future<void> _expireTimer() async {
    cancelTimer();
    try {
      // Fade out volume
      final initialVolume = _audioHandler.player.volume;
      for (int i = 5; i >= 0; i--) {
        await _audioHandler.player.setVolume(initialVolume * (i / 5));
        await Future.delayed(const Duration(milliseconds: 300));
      }
      await _audioHandler.pause();
      await _audioHandler.player.setVolume(initialVolume);
    } catch (_) {
      await _audioHandler.pause();
    }
  }

  void cancelTimer() {
    _ticker?.cancel();
    _ticker = null;
    state = const SleepTimerState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final sleepTimerNotifierProvider =
    StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return SleepTimerNotifier(handler);
});
