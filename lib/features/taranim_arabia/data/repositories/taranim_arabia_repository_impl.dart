import 'package:tarneemna/features/hymns/data/sources/local_hymn_cache.dart';
import 'package:tarneemna/features/hymns/domain/entities/album.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/singer.dart';
import 'package:tarneemna/features/taranim_arabia/domain/repositories/taranim_arabia_repository.dart';
import 'package:tarneemna/features/taranim_arabia/data/sources/taranim_arabia_remote_data_source.dart';

class TaranimArabiaRepositoryImpl implements TaranimArabiaRepository {
  final TaranimArabiaRemoteDataSource _remoteDataSource;
  final LocalHymnCache? _cache;

  TaranimArabiaRepositoryImpl({
    required TaranimArabiaRemoteDataSource remoteDataSource,
    LocalHymnCache? cache,
  })  : _remoteDataSource = remoteDataSource,
        _cache = cache;

  @override
  Future<List<Hymn>> searchSongs(String query, {int page = 1}) async {
    final results = await _remoteDataSource.searchSongs(query, page: page);
    if (_cache != null && results.isNotEmpty) {
      await _cache!.cacheHymns(results);
    }
    return results;
  }

  @override
  Future<Hymn> getSongDetails(String songId) async {
    final cached = _cache?.getHymn(songId);
    if (cached != null && cached.lyrics != null && cached.lyrics!.isNotEmpty) {
      return cached;
    }
    final details = await _remoteDataSource.getSongDetails(songId);
    if (_cache != null) {
      await _cache!.cacheHymn(details);
    }
    return details;
  }

  @override
  Future<List<Singer>> getSingers({int page = 1}) {
    return _remoteDataSource.getSingers(page: page);
  }

  @override
  Future<List<Hymn>> getSingerSongs(String singerId) async {
    final songs = await _remoteDataSource.getSingerSongs(singerId);
    if (_cache != null && songs.isNotEmpty) {
      await _cache!.cacheHymns(songs);
    }
    return songs;
  }

  @override
  Future<List<Album>> getAlbums({int page = 1}) {
    return _remoteDataSource.getAlbums(page: page);
  }

  @override
  Future<List<Hymn>> getAlbumSongs(String albumId) async {
    final songs = await _remoteDataSource.getAlbumSongs(albumId);
    if (_cache != null && songs.isNotEmpty) {
      await _cache!.cacheHymns(songs);
    }
    return songs;
  }

  @override
  Future<Hymn?> getHymnOfTheDay() async {
    final hymn = await _remoteDataSource.getHymnOfTheDay();
    if (hymn != null && _cache != null) {
      await _cache!.cacheHymn(hymn);
    }
    return hymn;
  }
}
