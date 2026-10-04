import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

final audioHandlerProvider = Provider<TarneemnaAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in ProviderScope');
});

final playbackStateStreamProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});

final currentMediaItemStreamProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});

final audioQueueStreamProvider = StreamProvider<List<MediaItem>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queue;
});

final currentHymnStreamProvider = StreamProvider<Hymn?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem.map((item) => item != null ? TarneemnaAudioHandler.mediaItemToHymn(item) : null);
});

final isPlayingProvider = Provider<bool>((ref) {
  final state = ref.watch(playbackStateStreamProvider).asData?.value;
  return state?.playing ?? false;
});

final isBufferingProvider = Provider<bool>((ref) {
  final state = ref.watch(playbackStateStreamProvider).asData?.value;
  return state?.processingState == AudioProcessingState.buffering ||
      state?.processingState == AudioProcessingState.loading;
});

final audioPositionStreamProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.positionStream;
});

final audioBufferedPositionStreamProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.bufferedPositionStream;
});

final audioDurationStreamProvider = StreamProvider<Duration?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.durationStream;
});
