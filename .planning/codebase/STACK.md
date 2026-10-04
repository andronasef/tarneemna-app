---
last_mapped_commit: 70914c7b7717f2cabca6dc529f781ab29c0caec3
last_mapped_at: 2026-10-04
---
# Technology Stack

**Analysis Date:** 2026-10-04

## Languages

**Primary:**

- Dart 3.12.2 (Target modern Dart 3.x, migrated from legacy Dart 2.16)

**Secondary:**

- Groovy / Gradle (Android build system scripts)
- Kotlin 1.9+ (Android native plugin host)

## Runtime

**Environment:**

- Flutter 3.44.9 (channel stable)
- OpenJDK 17.0.20.1 (`/opt/homebrew/opt/openjdk@17`)
- Android SDK 37.0.0 (API 34/35/37)

**Package Manager:**

- Flutter pub / Dart pub
- Lockfile: `pubspec.lock`

## Frameworks

**Core:**

- Flutter SDK (Material Design)
- GetX (v4.6.6) - State management, reactive controllers, navigation & snackbars

**Testing:**

- flutter_test (Flutter SDK unit & widget testing framework)

**Build/Dev Tooling:**

- Android Gradle Plugin (AGP) & Gradle Wrapper
- flutter_lints: ^3.0.1 (static analysis)
- flutter_launcher_icons (launcher icon generator)
- flutter_native_splash (splash screen generator)

## Key Dependencies

**Audio & Media:**

- `just_audio: ^0.9.28` - Audio playback engine
- `youtube_explode_dart: ^1.11.0` - YouTube search and stream extractor
- `miniplayer: ^1.0.1` - Persistent floating mini player widget

**System & Network:**

- `flutter_downloader: ^1.7.4` - Background task downloader
- `path_provider: ^2.0.11` / `android_path_provider: ^0.3.0` - File system directories
- `permission_handler: ^11.0.1` - Runtime permissions for storage
- `internet_connection_checker: ^1.0.0+1` - Connectivity monitoring
- `url_launcher: ^6.1.5` - Web link handler
- `share_plus: ^7.2.1` - Native share dialogs

**Firebase:**

- `firebase_core: ^2.24.2` - Firebase app initialization
- `firebase_analytics: ^10.7.4` - Usage telemetry

**UI/Styling:**

- `google_fonts: ^4.0.4` - Cairo and Arabic fonts
- `flutter_fadein: ^2.0.0` - Animation transitions
- `flutter_hooks: ^0.20.3` - React-style hooks
- `flutter_markdown: ^0.6.10+3` - Markdown rendering

## Configuration

**Environment:**

- `android/key.properties` (release signing keys, optional)
- `lib/firebase_options.dart` (Firebase configuration per platform)

**Build:**

- `android/build.gradle`, `android/settings.gradle`, `android/app/build.gradle`
- `analysis_options.yaml` (Dart analysis rules)

## Platform Requirements

**Development:**

- macOS 26.x (Apple Silicon darwin-arm64)
- Flutter 3.44.9, Dart 3.12.2, OpenJDK 17

**Production:**

- Android (minSdkVersion 21+, targetSdkVersion 34+)
