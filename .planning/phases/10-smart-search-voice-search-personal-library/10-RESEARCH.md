# Phase 10 Research: Smart Search, Voice Search & Personal Library

## Patterns and Best Practices

### 1. Personal Library Hive Schemas
- `user_favorites`: Stores Map of Hymn data keyed by `hymn.id`.
- `user_playlists`: Stores Playlist metadata + list of Hymn maps:
  ```dart
  class Playlist {
    final String id;
    final String name;
    final DateTime createdAt;
    final List<Hymn> hymns;
  }
  ```
- `playback_history`: List of Hymn maps capped at 50 tracks with unique ID deduplication.

### 2. Arabic Normalization Engine
- Re-use / extend `ArabicNormalizer` to handle:
  - Remove Tashkeel: `[\u064B-\u0652\u0670]`
  - Standardize Alef: `[أإآٱ]` -> `ا`
  - Standardize Yaa: `[ىئ]` -> `ي`
  - Standardize Haa/Taa: `[ة]` -> `ه`
  - Remove non-word punctuation.

### 3. Audio Handler Hook
- In `TarneemnaAudioHandler.playHymn(hymn)`, invoke `playbackHistoryService.record(hymn)`.
