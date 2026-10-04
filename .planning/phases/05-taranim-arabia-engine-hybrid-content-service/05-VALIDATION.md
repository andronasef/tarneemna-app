# Phase 5: Taranim Arabia Engine & Hybrid Content Service - Nyquist Validation Strategy

**Phase:** 5
**Status:** Defined

---

## 1. Test Architecture

### 1.1 Automated Test Execution Command
```bash
flutter test test/features/taranim_arabia/
```

### 1.2 Verification Checkpoints

1. **Parser & Data Source Unit Tests (`test/features/taranim_arabia/taranim_arabia_data_source_test.dart`):**
   - Test `searchSongs()` returns parsed list of search results with title, id, singer, artwork.
   - Test `getSongDetails()` extracts mp3 stream url, lyrics, album, artist, and sheet music.
   - Test `getSingers()` parses `/allsingers` items.
   - Test `getAlbums()` parses `/albums` items.
   - Test `getHymnOfTheDay()` parses homepage `.premium-item`.
   - Test HTTP error handling (e.g. 404, 500) throws `TaranimArabiaException`.

2. **Unified Model & Cache Tests (`test/features/hymns/hymn_model_test.dart`):**
   - Test `Hymn` factory constructors from Taranim Arabia and YouTube.
   - Test Hive box caching and retrieval.

3. **Hybrid Search Service Tests (`test/features/hymns/hybrid_hymns_service_test.dart`):**
   - Test Taranim Arabia results precede YouTube results.
   - Test deduplication logic.
   - Test YouTube fallback when Taranim Arabia encounters errors.

4. **Analyzer Check:**
   ```bash
   flutter analyze
   ```
   Must pass with 0 errors.
