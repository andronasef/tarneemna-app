import 'package:tarneemna/features/taranim_arabia/data/sources/taranim_arabia_remote_data_source.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:just_audio/just_audio.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/library/data/sources/personal_library_service.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';
import 'package:tarneemna/widgets/snackbar.dart';

class TarneemnaAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;
  final OfflineStorageService? _offlineStorageService;
  final PersonalLibraryService? _personalLibraryService;
  Future<void> Function(MediaItem? currentItem)? onAutoPlay;
  int _currentIndex = -1;
  // Bumped on every track load so a slow, superseded load can't start playing.
  int _loadGen = 0;
  final _rng = Random();
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _durationSubscription;

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

    // Position is NOT broadcast per tick: PlaybackState carries updatePosition + speed,
    // so the notification extrapolates it. Per-tick broadcasts flooded the platform
    // channel and rebuilt every playbackState listener ~60x/sec.
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
        'chordsUrl': hymn.chordsUrl,
        'notesUrl': hymn.notesUrl,
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
      chordsUrl: extras['chordsUrl'] as String?,
      notesUrl: extras['notesUrl'] as String?,
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

  @override
  Future<void> removeQueueItemAt(int index) async {
    final list = List<MediaItem>.from(queue.value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      // Publish the new queue first: skipToQueueItem reads queue.value.
      queue.add(list);
      if (_currentIndex > index) {
        _currentIndex--;
      } else if (_currentIndex == index) {
        if (list.isEmpty) {
          await stop();
        } else {
          await skipToQueueItem(min(_currentIndex, list.length - 1));
        }
      }
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final list = queue.value;
    if (index < 0 || index >= list.length) return;

    _currentIndex = index;
    final gen = ++_loadGen;
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
          if (gen == _loadGen) await _player.play();
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
        if (gen == _loadGen) await _player.play();
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
        if (gen != _loadGen) return;
      }
    }

    if (audioUrl == null || audioUrl.isEmpty) {
      if (kDebugMode) print('Could not resolve audio URL for track ${item.title}');
      _reportPlaybackError(item);
      return;
    }

    try {
      await _player.stop();
      await _player.setUrl(audioUrl);
      if (gen == _loadGen) await _player.play();
    } catch (e) {
      if (kDebugMode) print('Player error playing track: $e');
      if (gen == _loadGen) _reportPlaybackError(item);
    }
  }

  void _reportPlaybackError(MediaItem item) {
    showCustomSnackbar('تعذر التشغيل', 'لم نتمكن من تشغيل «${item.title}»', Icons.error_outline);
  }

  @override
  Future<void> skipToNext() async {
    final length = queue.value.length;
    if (playbackState.value.shuffleMode != AudioServiceShuffleMode.none && length > 1) {
      var next = _rng.nextInt(_currentIndex < 0 ? length : length - 1);
      if (_currentIndex >= 0 && next >= _currentIndex) next++; // never repeat the current track
      await skipToQueueItem(next);
    } else if (_currentIndex + 1 < length) {
      await skipToQueueItem(_currentIndex + 1);
    } else if (playbackState.value.repeatMode == AudioServiceRepeatMode.all && queue.value.isNotEmpty) {
      await skipToQueueItem(0);
    } else {
      await _triggerAutoPlayNext();
    }
  }

  Future<void> _triggerAutoPlayNext() async {
    if (onAutoPlay != null) {
      try {
        await onAutoPlay!(mediaItem.value);
        return;
      } catch (e) {
        if (kDebugMode) print('Auto-play callback error: $e');
      }
    }

    try {
      final remoteSource = TaranimArabiaRemoteDataSource();
      final randomHymn = await remoteSource.getHymnOfTheDay();
      if (randomHymn != null) {
        final item = hymnToMediaItem(randomHymn);
        final list = List<MediaItem>.from(queue.value)..add(item);
        queue.add(list);
        await skipToQueueItem(list.length - 1);
      }
    } catch (e) {
      if (kDebugMode) print('Default auto-play error: $e');
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
    _loadGen++; // cancel any in-flight track load
    await _player.stop();
    _currentIndex = -1;
    mediaItem.add(null);
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // The player holds one track at a time, so LoopMode.all would just loop it.
    // Queue-level repeat is handled in skipToNext.
    await _player.setLoopMode(
      repeatMode == AudioServiceRepeatMode.one ? LoopMode.one : LoopMode.off,
    );
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    // Shuffle is applied in skipToNext; the player only ever holds one track.
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'setSpeed') {
      final speed = (extras?['speed'] as num?)?.toDouble() ?? 1.0;
      await setSpeed(speed);
      return;
    }
    return super.customAction(name, extras);
  }

  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _playbackEventSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _player.dispose();
  }
}
