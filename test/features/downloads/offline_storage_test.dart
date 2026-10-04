import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

void main() {
  group('DownloadedHymn & OfflineStorage Tests', () {
    test('DownloadedHymn serializes to map and deserializes accurately', () {
      final downloaded = DownloadedHymn(
        id: '101',
        title: 'يا سيدي الحبيب',
        singer: 'زياد شحادة',
        album: 'أحبك يا رب قوتي',
        artworkUrl: 'https://example.com/art.jpg',
        localFilePath: '/data/user/0/downloads/audio/101.mp3',
        fileSizeBytes: 5242880, // 5 MB
        downloadedAt: DateTime(2026, 10, 4, 12, 0),
        lyrics: 'يا سيدي الحبيب إليك صلاتي',
        source: HymnSource.taranimar,
        duration: const Duration(minutes: 4, seconds: 12),
      );

      final map = downloaded.toMap();
      expect(map['id'], '101');
      expect(map['fileSizeBytes'], 5242880);
      expect(map['source'], 'taranimar');

      final deserialized = DownloadedHymn.fromMap(map);
      expect(deserialized.id, downloaded.id);
      expect(deserialized.title, downloaded.title);
      expect(deserialized.singer, downloaded.singer);
      expect(deserialized.localFilePath, downloaded.localFilePath);
      expect(deserialized.fileSizeBytes, downloaded.fileSizeBytes);
      expect(deserialized.duration?.inSeconds, 252);

      final hymn = deserialized.toHymn();
      expect(hymn.id, '101');
      expect(hymn.audioUrl, downloaded.localFilePath);
      expect(hymn.lyrics, downloaded.lyrics);
    });

    test('OfflineStorageService.formatBytes produces expected human-readable strings', () {
      expect(OfflineStorageService.formatBytes(512), '512 بايت');
      expect(OfflineStorageService.formatBytes(2048), '2.0 كيلوبايت');
      expect(OfflineStorageService.formatBytes(5242880), '5.0 ميجابايت');
      expect(OfflineStorageService.formatBytes(15728640), '15.0 ميجابايت');
    });

    test('DownloadedHymn offline search matches title, singer, and lyrics', () {
      final list = [
        DownloadedHymn(
          id: '1',
          title: 'يسوع فادي النفس',
          singer: 'ماهر فايز',
          localFilePath: '/path/1.mp3',
          fileSizeBytes: 1000,
          downloadedAt: DateTime.now(),
          lyrics: 'في وسط آلامي أراك تعزيني',
        ),
        DownloadedHymn(
          id: '2',
          title: 'نعظم دم الصليب',
          singer: 'فريق الحياة الأفضل',
          localFilePath: '/path/2.mp3',
          fileSizeBytes: 2000,
          downloadedAt: DateTime.now(),
          lyrics: 'يا فادينا العظيم',
        ),
      ];

      // Query by singer
      final bySinger = list.where((h) => h.singer!.contains('ماهر')).toList();
      expect(bySinger.length, 1);
      expect(bySinger.first.id, '1');

      // Query by lyrics
      final byLyrics = list.where((h) => h.lyrics!.contains('دم الصليب') || h.title.contains('دم الصليب')).toList();
      expect(byLyrics.length, 1);
      expect(byLyrics.first.id, '2');
    });
  });
}
