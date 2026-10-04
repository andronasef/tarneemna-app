# Requirements: Milestone 2 — Modern Worship & Content Ecosystem

## 1. Audio Player & Playback Engine (REQ-PLY)
- **REQ-PLY-01**: Provide a full-screen draggable bottom-sheet player (Spotify-style) displaying high-res album thumbnail, track title, singer, seeker slider with time elapsed/remaining, and comprehensive playback controls.
- **REQ-PLY-02**: Support background playback and system notification/lock-screen controls via `audio_service`, including play/pause, seek, skip, and metadata display.
- **REQ-PLY-03**: Support playback queue management (Up Next) with reordering and continuous autoplay.
- **REQ-PLY-04**: Implement A-B Repeat loop for practicing and learning hymns.
- **REQ-PLY-05**: Implement smart Sleep Timer (مؤقت النوم) with preset durations and "end of current track" option.
- **REQ-PLY-06**: Support gapless playback and configurable smooth crossfade between hymns.

## 2. Taranim Arabia Content Engine (REQ-TRN)
- **REQ-TRN-01**: Implement client engine for `taranimarabia.org` to search songs by title and lyrics, retrieve high-bitrate direct MP3 URLs, song metadata, lyrics, and album art.
- **REQ-TRN-02**: Support full Album browsing and streaming (`/albums`, `/album/{id}`).
- **REQ-TRN-03**: Support Singers and Choirs Directory (`/allsingers`, `/singer/{id}`).
- **REQ-TRN-04**: Fetch random "ترنيمة اليوم" (Hymn of the Day) with biblical verse.
- **REQ-TRN-05**: Implement hybrid search: query Taranim Arabia first for curated hymns + direct MP3s + lyrics, with seamless fallback / enrichment via YouTube Explode.

## 3. Lyrics & Spiritual Sharing (REQ-LYR)
- **REQ-LYR-01**: Display formatted Arabic hymn lyrics with adjustable font size, font family, and reading mode.
- **REQ-LYR-02**: Generate and share beautiful Hymn Quote Cards (بطاقات اقتباسات الترانيم) as images for WhatsApp Status / Instagram Stories.
- **REQ-LYR-03**: Support sharing hymn at a specific timestamp (مشاركة وقت محدد في الترنيمة).

## 4. Offline Storage & Library (REQ-OFF)
- **REQ-OFF-01**: Dedicated "ترانيمي المحملة" (Offline Downloads) screen for browsing, sorting, and playing downloaded MP3s without internet.
- **REQ-OFF-02**: One-click bulk/batch download for entire albums or playlists with unified progress tracker.
- **REQ-OFF-03**: Auto-download favorites when connected to Wi-Fi.
- **REQ-OFF-04**: Storage Manager screen showing cached/downloaded size, with clear-cache and file management tools.
- **REQ-OFF-05**: Export / share downloaded MP3 file to external apps (WhatsApp, Telegram, local storage).

## 5. Discovery & Home Experience (REQ-HOM)
- **REQ-HOM-01**: Dynamic Home Screen featuring Hymn of the Day, Popular Albums, Featured Singers, and Recently Played.
- **REQ-HOM-02**: Continuous Endless Hymn Radio (راديو الترانيم المستمر) by singer or worship mood.
- **REQ-HOM-03**: Dedicated Singers & Bands catalog screen.

## 6. Smart Search & Personal Library (REQ-LIB)
- **REQ-LIB-01**: Search by lyrics text (البحث بكلمات من داخل الترنيمة).
- **REQ-LIB-02**: Recent searches history and instant suggestion chips.
- **REQ-LIB-03**: Voice search (البحث الصوتي) using mobile speech recognition.
- **REQ-LIB-04**: 1-tap Favorites (المفضلة ❤️) and Custom Playlists (إنشاء وتنظيم القوائم).
- **REQ-LIB-05**: Listening History (سجل الاستماع) and Most Played tracks.
- **REQ-LIB-06**: In-app "Request a Missing Hymn" (طلب ترنيمة مفقودة) form.

## 7. Theming & Accessibility (REQ-THM)
- **REQ-THM-01**: True OLED Pitch Black dark theme and light theme toggle.
- **REQ-THM-02**: Custom spiritual accent themes (سماوي، كستنائي، ذهبي...).
- **REQ-THM-03**: Accessibility and senior-friendly font scaling.
- **REQ-THM-04**: Android Home Screen Widget for quick playback control.
