import 'package:tarneemna/features/hymns/domain/entities/album.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/singer.dart';

abstract class TaranimArabiaRepository {
  Future<List<Hymn>> searchSongs(String query, {int page = 1});
  Future<Hymn> getSongDetails(String songId);
  Future<List<Singer>> getSingers({int page = 1});
  Future<List<Hymn>> getSingerSongs(String singerId);
  Future<List<Album>> getAlbums({int page = 1});
  Future<List<Hymn>> getAlbumSongs(String albumId);
  Future<Hymn?> getHymnOfTheDay();
}
