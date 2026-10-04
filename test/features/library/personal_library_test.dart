import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/library/domain/entities/playlist.dart';
import 'package:tarneemna/features/search/data/sources/search_history_service.dart';

void main() {
  group('Personal Library & Smart Search Tests', () {
    test('Playlist entity serializes to map and deserializes correctly', () {
      final now = DateTime(2026, 10, 4, 12, 0);
      const hymn = Hymn(
        id: '123',
        title: 'يا صاحب الحنان',
        singer: 'فريق الحياة الأفضل',
        source: HymnSource.taranimar,
      );

      final playlist = Playlist(
        id: 'p1',
        name: 'ترانيم الصباح',
        createdAt: now,
        hymns: [hymn],
      );

      final map = playlist.toMap();
      expect(map['id'], 'p1');
      expect(map['name'], 'ترانيم الصباح');
      expect(map['createdAt'], now.toIso8601String());

      final restored = Playlist.fromMap(map);
      expect(restored.id, playlist.id);
      expect(restored.name, playlist.name);
      expect(restored.hymns.length, 1);
      expect(restored.hymns.first.title, 'يا صاحب الحنان');
    });

    test('Playlist copyWith adds and removes hymns cleanly', () {
      final playlist = Playlist(
        id: 'p1',
        name: 'قائمة 1',
        createdAt: DateTime.now(),
        hymns: [],
      );

      const hymn1 = Hymn(id: '1', title: 'ترنيمة 1', source: HymnSource.taranimar);
      const hymn2 = Hymn(id: '2', title: 'ترنيمة 2', source: HymnSource.youtube);

      final withHymns = playlist.copyWith(hymns: [hymn1, hymn2]);
      expect(withHymns.hymns.length, 2);

      final filtered = withHymns.copyWith(
        hymns: withHymns.hymns.where((h) => h.id != '1').toList(),
      );
      expect(filtered.hymns.length, 1);
      expect(filtered.hymns.first.id, '2');
    });

    test('SearchHistoryService.normalizeArabic removes diacritics and unifies letters', () {
      expect(SearchHistoryService.normalizeArabic('يَسُوعُ'), 'يسوع');
      expect(SearchHistoryService.normalizeArabic('إِلَهِي'), 'الهي');
      expect(SearchHistoryService.normalizeArabic('آبانا'), 'ابانا');
      expect(SearchHistoryService.normalizeArabic('حياةٌ'), 'حياه');
      expect(SearchHistoryService.normalizeArabic('صَلاةٌ'), 'صلاه');
    });

    test('SearchHistoryService.fuzzyArabicMatch matches flexible user input', () {
      const target = 'يسوع فادي النفس';

      // Exact match
      expect(SearchHistoryService.fuzzyArabicMatch(target, 'يسوع'), isTrue);

      // Match with diacritics
      expect(SearchHistoryService.fuzzyArabicMatch(target, 'يَسُوع'), isTrue);

      // Match with Hamza variations
      const hymn2 = 'إلهي الحي الأعظم';
      expect(SearchHistoryService.fuzzyArabicMatch(hymn2, 'الهي'), isTrue);
      expect(SearchHistoryService.fuzzyArabicMatch(hymn2, 'الاعظم'), isTrue);

      // Mismatch
      expect(SearchHistoryService.fuzzyArabicMatch(target, 'داود'), isFalse);
    });
  });
}
