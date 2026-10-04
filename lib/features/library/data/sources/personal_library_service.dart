import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/library/domain/entities/playlist.dart';

class PersonalLibraryService {
  static const String favoritesBoxName = 'user_favorites';
  static const String playlistsBoxName = 'user_playlists';
  static const String historyBoxName = 'playback_history';

  late Box _favoritesBox;
  late Box _playlistsBox;
  late Box _historyBox;

  Future<void> init() async {
    _favoritesBox = await Hive.openBox(favoritesBoxName);
    _playlistsBox = await Hive.openBox(playlistsBoxName);
    _historyBox = await Hive.openBox(historyBoxName);
  }

  // ValueListenable for UI reactivity
  ValueListenable<Box> get favoritesListenable => _favoritesBox.listenable();
  ValueListenable<Box> get playlistsListenable => _playlistsBox.listenable();
  ValueListenable<Box> get historyListenable => _historyBox.listenable();

  // --- FAVORITES ---
  bool isFavorite(String hymnId) {
    return _favoritesBox.containsKey(hymnId);
  }

  Future<bool> toggleFavorite(Hymn hymn) async {
    if (_favoritesBox.containsKey(hymn.id)) {
      await _favoritesBox.delete(hymn.id);
      return false;
    } else {
      await _favoritesBox.put(hymn.id, hymn.toMap());
      return true;
    }
  }

  List<Hymn> getFavorites() {
    final list = <Hymn>[];
    for (final key in _favoritesBox.keys) {
      final raw = _favoritesBox.get(key);
      if (raw != null && raw is Map) {
        list.add(Hymn.fromMap(Map<String, dynamic>.from(raw)));
      }
    }
    return list.reversed.toList();
  }

  // --- PLAYLISTS ---
  List<Playlist> getPlaylists() {
    final list = <Playlist>[];
    for (final key in _playlistsBox.keys) {
      final raw = _playlistsBox.get(key);
      if (raw != null && raw is Map) {
        list.add(Playlist.fromMap(Map<String, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<Playlist> createPlaylist(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(
      id: id,
      name: name.trim(),
      createdAt: DateTime.now(),
      hymns: [],
    );
    await _playlistsBox.put(id, playlist.toMap());
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    await _playlistsBox.delete(id);
  }

  Future<void> addHymnToPlaylist(String playlistId, Hymn hymn) async {
    final raw = _playlistsBox.get(playlistId);
    if (raw != null && raw is Map) {
      final playlist = Playlist.fromMap(Map<String, dynamic>.from(raw));
      if (!playlist.hymns.any((h) => h.id == hymn.id)) {
        final updated = playlist.copyWith(
          hymns: [...playlist.hymns, hymn],
        );
        await _playlistsBox.put(playlistId, updated.toMap());
      }
    }
  }

  Future<void> removeHymnFromPlaylist(String playlistId, String hymnId) async {
    final raw = _playlistsBox.get(playlistId);
    if (raw != null && raw is Map) {
      final playlist = Playlist.fromMap(Map<String, dynamic>.from(raw));
      final updated = playlist.copyWith(
        hymns: playlist.hymns.where((h) => h.id != hymnId).toList(),
      );
      await _playlistsBox.put(playlistId, updated.toMap());
    }
  }

  // --- PLAYBACK HISTORY ---
  static const int maxHistoryCount = 50;

  Future<void> recordPlayback(Hymn hymn) async {
    final list = getHistory();
    list.removeWhere((h) => h.id == hymn.id);
    list.insert(0, hymn);
    if (list.length > maxHistoryCount) {
      list.removeRange(maxHistoryCount, list.length);
    }
    await _historyBox.put('history_list', list.map((h) => h.toMap()).toList());
  }

  List<Hymn> getHistory() {
    final raw = _historyBox.get('history_list');
    if (raw != null && raw is List) {
      return raw
          .map((item) => Hymn.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  Future<void> clearHistory() async {
    await _historyBox.delete('history_list');
  }
}
