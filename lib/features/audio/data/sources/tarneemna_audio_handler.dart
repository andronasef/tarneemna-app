import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/library/data/sources/personal_library_service.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';

class TarneemnaAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;
  final OfflineStorageService? _offlineStorageService;
  final PersonalLibraryService? _personalLibraryService;
  int _currentIndex = -1;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;

  TarneemnaAudioHandler({
    AudioPlayer? player,
    OfflineStorageService? offlineStorageService,
    PersonalLibraryService? personalLibraryService,
  })  : _player = player ?? AudioPlayer(),
        _offlineStorageService = offlineStorageService,
        _personalLibraryService = personalLibraryService {
    _init();
  }

  AudioPlayer get player => _player;
  int get currentIndex => _currentIndex;

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      if (kDebugMode) print('AudioSession config error: $e');
    }

    _playbackEventSubscription = _player.playbackEventStream.listen(
      _broadcastPlaybackState,
      onError: (Object e, StackTrace st) {
        if (kDebugMode) print('PlaybackEventStream error: $e');
      },
    );

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      _broadcastPlaybackState(_player.playbackEvent);
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });

    _durationSubscription = _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (current != null && duration != null && current.duration != duration) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });

    _positionSubscription = _player.positionStream.listen((_) {
      _broadcastPlaybackState(_player.playbackEvent);
    });

    _bufferedPositionSubscription = _player.bufferedPositionStream.listen((_) {
      _broadcastPlaybackState(_player.playbackEvent);
    });
  }

  void _broadcastPlaybackState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = _currentIndex;
    final hasPrevious = queueIndex > 0;
    final hasNext = queueIndex >= 0 && queueIndex < queue.value.length - 1;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (hasPrevious) MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          if (hasNext) MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setSpeed,
          MediaAction.setRepeatMode,
          MediaAction.setShuffleMode,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: queueIndex >= 0 ? queueIndex : null,
      ),
    );
  }

  static MediaItem hymnToMediaItem(Hymn hymn) {
    return MediaItem(
      id: hymn.id,
      title: hymn.title,
      artist: hymn.singer ?? (hymn.source == HymnSource.taranimar ? 'ترانيم عربية' : 'غير معروف'),
      album: hymn.album ?? 'ترانيمنا',
      artUri: hymn.artworkUrl != null ? Uri.tryParse(hymn.artworkUrl!) : null,
      duration: hymn.duration,
      extras: {
        'source': hymn.source.name,
        'audioUrl': hymn.audioUrl,
        'lyrics': hymn.lyrics,
        'singerId': hymn.singerId,
        'albumId': hymn.albumId,
      },
    );
  }

  static Hymn mediaItemToHymn(MediaItem item) {
    final extras = item.extras ?? {};
    final sourceName = extras['source'] as String? ?? HymnSource.youtube.name;
    final source = sourceName == HymnSource.taranimar.name
        ? HymnSource.taranimar
        : HymnSource.youtube;

    return Hymn(
      id: item.id,
      title: item.title,
      singer: item.artist,
      album: item.album,
      artworkUrl: item.artUri?.toString(),
      duration: item.duration,
      audioUrl: extras['audioUrl'] as String?,
      lyrics: extras['lyrics'] as String?,
      singerId: extras['singerId'] as String?,
      albumId: extras['albumId'] as String?,
      source: source,
    );
  }

  Future<void> playHymn(Hymn hymn) async {
    final item = hymnToMediaItem(hymn);
    final currentList = List<MediaItem>.from(queue.value);
    final existingIdx = currentList.indexWhere((m) => m.id == item.id);

    if (existingIdx != -1) {
      await skipToQueueItem(existingIdx);
      return;
    }

    currentList.add(item);
    queue.add(currentList);
    await skipToQueueItem(currentList.length - 1);
  }

  Future<void> playQueue(List<Hymn> hymns, {int startIndex = 0}) async {
    if (hymns.isEmpty) return;
    final items = hymns.map(hymnToMediaItem).toList();
    queue.add(items);
    final safeIndex = (startIndex >= 0 && startIndex < items.length) ? startIndex : 0;
    await skipToQueueItem(safeIndex);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final list = List<MediaItem>.from(queue.value)..add(mediaItem);
    queue.add(list);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final list = List<MediaItem>.from(queue.value)..addAll(mediaItems);
    queue.add(list);
  }

  Future<void> addToQueue(Hymn hymn) async {
    await addQueueItem(hymnToMediaItem(hymn));
  }

  Future<void> playNext(Hymn hymn) async {
    final item = hymnToMediaItem(hymn);
    final list = List<MediaItem>.from(queue.value);
    final insertIndex = (_currentIndex >= 0 && _currentIndex < list.length)
        ? _currentIndex + 1
        : list.length;
    list.insert(insertIndex, item);
    queue.add(list);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    final list = List<MediaItem>.from(queue.value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      if (_currentIndex > index) {
        _currentIndex--;
      } else if (_currentIndex == index) {
        if (list.isEmpty) {
          await stop();
          _currentIndex = -1;
          mediaItem.add(null);
        } else {
          final nextIdx = _currentIndex >= list.length ? list.length - 1 : _currentIndex;
          _currentIndex = nextIdx;
          await skipToQueueItem(_currentIndex);
        }
      }
      queue.add(list);
    }
  }

  Future<void> removeFromQueue(int index) => removeQueueItemAt(index);

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    final list = List<MediaItem>.from(queue.value);
    if (oldIndex < 0 || oldIndex >= list.length || newIndex < 0 || newIndex >= list.length) return;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    queue.add(list);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) => moveQueueItem(oldIndex, newIndex);

  @override
  Future<void> skipToQueueItem(int index) async {
    final list = queue.value;
    if (index < 0 || index >= list.length) return;

    _currentIndex = index;
    final item = list[index];
    mediaItem.add(item);

    // Record playback history
    _personalLibraryService?.recordPlayback(mediaItemToHymn(item));

    // 1. Check for offline local file
    final storage = _offlineStorageService;
    if (storage != null && storage.isDownloaded(item.id)) {
      final downloaded = storage.getDownloadedHymn(item.id);
      if (downloaded != null && File(downloaded.localFilePath).existsSync()) {
        try {
          await _player.stop();
          await _player.setFilePath(downloaded.localFilePath);
          await _player.play();
          return;
        } catch (e) {
          if (kDebugMode) print('Local file playback error: $e');
        }
      }
    }

    // Resolve audio URL
    String? audioUrl = item.extras?['audioUrl'] as String?;
    final sourceName = item.extras?['source'] as String? ?? '';

    // If audioUrl is already a local file path
    if (audioUrl != null && audioUrl.startsWith('/') && File(audioUrl).existsSync()) {
      try {
        await _player.stop();
        await _player.setFilePath(audioUrl);
        await _player.play();
        return;
      } catch (e) {
        if (kDebugMode) print('File path playback error: $e');
      }
    }

    if (audioUrl == null || audioUrl.isEmpty) {
      if (sourceName == HymnSource.taranimar.name) {
        audioUrl = 'https://taranimarabia.org/music/${item.id}.mp3';
      } else {
        audioUrl = await YouTubeAudioResolver.getAudioUrl(item.id);
      }
    }

    if (audioUrl == null || audioUrl.isEmpty) {
      if (kDebugMode) print('Could not resolve audio URL for track ${item.title}');
      return;
    }

    try {
      await _player.stop();
      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('Player error playing track: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex + 1 < queue.value.length) {
      await skipToQueueItem(_currentIndex + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 4) {
      await seek(Duration.zero);
    } else if (_currentIndex > 0) {
      await skipToQueueItem(_currentIndex - 1);
    } else {
      await seek(Duration.zero);
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.none => LoopMode.off,
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all => LoopMode.all,
      AudioServiceRepeatMode.group => LoopMode.all,
    };
    await _player.setLoopMode(loopMode);
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode != AudioServiceShuffleMode.none;
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'setSpeed') {
      final speed = (extras?['speed'] as num?)?.toDouble() ?? 1.0;
      await setSpeed(speed);
      return;
    }
    if (name == 'moveQueueItem') {
      final oldIndex = extras?['oldIndex'] as int? ?? 0;
      final newIndex = extras?['newIndex'] as int? ?? 0;
      await moveQueueItem(oldIndex, newIndex);
      return;
    }
    return super.customAction(name, extras);
  }

  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _playbackEventSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _bufferedPositionSubscription?.cancel();
    await _player.dispose();
  }
}
