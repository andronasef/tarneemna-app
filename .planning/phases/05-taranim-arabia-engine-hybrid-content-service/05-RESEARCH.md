# Phase 5: Taranim Arabia Engine & Hybrid Content Service - Technical Research

**Phase:** 5
**Status:** Complete
**Target Architecture:** Clean Architecture (Feature-First) with Riverpod 2.x & GoRouter

---

## 1. Executive Summary

Phase 5 transitions Tarneemna App from a monolithic GetX prototype into an extensible, enterprise-grade Flutter architecture powered by Riverpod and GoRouter. It delivers the complete content engine for `taranimarabia.org` (scraping 7 core endpoints without any required API keys) and unifies it with YouTube audio into a single `Hymn` domain entity with Hive caching.

---

## 2. taranimarabia.org Analysis & Scraping Strategy

Live probe testing against `https://taranimarabia.org` confirmed high reliability, consistent HTML DOM patterns, and predictable URL schemas.

### 2.1 Scraping Endpoints & DOM Selectors

1. **Search (`/search?searchByWord={term}&searchBySinger=0`):**
   - **Method:** GET with URL-encoded Arabic text
   - **Container:** `.song-info-box` inside `.col-lg-6`
   - **Track Title:** `h4.text-right` inside `<a href="https://taranimarabia.org/song/{id}">`
   - **Song ID:** Extracted regex `r'/song/(\d+)'` from `href`
   - **Singer Name & ID:** `<p class="text-right">المرنم : <a href="https://taranimarabia.org/singer/{singerId}">{singerName}</a></p>`
   - **Artwork:** `img.float-right` with `src` attribute (e.g. `https://taranimarabia.org/images/album/{albumId}.jpg`)

2. **Song Details & Direct MP3 Stream (`/song/{id}`):**
   - **Audio Stream:** `<li track="https://taranimarabia.org/music/{id}.mp3" title="...">`
   - **Direct Stream Pattern:** Always maps to `https://taranimarabia.org/music/{id}.mp3`
   - **Lyrics:** `<div id="words{id}" class="container"><p dir="rtl" align="center">...</p></div>`
   - **Album Name & ID:** `<p class="text-right">الألبوم : <a href="https://taranimarabia.org/album/{albumId}">{albumName}</a></p>`
   - **Poet / Composer / Distributor:** Extracted from `<p class="text-right">` labels
   - **Chords & Sheet Music:** `https://taranimarabia.org/Files/Chords/{id}.pdf`, `https://taranimarabia.org/Files/MusicNotes/{id}.gif`

3. **Singers Directory (`/allsingers`) & Singer Details (`/singer/{id}`):**
   - **Directory:** `.playlist-item` containing `<a href="https://taranimarabia.org/singer/{id}">` with `<h4>{name}</h4>` and `<img>`
   - **Singer Page:** Contains playlist items of songs performed by that artist

4. **Albums Directory (`/albums`) & Album Details (`/album/{id}`):**
   - **Directory:** `.playlist-item` with `<a href="https://taranimarabia.org/album/{id}">` with `<h4>{title}</h4>` and `<img>`
   - **Album Page:** Contains list of tracks with direct links to `/song/{id}`

5. **Hymn of the Day / Featured (`/` homepage):**
   - **Container:** `.premium-item` on homepage
   - **Item:** Song link (`/song/{id}`), title, and artist link (`/singer/{id}`)

### 2.2 Error Handling & Resiliency
- Implement `TaranimArabiaException` hierarchy (`NetworkException`, `ParsingException`, `NotFoundException`).
- Add user-agent headers mimicking modern mobile browser to prevent bot blocks.
- Set a 10-second connection & receive timeout with `http.Client`.

---

## 3. Clean Architecture & Unified Model

### 3.1 Unified Domain Entity: `Hymn`
```dart
enum HymnSource { taranimar, youtube }

class Hymn {
  final String id;
  final String title;
  final String? singer;
  final String? singerId;
  final String? album;
  final String? albumId;
  final String? audioUrl;
  final String? lyrics;
  final String? artworkUrl;
  final Duration? duration;
  final HymnSource source;
  final Map<String, dynamic> metadata;
  ...
}
```

### 3.2 Hybrid Content Aggregation
- **Primary Source:** Taranim Arabia (lossless MP3 metadata + Arabic lyrics + album/singer relationships).
- **Secondary Source:** YouTube Explode (`resolveVisionOsAudio`) for hymns or recordings not found in Taranim Arabia or when the user seeks live choir performances.
- **Deduplication:** Fuzzy title normalization (stripping diacritics, punctuation, brackets) to prioritize Taranim Arabia direct MP3 over YouTube audio.

---

## 4. State Management & Navigation Migration

- **GetX -> Riverpod:**
  - Wrap app in `ProviderScope`.
  - Use `StateNotifier` / `AsyncNotifier` for async states.
  - Eliminate all `Get.to()`, `Get.find()`, `RxString`, `Obx`.
- **Navigation:**
  - Implement `GoRouter` with initial route `/home`, `/player`, `/settings`, and parameter routes `/song/:id`, `/singer/:id`, `/album/:id`.
- **Local Cache:**
  - Hive Box `hymns_cache` to store recently accessed hymns, lyrics, and metadata for instant offline-first display.

---

## 5. Verification Strategy

1. **Unit Tests:**
   - HTML parser tests against recorded fixture responses for search, song detail, allsingers, and albums.
   - Unified `Hymn` model serialization/deserialization.
   - Hybrid content service merging and deduplication logic.
2. **Integration Tests:**
   - Riverpod provider state changes.
   - GoRouter route transitions.
3. **Static Analysis:**
   - `flutter analyze` must pass with zero errors and zero warnings.
