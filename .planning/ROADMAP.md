# Roadmap: Tarneemna App Modernization

## Milestone 1: Flutter Migration (Completed)
- [x] **Phase 1: SDK & Dependency Modernization**
- [x] **Phase 2: Android Build Configuration Modernization**
- [x] **Phase 3: Dart Code Quality & Analyzer Warning Fixes**
- [x] **Phase 4: Full Verification & Build Validation**

---

## Milestone 2: Modern Player, Offline Library, Lyrics & Taranim Arabia Integration (Active)

### Phase 5: Taranim Arabia Engine & Hybrid Content Service
- Build scrapers/services for `taranimarabia.org` (Search, Song Details, MP3 stream, Lyrics, Singers, Albums, Hymn of the Day).
- Create a unified `Hymn` model supporting both Taranim Arabia and YouTube Explode.
- Add local persistence layer (Hive / SharedPreferences) for caching song metadata.

### Phase 6: Modern Audio Service & Background Playback
- Integrate `audio_service` with `just_audio` for system background playback.
- Implement Android notification media controls and lock screen art/controls.
- Implement Playback Queue (Up Next) with reordering and continuous autoplay.
- Add Sleep Timer (مؤقت النوم), A-B Repeat loop, and Crossfade.

### Phase 7: Full-Screen Draggable Player & Interactive Lyrics
- Build Spotify-style draggable bottom-sheet player with high-res artwork, seeker, volume/speed.
- Build synchronized/static lyrics viewer with typography scaling and dark mode.
- Add Hymn Quote Card generator (مشاركة كبطاقة صورة) and timestamp sharing.

### Phase 8: Offline Downloads Library & Storage Manager
- Build dedicated "ترانيمي المحملة" (Offline Downloads) library screen with offline playback.
- Add one-click bulk/batch download for full albums and playlists with progress indicator.
- Add auto-download favorites on Wi-Fi.
- Build Storage Manager (view storage usage, delete files, clear cache).
- Add MP3 file export/sharing to WhatsApp and local files.

### Phase 9: Dynamic Discovery Home, Albums & Singers Catalog
- Redesign Home screen with dynamic sections: Hymn of the Day, Popular Albums, Featured Singers, Recently Played.
- Build Singers & Bands catalog screen (`/allsingers` and singer details).
- Build Full Albums screen (`/albums` and album details).
- Build Endless Hymn Radio (راديو متواصل).

### Phase 10: Smart Search, Voice Search & Personal Library
- Unified search with lyrics search (البحث بكلمات الترنيمة) and instant chips.
- Add Voice Search (البحث الصوتي) using device speech-to-text.
- Build Personal Library: 1-tap Favorites ❤️, Custom Playlists, History, Most Played.
- Add in-app "Request a Missing Hymn" form.

### Phase 11: Theming (OLED Black), Accessibility & Widgets
- Add true OLED Dark Mode + Custom spiritual accent themes.
- Add senior/accessibility font scaling controls.
- Add Android Home Screen Widget for quick playback control.
