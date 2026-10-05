# Roadmap: Tarneemna App Modernization

## Milestone 1: Flutter Migration (Completed)
- [x] **Phase 1: SDK & Dependency Modernization**
- [x] **Phase 2: Android Build Configuration Modernization**
- [x] **Phase 3: Dart Code Quality & Analyzer Warning Fixes**
- [x] **Phase 4: Full Verification & Build Validation**

---

## Milestone 2: Modern Player, Offline Library, Lyrics & Taranim Arabia Integration (Completed)

### Phase 5: Taranim Arabia Engine & Hybrid Content Service [Completed]
- [x] Build scrapers/services for `taranimarabia.org` (Search, Song Details, MP3 stream, Lyrics, Singers, Albums, Hymn of the Day).
- [x] Create a unified `Hymn` model supporting both Taranim Arabia and YouTube Explode.
- [x] Add local persistence layer (Hive / SharedPreferences) for caching song metadata.

### Phase 6: Modern Audio Service & Background Playback [Completed]
- [x] Integrate `audio_service` with `just_audio` for system background playback.
- [x] Implement Android notification media controls and lock screen art/controls.
- [x] Implement Playback Queue (Up Next) with reordering and continuous autoplay.
- [x] Add Sleep Timer (مؤقت النوم), A-B Repeat loop, and Crossfade.

### Phase 7: Full-Screen Draggable Player & Interactive Lyrics [Completed]
- [x] Build Spotify-style draggable bottom-sheet player with high-res artwork, seeker, volume/speed.
- [x] Build synchronized/static lyrics viewer with typography scaling and dark mode.
- [x] Add Hymn Quote Card generator (مشاركة كبطاقة صورة) and timestamp sharing.

### Phase 8: Offline Downloads Library & Storage Manager [Completed]
- [x] Build dedicated "ترانيمي المحملة" (Offline Downloads) library screen with offline playback.
- [x] Add one-click bulk/batch download for full albums and playlists with progress indicator.
- [x] Add auto-download favorites on Wi-Fi.
- [x] Build Storage Manager (view storage usage, delete files, clear cache).
- [x] Add MP3 file export/sharing to WhatsApp and local files.

### Phase 9: Dynamic Discovery Home, Albums & Singers Catalog [Completed]
- [x] Redesign Home screen with dynamic sections: Hymn of the Day, Popular Albums, Featured Singers, Recently Played.
- [x] Build Singers & Bands catalog screen (`/allsingers` and singer details).
- [x] Build Full Albums screen (`/albums` and album details).
- [x] Build Endless Hymn Radio (راديو متواصل).

### Phase 10: Smart Search, Voice Search & Personal Library [Completed]
- [x] Unified search with lyrics search (البحث بكلمات الترنيمة) and instant chips.
- [x] Add Voice Search (البحث الصوتي) using device speech-to-text.
- [x] Build Personal Library: 1-tap Favorites ❤️, Custom Playlists, History, Most Played.
- [x] Add in-app "Request a Missing Hymn" form.

### Phase 11: Theming (OLED Black), Accessibility & Widgets [Completed]
- [x] Add true OLED Dark Mode + Custom spiritual accent themes.
- [x] Add senior/accessibility font scaling controls.
- [x] Add Android Home Screen Widget for quick playback control.

### Phase 12: iOS Native Support, UI Adaptations & Platform Logic [Completed]
- [x] Scaffold official native iOS runner (`ios/`) with modern Swift Package Manager (SwiftPM) toolchain.
- [x] Configure `Info.plist` with background audio mode, ATS streaming permissions, and microphone/speech recognition strings.
- [x] Register iOS app in Firebase (`com.increase.tarneemna`), install `GoogleService-Info.plist`, and update `firebase_options.dart`.
- [x] Configure `AudioSession` for iOS background playback and lock-screen / Dynamic Island controls.
- [x] Adapt UI for iOS: notch/home-indicator safe area polish, native haptic feedback, and Cupertino transitions.
- [x] Validate full iOS build (`flutter build ios --no-codesign --simulator`) and analyzer.
