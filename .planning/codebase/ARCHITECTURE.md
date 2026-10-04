---
last_mapped_commit: 70914c7b7717f2cabca6dc529f781ab29c0caec3
last_mapped_at: 2026-10-04
---
# Architecture

**Analysis Date:** 2026-10-04

## Pattern Overview

**Overall:** Flutter Mobile Application using GetX Pattern (MVC/Reactive State Management)

**Key Characteristics:**

- Reactive state management using GetX observables (`Rx`, `Obx`, `GetxController`)
- RTL (Right-to-Left) primary layout for Arabic Christian hymns ("ترانيم")
- Background audio streaming via `just_audio` and stream URL resolution via `youtube_explode_dart`
- Background downloads via `flutter_downloader` with Isolate port communication
- Firebase Analytics integration for tracking events

## Layers

**UI Layer (`lib/screens/`, `lib/widgets/`):**

- Purpose: Render screens, widgets, mini-player, and user interactions
- Contains:
  - `lib/screens/home/`: `HomeScreen`, search field, list view, miniplayer widget
  - `lib/screens/settings/`: App settings, share buttons, theme toggles, links
  - `lib/screens/markdown/`: Markdown document viewer (e.g. Terms, About)
  - `lib/widgets/snackbar.dart`: Custom snackbars

**Controller / State Management Layer (`lib/screens/home/home_controller.dart`, `lib/app/global_controller.dart`):**

- Purpose: Manage state, handle user input, coordinate playback and search
- Depends on: Model/Service classes (`Tarnemma`, `Player`)
- Used by: UI layer widgets

**Service / Core Logic Layer (`lib/tarnemma.dart`, `lib/player.dart`):**

- Purpose: Encapsulate domain logic for YouTube searching, stream extraction, audio controls, and file downloading
- Location: `lib/tarnemma.dart`, `lib/player.dart`
- Depends on: `youtube_explode_dart`, `just_audio`, `flutter_downloader`, `permission_handler`

**Core / Infrastructure Layer (`lib/core/`):**

- Purpose: App theming, constants, route definitions
- Location: `lib/core/theme.dart`, `lib/core/routes.dart`, `lib/core/values.dart`

## Data Flow

**Hymn Search & Stream Playback:**

1. User types hymn query in `TarnemaSearch` (`lib/screens/home/widgets/tarnema_search.dart`).
2. Controller invokes `Tarnemma.search(query)` via `youtube_explode_dart`.
3. Results populate `HomeController.tarneemList`.
4. User selects a hymn: `Player.play(tarnemma)` is called.
5. `just_audio` streams the audio; miniplayer expands at bottom of screen.

**Download Flow:**

1. User clicks download icon.
2. `Tarnemma.download()` checks/requests storage permissions.
3. Path provider resolves target downloads directory.
4. `FlutterDownloader.enqueue()` enqueues task in Android download manager.
5. `IsolateNameServer` sends progress back to UI isolate port.

## Entry Points

**App Main Entry (`lib/main.dart`):**

- Initializes Flutter bindings, FlutterNativeSplash, Firebase, and FlutterDownloader.
- Launches `App` widget (`lib/app/app.dart`).

---
*Architecture analysis: 2026-10-04*
