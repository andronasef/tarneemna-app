# Phase 5: Taranim Arabia Engine & Hybrid Content Service - Context

**Gathered:** 2026-10-04
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase delivers the complete Taranim Arabia content engine AND the foundational Clean Architecture migration. It replaces the existing GetX-based `Tarnemma` model with a unified `Hymn` domain entity, implements all 7 taranimarabia.org endpoints (Search, Song Details, direct MP3 URL, Lyrics, Singers, Albums, Hymn of the Day), builds the hybrid search service that merges Taranim Arabia + YouTube results, and establishes the feature-first clean architecture structure that all subsequent phases will follow.

</domain>

<decisions>
## Implementation Decisions

### Taranim Arabia Client Architecture
- HTTP scraping with `http` + `html` packages — direct HTML parsing, no API key needed
- Feature-first Clean Architecture: `lib/features/taranim_arabia/{data,domain,presentation}/`
- State management: Riverpod AsyncNotifier + StateNotifier — replaces GetX throughout
- Local persistence: Hive for song metadata cache — fast, Flutter-native

### Unified Hymn Model Design
- Model named `Hymn` — clean domain entity that replaces `Tarnemma`
- Source discriminated by `HymnSource` enum (taranimar, youtube) — typed, exhaustive switching
- Lyrics as nullable `String? lyrics` — fetched lazily on demand
- Full migration: all existing `Tarnemma` usages migrated to `Hymn` in Phase 5 — clean break

### taranimarabia.org Scraping Scope
- All 7 endpoints implemented in Phase 5: Search, Song Details, MP3 URL, Lyrics, Singers, Albums, Hymn of the Day
- MP3 URL extraction: parse direct MP3 href from song detail page HTML
- Error handling: throw `TaranimalArabiaException` — caught by hybrid service, falls back to YouTube
- Search ranking: Taranim Arabia results first, YouTube results appended deduped

### Clean Architecture Migration Scope
- Phase 5 delivers: full GetX → Riverpod migration of existing code + new Taranim Arabia feature built clean
- Folder structure: `lib/features/{feature}/{data,domain,presentation}/` — features: hymns, player, search, downloads, home, library
- Dependency injection: Riverpod Providers only — no extra DI library (Riverpod IS the DI)
- Router: migrate to `go_router` — declarative, deep-link ready, Flutter best practice

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `resolveVisionOsAudio()` in `lib/tarnemma.dart` — VISIONOS Innertube client for YouTube audio (keep this logic, wrap in new data layer)
- `lib/widgets/snackbar.dart` — custom Arabic snackbar widget (reuse)
- `lib/core/theme.dart` — theme data (keep, extend)
- `lib/core/routes.dart` — route constants (replace with go_router routes)
- `android/` — download manager setup with `flutter_downloader` (keep)

### Established Patterns
- Currently GetX with `.obs` reactive fields and `Get.find<Controller>()` — MIGRATING to Riverpod
- Static factory methods on model (`search()`, `getAudioUrl()`) — move to repository/use case layer
- `cairo` Arabic font via `google_fonts` — continue using
- HTTP calls: existing Innertube raw `HttpClient` calls — wrap in `http` package for new service

### Integration Points
- `lib/main.dart` — wrap app in `ProviderScope` (Riverpod root)
- `lib/app/app.dart` — replace `GetMaterialApp` with `MaterialApp.router` + `go_router`
- `lib/player.dart` — audio player controller; will become `features/player/` in a later phase; stub bridge for now
- `pubspec.yaml` — add: `flutter_riverpod`, `riverpod_annotation`, `go_router`, `hive_flutter`, `html`, `http` (if not present)

</code_context>

<specifics>
## Specific Ideas

- **Full GetX → Riverpod migration**: User wants a clean architecture with Riverpod across the whole project, starting here in Phase 5. This is a cross-cutting concern that applies to all remaining phases.
- All new features from Phase 6 onward should follow the `lib/features/{feature}/{data,domain,presentation}/` structure established here.

</specifics>

<deferred>
## Deferred Ideas

- Singers catalog UI screen — deferred to Phase 9 (Discovery & Home)
- Albums screen UI — deferred to Phase 9
- Endless Hymn Radio using singers data — deferred to Phase 9
- Voice search — deferred to Phase 10
</deferred>
