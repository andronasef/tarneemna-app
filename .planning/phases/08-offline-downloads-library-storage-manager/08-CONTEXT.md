# Phase 8 Context: Offline Downloads Library & Storage Manager

## Objectives
Build a resilient offline downloads manager and storage system allowing users to download hymns (from both Taranim Arabia direct MP3s and YouTube audio), manage storage consumption with granular breakdowns, perform batch deletions, and play downloaded hymns completely offline with full metadata and lyrics.

## Locked Architectural Directives
1. **Downloaded Hymn Metadata & Local Storage**:
   - Store download metadata in a dedicated Hive box: `downloaded_hymns`.
   - Store downloaded audio files in the app's persistent documents directory (`path_provider.getApplicationDocumentsDirectory() / 'hymns_audio' / '{id}.mp3'`).
   - Store downloaded lyrics & cover images offline so the entire hymn experience is 100% functional without internet connectivity.
2. **Download Engine**:
   - `DownloadManagerService`: queues downloads, writes file directly to local storage, saves metadata into Hive box.
   - For Taranim Arabia tracks: downloads direct lossless MP3 from `hymn.audioUrl`.
   - For YouTube tracks: resolves audio stream via `YouTubeAudioResolver` and streams to local file.
   - Tracks download progress (`DownloadTask` with progress 0.0 to 1.0, status: pending, downloading, completed, failed).
3. **Offline Playback Routing**:
   - When playing a hymn, `TarneemnaAudioHandler` checks if `id` exists in `downloaded_hymns` Hive box and the local file exists on disk.
   - If found, loads `AudioSource.file(localPath)` directly, enabling instant zero-buffering offline playback.
4. **Storage Manager**:
   - Shows total app storage, hymns storage, cache size.
   - Allows selective batch deletion or one-tap "مسح كافة الترانيم المحملة".
