# Phase 6 Research: Modern Audio Service & Background Playback

## Audio Service & Just Audio Integration Patterns

### 1. Initialization and Lifecycle
- `AudioService.init` must be called before `runApp` (or lazily before audio playback) with:
  ```dart
  AudioHandler audioHandler = await AudioService.init(
    builder: () => TarneemnaAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.increase.tarneemna.audio',
      androidNotificationChannelName: 'تشغيل الترانيم',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
    ),
  );
  ```
- AudioSession setup:
  ```dart
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  ```

### 2. Playback State Synchronization
`just_audio` has:
- `player.playerStateStream`
- `player.playbackEventStream`
- `player.positionStream`
- `player.bufferedPositionStream`

These map directly to `audio_service`'s `playbackState.add(PlaybackState(...))` with:
- `controls`: `[MediaControl.skipToPrevious, MediaControl.play/pause, MediaControl.stop, MediaControl.skipToNext]`
- `systemActions`: `{MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward}`
- `androidCompactActionIndices`: `[0, 1, 3]`
- `processingState`: mapping `ProcessingState` to `AudioProcessingState`
- `playing`: `player.playing`
- `updatePosition`: `player.position`
- `bufferedPosition`: `player.bufferedPosition`
- `speed`: `player.speed`

### 3. MediaItem Mapping
`Hymn` maps to `MediaItem`:
```dart
MediaItem(
  id: hymn.id,
  album: hymn.album ?? 'ترانيمنا',
  title: hymn.title,
  artist: hymn.singer ?? 'ترانيم عربية',
  duration: hymn.duration,
  artUri: hymn.artworkUrl != null ? Uri.tryParse(hymn.artworkUrl!) : null,
  extras: {
    'source': hymn.source.name,
    'audioUrl': hymn.audioUrl,
  },
)
```

### 4. Sleep Timer & A-B Repeat
- **Sleep Timer**: A timer that runs down every second, emitting remaining `Duration?`. When timer expires, optionally fade volume to 0 over 3 seconds, then call `pause()`. If "end of track" option is selected, listen for `processingState == completed` or next track event, then stop.
- **A-B Repeat**: Monitored via `player.positionStream`. When position >= point B, execute `player.seek(pointA)`.

### 5. Android 14 Requirements
- Android 14 (API 34) enforces specific foreground service types:
  - `FOREGROUND_SERVICE_MEDIA_PLAYBACK` in manifest
  - `<service ... android:foregroundServiceType="mediaPlayback" />`
- `MainActivity` extending `AudioServiceActivity`.
