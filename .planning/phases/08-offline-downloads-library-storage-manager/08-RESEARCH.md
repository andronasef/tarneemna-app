# Phase 8 Research: Offline Downloads Library & Storage Manager

## Storage and Download Patterns

### 1. Storage Paths
- `path_provider.getApplicationDocumentsDirectory()` provides persistent app storage on both iOS and Android.
- Audio files directory: `${docDir.path}/downloads/audio/${hymnId}.mp3`.
- File size formatting: helper method converting bytes to KB / MB with 1 decimal place (`12.4 MB`).

### 2. File Download Engine
- For Taranim Arabia direct URLs: `http.Client().send(http.Request('GET', Uri.parse(url)))` streaming bytes to `File.openWrite()`, updating bytes received / contentLength for accurate progress calculation.
- For YouTube Explode: `yt.videos.streamsClient.get(audioStreamInfo)` piped to file stream.

### 3. Hive Download Registry
- Box name: `downloaded_hymns`.
- Schema:
  ```json
  {
    "id": "123",
    "title": "...",
    "singer": "...",
    "album": "...",
    "artworkUrl": "...",
    "localFilePath": "/.../downloads/audio/123.mp3",
    "fileSizeBytes": 4512310,
    "downloadedAt": "2026-10-04T...",
    "lyrics": "...",
    "source": "taranimar"
  }
  ```

### 4. AudioHandler Local File Playback
- `just_audio` natively supports `AudioSource.file(localPath)` or `player.setFilePath(localPath)`.
- When `TarneemnaAudioHandler.skipToQueueItem` is called:
  - Check `OfflineStorageManager.getLocalHymn(id)`.
  - If local file exists, `_player.setFilePath(localPath)` is used instead of network URL.
