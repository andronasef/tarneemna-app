# Phase 6 Context: Modern Audio Service & Background Playback

## Objectives
Implement a modern, robust background audio architecture for Tarneemna that keeps audio playing flawlessly when the app is in the background, screen is locked, or system resources are tight.

## Locked Architecture Decisions
1. **Audio Service Core**:
   - Use `audio_service` (^0.18.12) combined with `just_audio` (^0.9.36) and `audio_session` (^0.1.21).
   - Implement `TarneemnaAudioHandler` extending `BaseAudioHandler` with `QueueAudioHandler` and `SeekHandler`.
   - Setup `AudioSession.configure(const AudioSessionConfiguration.music())` for automatic audio focus handling (ducking, pausing for phone calls).
2. **Android Background Integration**:
   - `MainActivity` extends `AudioServiceActivity`.
   - `AndroidManifest.xml` configured with `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, and `MediaButtonReceiver`.
3. **Queue & Autoplay Architecture**:
   - `ConcatenatingAudioSource` or programmatic queue management inside `TarneemnaAudioHandler`.
   - Support adding hymns to queue, reordering, skipping, and continuous next-track autoplay.
4. **Practice & Utility Controls**:
   - **A-B Repeat Loop**: Set point A and point B on current track; player monitors position and seeks back to A when B is reached.
   - **Smart Sleep Timer**: Countdown timer (15, 30, 45, 60 mins) and "End of current track" option with smooth fade out.
   - **Crossfade & Gapless**: Transition settings for hymn transitions.
5. **State Management**:
   - Pure Riverpod providers (`audioHandlerProvider`, `playbackStateProvider`, `currentHymnProvider`, `queueProvider`, `sleepTimerProvider`, `abRepeatProvider`).
   - Legacy `Player` class updated to delegate to `AudioHandler` for backward compatibility.
