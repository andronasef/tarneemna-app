---
phase: 03-dart-code-quality
plan: 01
status: in_progress
---

# Phase 3 Plan: Dart Code Quality & Analyzer Warning Fixes

## Objective
Address all static analyzer errors and warnings reported by `flutter analyze`, and fix the broken test suite in `test/widget_test.dart` so `flutter test` succeeds.

## Tasks
1. In `lib/screens/home/home_screen.dart`:
   - Remove invalid `@override` annotation from `ReceivePort _port`.
   - Add missing `@override` annotation to `Widget build(BuildContext context)`.
2. In `lib/screens/markdown/markdown_screen.dart`:
   - Change `_MarkdownPageState createState()` to `State<MarkdownPage> createState()`.
3. In `lib/tarnemma.dart`:
   - Replace string concatenation with string interpolation (`"ترنيمة $traneema"`).
   - Add curly braces to single-line `if` block in `Timer` callback.
4. In `test/widget_test.dart`:
   - Implement valid test suite covering routes and app constants.
5. Run `flutter analyze` and `flutter test` to ensure 0 errors and 0 warnings.
6. Record summary in `03-dart-code-quality/SUMMARY.md`.
