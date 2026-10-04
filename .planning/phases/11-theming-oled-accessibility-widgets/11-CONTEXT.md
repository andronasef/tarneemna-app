# Phase 11 Context: Theming (OLED Black), Accessibility & Widgets

## Phase Overview
Phase 11 delivers modern personalization, accessibility, and ecosystem integration for Tarneemna:
1. **Dynamic Theming Engine**:
   - Theme modes: System, Light, Dark (Slate `#1E293B`), and True OLED Black (`#000000` pitch black for battery saving and night worship).
   - Spiritual accent palettes:
     - Tarneemna Coral (Default: `#FF5432`)
     - Celestial Sky / سماوي (`#0284C7`)
     - Holy Gold / ذهبي (`#D97706`)
     - Royal Purple / بنفسجي (`#7C3AED`)
     - Olive Branch / زيتوني (`#15803D`)
2. **Accessibility & Senior Typography**:
   - Adjustable UI font scaling (Small 0.85x, Standard 1.0x, Large 1.15x, Senior-Friendly 1.30x).
   - High-contrast text options with Cairo Arabic font readability.
3. **Preferences Persistence & Settings UI**:
   - `SettingsService` backed by Hive (`app_settings` box).
   - Riverpod `settingsNotifierProvider` providing real-time reactivity to `MaterialApp` / `GetMaterialApp`.
   - Modern `SettingsScreen` (`/settings`) accessible from navigation/app bar.
4. **Android Home Screen Widget**:
   - Widget layout and receiver definition (`TarneemnaWidgetProvider`) for quick playback display and control.
