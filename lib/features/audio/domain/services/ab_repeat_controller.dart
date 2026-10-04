import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';

class AbRepeatState {
  final Duration? pointA;
  final Duration? pointB;

  const AbRepeatState({this.pointA, this.pointB});

  bool get isActive => pointA != null && pointB != null;
  bool get hasPointA => pointA != null;

  AbRepeatState copyWith({
    Duration? pointA,
    Duration? pointB,
    bool clearB = false,
  }) {
    return AbRepeatState(
      pointA: pointA ?? this.pointA,
      pointB: clearB ? null : (pointB ?? this.pointB),
    );
  }
}

class AbRepeatNotifier extends StateNotifier<AbRepeatState> {
  final TarneemnaAudioHandler _audioHandler;
  StreamSubscription? _positionSub;

  AbRepeatNotifier(this._audioHandler) : super(const AbRepeatState());

  void setPointA([Duration? position]) {
    final pos = position ?? _audioHandler.player.position;
    state = AbRepeatState(pointA: pos, pointB: null);
    _cancelLoop();
  }

  void setPointB([Duration? position]) {
    final pos = position ?? _audioHandler.player.position;
    if (state.pointA == null) return;

    if (pos <= state.pointA!) {
      return; // Point B must be strictly after Point A
    }

    state = state.copyWith(pointB: pos);
    _startLoop();
  }

  void _startLoop() {
    _cancelLoop();
    final pA = state.pointA;
    final pB = state.pointB;
    if (pA == null || pB == null) return;

    _positionSub = _audioHandler.player.positionStream.listen((pos) {
      if (pos >= pB) {
        _audioHandler.seek(pA);
      }
    });
  }

  void _cancelLoop() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void clear() {
    _cancelLoop();
    state = const AbRepeatState();
  }

  @override
  void dispose() {
    _cancelLoop();
    super.dispose();
  }
}

final abRepeatNotifierProvider =
    StateNotifierProvider<AbRepeatNotifier, AbRepeatState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return AbRepeatNotifier(handler);
});
