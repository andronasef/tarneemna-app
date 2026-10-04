# Phase 7 Context: Full-Screen Draggable Player & Interactive Lyrics

## Objectives
Elevate Tarneemna's listening experience with a modern full-screen draggable bottom sheet player (Spotify-like), interactive typography-scaled Arabic lyrics viewer, sheet music / chord visualizer, aesthetic hymn quote card generator, and timestamped audio sharing.

## Locked Architecture & UI Decisions
1. **Full-Screen Draggable Bottom Sheet Player**:
   - Built on top of `miniplayer` or an animated sliding panel / draggable bottom sheet.
   - Shows compact MiniPlayer at the bottom when collapsed: artwork thumbnail, title, singer, play/pause button, progress indicator.
   - Smoothly expands to full screen displaying:
     - Large rounded album artwork with shadow and backdrop blur.
     - Track title and singer with Arabic typography (Cairo / Amiri).
     - Seeker bar with drag-to-seek, current position, and remaining/total duration.
     - Playback controls: Shuffle, Previous, Play/Pause with morphing icon, Next, Repeat mode.
     - Secondary controls: Speed selector (0.75x, 1.0x, 1.25x, 1.5x, 2.0x), Sleep Timer button, A-B Repeat button, Lyrics button, Chords/Notes button, Share button.
2. **Interactive Lyrics Viewer**:
   - Clean readable Arabic typography with adjustable font size slider (A- / A+).
   - Auto-scrollable with reading mode.
   - Integrated tab/button for sheet music & chords (if available from Taranim Arabia).
3. **Hymn Quote Card Generator**:
   - Allow user to tap/select lines from the lyrics.
   - Generate an aesthetic image card with gradient backgrounds (dark, sunset, celestial blue, olive gold), hymn title, singer, and subtle "ترانيمنا" watermark.
   - Render to image using `RepaintBoundary` and share via `share_plus`.
4. **Timestamped Sharing**:
   - Share current hymn with timestamp text (e.g., "اسمع ترنيمة [عنوان] عند الدقيقة 01:23 في تطبيق ترانيمنا").
