# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [2.0.2+7] - 2026-10-14

### Added
- Microsoft Clarity session analytics (`clarity_flutter`), wrapping the app in `ClarityWidget`.
- Firebase Crashlytics (`firebase_crashlytics`) for Flutter and platform errors, enabled in release builds only; Android Crashlytics Gradle plugin and an iOS dSYM upload build phase.

### Fixed
- iOS upload rejected (ITMS-90683): restored `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` in `Info.plist`, which `permission_handler` references even though the app does not record audio. Build number bumped to 2.0.1+5.

### Changed
- Settings: added WhatsApp contact link; rate and share now use the Increasing Labs promote page.
- Home search no longer runs as you type; it runs only on the search button or the keyboard's search key.
- iOS Firebase Analytics now builds without ad-ID (IDFA) support (`$FirebaseAnalyticsWithoutAdIdSupport`).
- Bundled privacy policy (`assets/md/tarneemna.md`) replaced with the new policy effective 2026-10-14 (CCPA/CPRA, AI, international transfers, retention, breach notification).
- YouTube search, playback, and downloads are disabled on iOS (App Store guidelines 5.2.2/5.2.3); iOS uses Taranim Arabia only. Android is unchanged.
- iOS `Info.plist` prepared for App Store review: removed unused microphone, speech recognition, and photo-library usage descriptions; dropped the `NSAllowsArbitraryLoads` ATS exception (all endpoints are HTTPS); declared `ITSAppUsesNonExemptEncryption = false` to skip the export-compliance prompt.

## [2.0.1] - 2026-10-05

### Added
- Official native iOS support (`ios/`) with background audio playback capability and audio session configuration.
- Native tactile haptic feedback across player controls, seeker bar scrubbing, favorites, and playlists.
- Adaptive UI elements including Cupertino activity indicator and edge-to-edge safe area styling under the iOS Home Indicator.

### Fixed
- Firebase project configuration for Android and iOS (`tarneemna-91611`), resolving missing iOS configuration and unsupported platform errors.

## [2.0.0] - 2026-10-05

### Added
- Settings: follow the system light/dark mode, plus a themed input style used across the app.
- Settings: About section with the app version and shortcuts to downloads and storage.
- Taranim Arabia: lyrics, chords and sheet music are fetched on demand for the song that is playing.
- Search: recent searches refresh right after a search or "clear".
- Play Store screenshots (Arabic, 1080×1920) with a script to rebuild them (`store-screenshots/`, `store-screenshots.md`).

### Changed
- Downloading from search results now saves into the app's own storage, exactly like album, singer and player downloads. Every download shows up under "الترانيم المحملة".
- Singers list loads every page of songs instead of only the first one, and combined search results are no longer cut to 12.
- Font size scales on top of the system accessibility text size instead of replacing it.
- Search field and button follow the active theme.
- The miniplayer opens the full player with a route transition.
- The seek bar seeks once when you release it instead of on every drag tick.
- Sheet music sheet has a close button and shows the file links.
- Privacy policy screen is RTL, has an app bar and shows a readable error when the file cannot be loaded.

### Fixed
- Search downloads never appeared in the downloads screen because they went to the public `Download` folder.
- A slow, superseded track load could start playing over the current track; playback failures now show a message.
- Shuffle and queue repeat did nothing because the player only holds one track; both are now handled when skipping.
- Removing the current track from the queue could leave playback in a wrong state.
- Short titles such as "يا" matched every other title in the hybrid search de-duplication.
- Downloads check the HTTP status and delete partial files when they fail.
- Library listeners are cached so they are actually removed on dispose.
- The offline storage scan no longer registers (and lets users delete) arbitrary audio files from the public `Download` folder.

### Removed
- Unused code: old routes, theme, global controller, legacy settings screens, share service, search history provider and Arabic normalization helpers, hybrid hymns providers, queue reordering and the end-of-track sleep timer.
- Unused settings: gapless playback and auto-download favorites on Wi-Fi.
- Unused packages: `go_router`, `flutter_hooks`, `animations`, `android_path_provider`.

## [Milestone 2] - 2026-10-04

A rewrite of the app around a feature-first, Riverpod-based architecture.

### Added
- Taranim Arabia engine with a hybrid repository that merges its catalogue with YouTube results.
- Background audio with a queue, sleep timer and A-B repeat.
- Full-screen draggable player with interactive lyrics, quote cards and timestamp sharing.
- Offline downloads library, download manager and storage manager.
- Discovery home with featured carousels, an albums catalogue and a singers directory (infinite scroll).
- Smart Arabic search, favorites, playlists and listening history.
- OLED black theme, spiritual accent colors and accessibility font scaling.
- Android home screen widget.

### Fixed
- Hymn audio streaming and downloading, search UI, performance lag and startup jank.
