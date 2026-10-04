---
phase: 01-sdk-dependencies
plan: 01
status: in_progress
---

# Phase 1 Plan: SDK & Dependency Modernization

## Objective
Update Flutter & Dart SDK environment constraints in `pubspec.yaml` to modern Dart 3 (`>=3.0.0 <4.0.0`), move `flutter_native_splash` to runtime dependencies, and run `flutter pub get` cleanly.

## Tasks
1. Edit `pubspec.yaml` to set `sdk: '>=3.0.0 <4.0.0'`.
2. Move `flutter_native_splash: ^2.3.7` from `dev_dependencies` to `dependencies` because it is referenced at runtime in `lib/main.dart`.
3. Run `flutter pub get` and verify dependency resolution succeeds without errors.
4. Record summary in `01-sdk-dependencies/SUMMARY.md`.
