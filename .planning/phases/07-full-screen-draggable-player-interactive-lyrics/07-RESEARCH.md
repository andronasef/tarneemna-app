# Phase 7 Research: Full-Screen Draggable Player & Interactive Lyrics

## UI/UX Architectural Patterns

### 1. Miniplayer & Full Screen Expansion
- The project already has `miniplayer: ^1.0.1` in `pubspec.yaml`.
- `Miniplayer(minHeight: 70, maxHeight: MediaQuery.of(context).size.height, builder: (height, percentage) => ...)` provides standard Spotify-like gesture behavior.
- In collapsed mode (height <= 75), render compact row with progress line.
- In expanded mode (percentage > 0.8), render full player.

### 2. Lyrics Presentation
- Lyrics from Taranim Arabia are clean Arabic stanzas (e.g. القرار followed by verses 1, 2, 3).
- Display with line spacing, selectable lines, and responsive font size controls (`StateProvider<double>` for font scaling).

### 3. Quote Card Image Generation
- Use Flutter's `RepaintBoundary` with `GlobalKey`.
  ```dart
  RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List pngBytes = byteData!.buffer.asUint8List();
  ```
- Save to temporary file in `path_provider.getTemporaryDirectory()` and share via `Share.shareXFiles([XFile(...)])`.

### 4. Timestamp Sharing
- Format `player.position` into `MM:SS`.
- Generate formatted message with hymn title, artist, and timestamp.
