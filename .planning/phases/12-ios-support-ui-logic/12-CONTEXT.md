# Phase 12 Context: iOS UI, Platform Integration & Logic Readiness

## Phase Overview
Phase 12 prepares the Tarneemna app for a first-class native iOS user experience using Flutter 3.44's modern toolchain, Firebase iOS registration, background audio, and Cupertino-aligned UI polish:

1. **Native iOS Project Scaffolding & SwiftPM Toolchain**:
   - Modern iOS Flutter runner setup (`ios/` directory, `Runner.xcodeproj`, Swift Package Manager support).
   - Adoption of SwiftPM as Flutter's standard package manager instead of deprecated CocoaPods workflows.
   - `Info.plist` critical configurations:
     - Background Audio Mode (`UIBackgroundModes: audio`) for continuous playback when locked or backgrounded.
     - App Transport Security (`NSAppTransportSecurity`) exceptions for streaming Taranim Arabia MP3s and CDN assets.
     - Permission descriptions: Microphone (`NSMicrophoneUsageDescription`), Speech Recognition (`NSSpeechRecognitionUsageDescription`), and Photo Library (`NSPhotoLibraryAddUsageDescription`).
     - App Display Name: `ترنيمنا` (`CFBundleDisplayName`).
   - Native iOS splash screen generation (`flutter_native_splash`).

2. **Firebase iOS Project Registration & Platform Logic**:
   - Register iOS app (`com.increase.tarneemna`) in the Firebase project.
   - Install `GoogleService-Info.plist` and run `flutterfire configure` to generate real iOS options in `lib/firebase_options.dart`.
   - Audio Session category configuration for iOS (`AVAudioSessionCategoryPlayback`).
   - Storage path sandboxing: confirm `OfflineStorageService` and `DownloadManagerService` write to iOS `getApplicationDocumentsDirectory()` with correct permissions.

3. **iOS UI Adaptations & Tactile Polish**:
   - Safe Area & Home Indicator adaptations: audit bottom miniplayer, draggable full-screen player, and bottom sheets for iPhone notch / Dynamic Island and home indicator bars.
   - iOS Haptic Feedback: subtle physical feedback on key actions (play/pause toggle, hymn favoriting, slider scrubbing, modal dismissal).
   - Cupertino transitions & adaptive widgets: smooth swipe-to-back gestures across all screens and adaptive platform controls.
