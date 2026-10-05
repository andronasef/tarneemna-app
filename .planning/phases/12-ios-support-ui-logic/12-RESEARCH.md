# Phase 12 Research: iOS UI, Platform Integration & Logic Readiness

## 1. Native iOS Scaffolding & Swift Package Manager (SwiftPM)

### Project Generation & SwiftPM
In Flutter 3.44.9, **Swift Package Manager (SwiftPM)** is enabled by default (`enable-swift-package-manager: true` in `flutter config`). CocoaPods is being deprecated/phased out by the Flutter team in favor of Apple's native Swift Package Manager.
Running:
```bash
flutter create . --platforms=ios --org com.increase
```
creates standard modern runner templates with bundle identifier `com.increase.tarneemna`, using SwiftPM as the primary package integration mechanism.

### Info.plist Configuration
The following keys are required for full iOS functionality:
- **Background Audio**:
  ```xml
  <key>UIBackgroundModes</key>
  <array>
      <string>audio</string>
  </array>
  ```
- **App Transport Security (ATS)**:
  Taranim Arabia audio streams and assets (`taranimarabia.org`) require HTTP/HTTPS streaming clearance:
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
      <key>NSAllowsArbitraryLoads</key>
      <true/>
  </dict>
  ```
- **Privacy Usage Descriptions**:
  - `NSMicrophoneUsageDescription`: Arabic explanation for voice hymn search.
  - `NSSpeechRecognitionUsageDescription`: Arabic explanation for speech recognition.
  - `NSPhotoLibraryAddUsageDescription`: Permission for saving quote cards to the iOS Photos album.
- **Localization & App Title**:
  - `CFBundleDisplayName`: `ترنيمنا`
  - `CFBundleLocalizations`: Arabic (`ar`).

### Native Splash Integration
- `pubspec.yaml` currently has `ios: false` under `flutter_native_splash`.
- Update `ios: true` and execute `dart run flutter_native_splash:create` to generate `LaunchScreen.storyboard` and launch assets in `ios/Runner/Assets.xcassets`.

---

## 2. Firebase iOS Project Registration & Platform Logic

### Firebase Project & iOS Configuration
- The app's Android configuration currently targets Firebase project `tarneemna` (`appId: 1:799396486646:android:...`).
- An iOS app with bundle ID `com.increase.tarneemna` must be registered in the Firebase console for the project.
- Downloading and adding `GoogleService-Info.plist` to `ios/Runner/` and running `flutterfire configure` generates official `DefaultFirebaseOptions.ios` in `lib/firebase_options.dart`.

### Audio Session & Background Audio
- `audio_session` `AudioSessionConfiguration.music()` initializes `AVAudioSessionCategoryPlayback` on iOS.
- With `UIBackgroundModes: audio` present in `Info.plist`, `audio_service` integrates with `MPNowPlayingInfoCenter` and `MPRemoteCommandCenter` for lock screen media controls, Dynamic Island / Control Center playback, and headphone controls.

### File Storage & Downloads on iOS
- `OfflineStorageService` and `DownloadManagerService` use `getApplicationDocumentsDirectory()`.
- On iOS, this resolves to the app's sandboxed `Documents` folder (`/var/mobile/Containers/Data/Application/<UUID>/Documents/downloads/audio/`), which is persistent across launches.

---

## 3. iOS UI Adaptations & Tactile Polish

### Safe Area & Home Indicator
- Devices with Home Indicators (iPhone X through iPhone 16) require bottom padding (~34pt).
- Verify that `MiniPlayer` and `FullPlayerView` handle `MediaQuery.paddingOf(context).bottom` cleanly without clipping playback controls or overlapping the gesture indicator bar.

### Tactile Feedback (Haptics)
- iOS users expect responsive tactile feedback on key touch interactions:
  - Play/Pause toggle -> `HapticFeedback.lightImpact()`
  - Favorite toggle -> `HapticFeedback.mediumImpact()`
  - Seeker scrub release -> `HapticFeedback.selectionClick()`
  - Sleep timer selection -> `HapticFeedback.selectionClick()`

### Navigation & Transitions
- `GetMaterialApp` specifies `defaultTransition: Transition.cupertino`.
- Verify RTL back-swipe gesture support across all push navigation flows.
