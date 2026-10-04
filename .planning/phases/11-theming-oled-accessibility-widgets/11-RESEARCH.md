# Phase 11 Research: Theming, Accessibility & Android Widget

## Architectural Findings

### 1. Flutter Dynamic Theming & OLED Black
- Material 3 supports `colorSchemeSeed` or custom `ColorScheme`.
- For True OLED Black, `scaffoldBackgroundColor`, `colorScheme.surface`, and `colorScheme.background` should be `Color(0xFF000000)`, with `cardColor` at `#0D0D0D` or `#121212`.
- Contrast ratios must comply with WCAG AAA for senior accessibility when OLED Black is engaged.

### 2. Typography Scaling (Senior Friendly)
- Flutter 3.16+ uses `MediaQueryData.copyWith(textScaler: TextScaler.linear(scale))` or wrapping with `MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: ...))`.
- Preset multipliers: 0.85 (Small), 1.0 (Normal), 1.15 (Large), 1.30 (Senior / Large Worship Font).

### 3. Hive Settings Storage
- Settings to store:
  - `theme_mode`: `system`, `light`, `dark`, `oled`
  - `accent_color`: integer value or enum (`coral`, `sky`, `gold`, `purple`, `olive`)
  - `font_scale`: double (`0.85`, `1.0`, `1.15`, `1.30`)
  - `crossfade_enabled`: bool
  - `auto_download_wifi`: bool

### 4. Android Home Screen Widget
- In Android, `AppWidgetProvider` specifies XML layout (`widget_layout.xml`) and `appwidget-provider` metadata.
- Can be triggered via BroadcastReceiver or deep links directly communicating with `TarneemnaAudioHandler`.
