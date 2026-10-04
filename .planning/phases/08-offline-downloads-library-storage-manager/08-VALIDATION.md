# Phase 8 Validation: Offline Downloads Library & Storage Manager

## Verification Criteria
1. **Downloaded Hymn Metadata & Registry**:
   - `DownloadedHymn` model serializes/deserializes with Hive.
   - Files are stored in persistent app documents directory.
   - Deletion removes both Hive record and file on disk.
2. **Offline-First Playback Resolver**:
   - `TarneemnaAudioHandler` detects local file presence and plays via `setFilePath`.
3. **Storage Metrics**:
   - Correctly calculates total bytes used by downloaded audio files and cache box.
   - Batch deletion cleans up all selected files.
4. **Code Quality**:
   - `flutter analyze` passes with 0 issues.
   - All tests pass in `test/features/downloads/`.
