import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/hymns/data/repositories/hybrid_hymns_repository_impl.dart';
import 'package:tarneemna/features/hymns/domain/entities/album.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/singer.dart';
import 'package:tarneemna/features/taranim_arabia/domain/repositories/taranim_arabia_repository.dart';

class MockTaranimArabiaRepository implements TaranimArabiaRepository {
  bool shouldThrow = false;
  List<Hymn> mockSongs = [];

  @override
  Future<List<Hymn>> searchSongs(String query, {int page = 1}) async {
    if (shouldThrow) throw Exception('Taranim Arabia unavailable');
    return mockSongs;
  }

  @override
  Future<Hymn> getSongDetails(String songId) async {
    return Hymn(
      id: songId,
      title: 'Detailed Song',
      audioUrl: 'https://taranimarabia.org/music/$songId.mp3',
      lyrics: 'Detailed Arabic Lyrics',
      source: HymnSource.taranimar,
    );
  }

  @override
  Future<List<Singer>> getSingers({int page = 1}) async => [];

  @override
  Future<List<Hymn>> getSingerSongs(String singerId) async => [];

  @override
  Future<List<Album>> getAlbums({int page = 1}) async => [];

  @override
  Future<List<Hymn>> getAlbumSongs(String albumId) async => [];

  @override
  Future<Hymn?> getHymnOfTheDay() async => null;
}

void main() {
  group('HybridHymnsRepository Tests', () {
    late MockTaranimArabiaRepository mockTaranimRepo;
    late HybridHymnsRepositoryImpl hybridRepo;

    setUp(() {
      mockTaranimRepo = MockTaranimArabiaRepository();
      hybridRepo = HybridHymnsRepositoryImpl(taranimArabiaRepo: mockTaranimRepo);
    });

    test('normalizeTitle strips Arabic diacritics, punctuation, and unifies alef', () {
      const input = '  (نُعَظِّمُ) اسْمَ يَسُوعَ!  ';
      final normalized = HybridHymnsRepositoryImpl.normalizeTitle(input);
      expect(normalized, 'نعظم اسم يسوع');
    });

    test('searchHymns returns Taranim Arabia hymns first', () async {
      mockTaranimRepo.mockSongs = [
        const Hymn(
          id: '10',
          title: 'نعظم اسم يسوع',
          singer: 'فريق أنهار الحياة',
          audioUrl: 'https://taranimarabia.org/music/10.mp3',
          source: HymnSource.taranimar,
        ),
      ];

      final results = await hybridRepo.searchHymns('يسوع', includeYouTube: false);
      expect(results.length, 1);
      expect(results.first.id, '10');
      expect(results.first.source, HymnSource.taranimar);
    });

    test('searchHymns handles Taranim Arabia network errors gracefully', () async {
      mockTaranimRepo.shouldThrow = true;
      final results = await hybridRepo.searchHymns('يسوع', includeYouTube: false);
      expect(results, isEmpty);
    });

    test('getHymnDetails retrieves full lyrics for Taranim Arabia hymn', () async {
      const initial = Hymn(
        id: '10',
        title: 'نعظم اسم يسوع',
        source: HymnSource.taranimar,
      );

      final enriched = await hybridRepo.getHymnDetails(initial);
      expect(enriched.lyrics, 'Detailed Arabic Lyrics');
      expect(enriched.audioUrl, 'https://taranimarabia.org/music/10.mp3');
    });
  });
}
