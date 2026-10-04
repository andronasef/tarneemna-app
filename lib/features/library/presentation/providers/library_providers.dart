import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/library/data/sources/personal_library_service.dart';
import 'package:tarneemna/features/library/domain/entities/playlist.dart';

final personalLibraryServiceProvider = Provider<PersonalLibraryService>((ref) {
  throw UnimplementedError('personalLibraryServiceProvider must be initialized');
});

class FavoritesNotifier extends StateNotifier<List<Hymn>> {
  final PersonalLibraryService _service;

  FavoritesNotifier(this._service) : super(_service.getFavorites()) {
    _service.favoritesListenable.addListener(_sync);
  }

  void _sync() {
    state = _service.getFavorites();
  }

  Future<bool> toggleFavorite(Hymn hymn) async {
    final result = await _service.toggleFavorite(hymn);
    _sync();
    return result;
  }

  @override
  void dispose() {
    _service.favoritesListenable.removeListener(_sync);
    super.dispose();
  }
}

final favoritesListProvider =
    StateNotifierProvider<FavoritesNotifier, List<Hymn>>((ref) {
  final service = ref.watch(personalLibraryServiceProvider);
  return FavoritesNotifier(service);
});

final isFavoriteProvider = Provider.family<bool, String>((ref, hymnId) {
  final favorites = ref.watch(favoritesListProvider);
  return favorites.any((h) => h.id == hymnId);
});

class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  final PersonalLibraryService _service;

  PlaylistsNotifier(this._service) : super(_service.getPlaylists()) {
    _service.playlistsListenable.addListener(_sync);
  }

  void _sync() {
    state = _service.getPlaylists();
  }

  Future<Playlist> createPlaylist(String name) async {
    final p = await _service.createPlaylist(name);
    _sync();
    return p;
  }

  Future<void> deletePlaylist(String id) async {
    await _service.deletePlaylist(id);
    _sync();
  }

  Future<void> addHymn(String playlistId, Hymn hymn) async {
    await _service.addHymnToPlaylist(playlistId, hymn);
    _sync();
  }

  Future<void> removeHymn(String playlistId, String hymnId) async {
    await _service.removeHymnFromPlaylist(playlistId, hymnId);
    _sync();
  }

  @override
  void dispose() {
    _service.playlistsListenable.removeListener(_sync);
    super.dispose();
  }
}

final playlistsListProvider =
    StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  final service = ref.watch(personalLibraryServiceProvider);
  return PlaylistsNotifier(service);
});

class HistoryNotifier extends StateNotifier<List<Hymn>> {
  final PersonalLibraryService _service;

  HistoryNotifier(this._service) : super(_service.getHistory()) {
    _service.historyListenable.addListener(_sync);
  }

  void _sync() {
    state = _service.getHistory();
  }

  Future<void> record(Hymn hymn) async {
    await _service.recordPlayback(hymn);
    _sync();
  }

  Future<void> clear() async {
    await _service.clearHistory();
    _sync();
  }

  @override
  void dispose() {
    _service.historyListenable.removeListener(_sync);
    super.dispose();
  }
}

final playbackHistoryListProvider =
    StateNotifierProvider<HistoryNotifier, List<Hymn>>((ref) {
  final service = ref.watch(personalLibraryServiceProvider);
  return HistoryNotifier(service);
});
