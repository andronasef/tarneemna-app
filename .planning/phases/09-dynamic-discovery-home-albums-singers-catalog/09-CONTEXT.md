# Phase 9 Context: Dynamic Discovery Home, Albums & Singers Catalog

## Objectives
Elevate Tarneemna's discovery experience by transforming the home screen into a rich, dynamic Christian worship hub featuring:
- Hero banner with Hymn of the Day (ترنيمة اليوم)
- Multi-lane horizontal carousels: Featured Singers (أبرز المرنمين), Trending Albums (ألبومات مميزة), and Quick Access (التحميلات، المفضلة).
- Dedicated Singers Directory screen with search and individual singer profile detail views (showing all hymns and albums).
- Dedicated Albums Catalog screen with cover grids and individual album detail views (showing tracklist and one-tap "تشغيل الألبوم").
- Offline resilience: If offline, smoothly render downloaded hymns and cached content with zero error screens.

## Locked Architectural Directives
1. **Repository & Data Access**:
   - `TaranimArabiaRemoteDataSource` already provides: `getHymnOfTheDay()`, `getSingers()`, `getAlbums()`, `getSingerSongs()`, `getAlbumSongs()`.
   - Riverpod `FutureProvider`s cache these queries with offline fallback to Hive (`LocalHymnCache`).
2. **Navigation & Routes**:
   - `/singers`: `SingersScreen` (Directory)
   - `/singers/:id`: `SingerDetailScreen`
   - `/albums`: `AlbumsScreen` (Catalog)
   - `/albums/:id`: `AlbumDetailScreen`
3. **UI / Design System**:
   - Consistent RTL typography, dark-friendly aesthetic, rounded card layouts.
   - Smooth transitions to `FullPlayerView` when tapping tracks.
