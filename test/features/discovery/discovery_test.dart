import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/hymns/domain/entities/album.dart';
import 'package:tarneemna/features/hymns/domain/entities/singer.dart';

void main() {
  group('Discovery, Singers & Albums Tests', () {
    test('Singer model instantiates with correct properties', () {
      const singer = Singer(
        id: '12',
        name: 'ماهر فايز',
        songCount: 150,
      );

      expect(singer.id, '12');
      expect(singer.name, 'ماهر فايز');
      expect(singer.songCount, 150);
    });

    test('Album model instantiates with correct properties', () {
      const album = Album(
        id: '45',
        title: 'أحبك يا رب قوتي',
        singerName: 'زياد شحادة',
        imageUrl: 'https://example.com/cover.jpg',
        trackCount: 12,
      );

      expect(album.id, '45');
      expect(album.title, 'أحبك يا رب قوتي');
      expect(album.singerName, 'زياد شحادة');
      expect(album.trackCount, 12);
    });

    test('Singers directory search filter matches case and sub-strings', () {
      const singers = [
        Singer(id: '1', name: 'فريق الحياة الأفضل'),
        Singer(id: '2', name: 'فريق الخبر السار'),
        Singer(id: '3', name: 'ماهر فايز'),
        Singer(id: '4', name: 'نزار فارس'),
      ];

      final filtered = singers.where((s) => s.name.contains('فريق')).toList();
      expect(filtered.length, 2);
      expect(filtered.map((s) => s.name), containsAll(['فريق الحياة الأفضل', 'فريق الخبر السار']));
    });

    test('Albums catalog search filter matches title and singer', () {
      const albums = [
        Album(id: '1', title: 'هتاف النصر', singerName: 'فريق الحياة الأفضل'),
        Album(id: '2', title: 'راجعلك يا أبونا', singerName: 'ماهر فايز'),
      ];

      final byTitle = albums.where((a) => a.title.contains('النصر')).toList();
      expect(byTitle.length, 1);
      expect(byTitle.first.id, '1');

      final bySinger = albums.where((a) => a.singerName?.contains('ماهر') ?? false).toList();
      expect(bySinger.length, 1);
      expect(bySinger.first.id, '2');
    });
  });
}
