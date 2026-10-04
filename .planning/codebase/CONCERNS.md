---
last_mapped_commit: 70914c7b7717f2cabca6dc529f781ab29c0caec3
last_mapped_at: 2026-10-04
---
# Technical Debt & Migration Concerns

**Analysis Date:** 2026-10-04

## Identified Migration Blockers & Debt

1. **Obsolete SDK Constraint in `pubspec.yaml`**:
   - `sdk: '>=2.16.2 <3.0.0'` locks Dart to 2.x while host environment is Dart 3.12.2 / Flutter 3.44.9.
   - Must be updated to `sdk: ^3.12.0` (or `sdk: '>=3.0.0 <4.0.0'`).
2. **Deprecated Imperative Gradle Configuration**:
   - In Flutter 3.24+, imperative apply (`apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"` and `apply from: "$flutterRoot/.../flutter.gradle"`) fails immediately with Gradle script errors.
   - Android Gradle files must be migrated to the new declarative `pluginManagement` and `plugins` block syntax.
3. **Android Gradle Plugin & Gradle Wrapper**:
   - Outdated Gradle 7.6.1 and AGP 7.4.0 must be aligned with JDK 17 and Flutter 3.44.9 requirements (AGP 8.3+ or 8.4+, Gradle 8.4+).
   - Obsolete support library `com.android.support:multidex:1.0.3` causes build failures and conflicts with AndroidX.
4. **Static Analyzer Warnings**:
   - `flutter_native_splash` imported in `lib/main.dart` but listed under `dev_dependencies`.
   - `HomeScreen._HomeScreenState._port` marked `@override` when not overriding anything.
   - `HomeScreen._HomeScreenState.build` missing `@override`.
   - `MarkdownPage.createState()` returning private `_MarkdownPageState` instead of `State<MarkdownPage>`.
   - String concatenation and curly brace style issues in `lib/tarnemma.dart`.
5. **Broken Test Suite**:
   - `test/widget_test.dart` has commented out code with typo import `package:traneemna/main.dart` causing `Missing definition of main method` test failure.
