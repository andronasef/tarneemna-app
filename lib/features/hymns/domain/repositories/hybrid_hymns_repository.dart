import '../entities/hymn.dart';

abstract class HybridHymnsRepository {
  Future<List<Hymn>> searchHymns(String query, {bool includeYouTube = true});
  Future<Hymn> getHymnDetails(Hymn hymn);
  Future<Hymn?> getHymnOfTheDay();
}
