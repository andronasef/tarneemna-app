---
last_mapped_commit: 70914c7b7717f2cabca6dc529f781ab29c0caec3
last_mapped_at: 2026-10-04
---
# Directory Structure

**Analysis Date:** 2026-10-04

```
tarneemna-app/
├── .planning/                  # GSD planning and execution state
│   ├── codebase/               # Codebase architecture and tech mapping
│   ├── phases/                 # Phase execution plans and summaries
│   ├── PROJECT.md              # Project scope and milestones
│   ├── REQUIREMENTS.md         # Requirements matrix
│   ├── ROADMAP.md              # Phase breakdown
│   ├── STATE.md                # Execution memory and status
│   └── config.json             # GSD configuration
├── android/                    # Android host project & Gradle configuration
│   ├── app/
│   │   ├── build.gradle        # App module Gradle configuration
│   │   └── src/                # Android manifest, resources, Kotlin MainActivity
│   ├── gradle/wrapper/         # Gradle wrapper properties and jar
│   ├── build.gradle            # Root project buildscript
│   ├── gradle.properties       # JVM & AndroidX properties
│   └── settings.gradle         # Plugin management and module inclusions
├── assets/                     # Bundled markdown & static content
│   └── md/                     # Static markdown texts
├── lib/                        # Dart / Flutter application source code
│   ├── app/
│   │   ├── app.dart            # GetMaterialApp configuration & routing
│   │   └── global_controller.dart # App-level state
│   ├── core/
│   │   ├── routes.dart         # Named route constants
│   │   ├── theme.dart          # Dark/Light theme data & colors
│   │   └── values.dart         # Global constants
│   ├── screens/
│   │   ├── home/               # Main discovery & search screen
│   │   ├── markdown/           # Markdown document viewer
│   │   └── settings/           # Settings & information screen
│   ├── utils/
│   │   ├── analytics.dart      # Firebase analytics helper
│   │   └── open_urls.dart      # URL launcher helper
│   ├── widgets/
│   │   └── snackbar.dart       # Reusable notification banners
│   ├── firebase_options.dart   # Firebase configuration
│   ├── main.dart               # Main entrypoint
│   ├── player.dart             # Audio playback controller & logic
│   └── tarnemma.dart           # Hymn model, search & download actions
├── test/
│   └── widget_test.dart        # Unit and widget test suite
├── analysis_options.yaml       # Dart analysis & linter rules
├── pubspec.yaml                # Flutter package definition and dependencies
└── pubspec.lock                # Locked dependency tree
```
