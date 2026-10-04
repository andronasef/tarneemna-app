# Phase 7 Validation: Full-Screen Draggable Player & Interactive Lyrics

## Verification Strategy

### Automated Verification
1. **Player UI & Widget Unit Tests**:
   - Test `Miniplayer` expands and collapses.
   - Verify play, pause, seek, and skip callbacks trigger `AudioHandler`.
   - Test lyrics scaling controller and line selection logic.
   - Test Quote Card rendering model and gradient presets.
2. **Code Quality**:
   - `flutter analyze` passes with 0 issues.
   - All tests in `test/` pass.

### Manual / Integration Verification
- Draggable bottom sheet expands smoothly without overflow.
- Seeker accurately reflects playback progress.
- Lyrics view displays Arabic text properly formatted with correct RTL text direction.
- Quote card exports properly.
