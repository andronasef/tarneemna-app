---
last_mapped_commit: 70914c7b7717f2cabca6dc529f781ab29c0caec3
last_mapped_at: 2026-10-04
---
# Testing Strategy & Configuration

**Analysis Date:** 2026-10-04

## Test Tooling

- Framework: `flutter_test` (built into the Flutter SDK)
- Test Directory: `test/`
- Test Runner: `flutter test`

## Test Scope

- **Smoke & Unit Tests**: Test widget rendering, route navigation, and core model instantiation.
- **Mocking**: Isolate platform channels (Firebase, Downloader, JustAudio) during headless automated tests.
- **Verification Gates**:
  1. `flutter analyze` must produce 0 errors, 0 warnings.
  2. `flutter test` must execute and pass cleanly.
  3. `flutter build apk --debug` must succeed against the current Flutter toolchain.
