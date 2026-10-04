# Phase 10 Context: Smart Search, Voice Search & Personal Library

## Objectives
Equip Tarneemna with a personalized spiritual sanctuary and intelligent search:
1. **Favorites (المفضلة)**: Quick toggle (heart icon) in full player and hymn lists, saved persistently in Hive (`favorites_box`).
2. **Custom Playlists (قوائم التشغيل)**: Create playlists (e.g. "ترانيم الصباح", "ترانيم أسبوع الآلام"), add/remove tracks, reorder, play full playlist.
3. **Recently Played (سجل الاستماع)**: Automatically append played hymns up to 50 items.
4. **Smart Arabic Search**: Normalize Arabic diacritics, Alef with Hamza variants (أ, إ, آ -> ا), Taa Marbouta (ة -> ه), Yaa (ى -> ي) and keep local search query history.

## Locked Architectural Directives
- Persistence: Hive boxes `user_favorites`, `user_playlists`, `playback_history`, `search_history`.
- Riverpod state management: Notifiers for favorites, playlists, and history.
- Clean presentation with RTL-first UI and seamless integration into `HomeScreen` and `TarneemnaAudioHandler`.
