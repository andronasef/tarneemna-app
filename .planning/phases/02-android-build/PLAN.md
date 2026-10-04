---
phase: 02-android-build
plan: 01
status: in_progress
---

# Phase 2 Plan: Android Build Configuration Modernization

## Objective
Migrate the Android project configuration to modern declarative Flutter Gradle plugins (Gradle 8+, AGP 8.3+, Java 17, declarative plugins DSL in `settings.gradle` and `app/build.gradle`), eliminating the obsolete imperative `app_plugin_loader.gradle` and support multidex dependencies.

## Tasks
1. Update `android/gradle/wrapper/gradle-wrapper.properties` to Gradle 8.4 (`gradle-8.4-all.zip`).
2. Update `android/settings.gradle` to use the declarative `pluginManagement` and `plugins` block.
3. Update `android/build.gradle` to remove obsolete `buildscript` dependencies and align repositories.
4. Update `android/app/build.gradle` to use `plugins { ... }` block (including `dev.flutter.flutter-gradle-plugin`), remove imperative applies, upgrade compileOptions/jvmTarget to Java 17, and remove legacy support multidex.
5. Verify Android build configuration starts up and evaluates correctly.
6. Record summary in `02-android-build/SUMMARY.md`.
