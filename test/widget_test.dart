import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/tarnemma.dart';

void main() {
  test('App constants validation', () {
    expect(AppDetails.kAppName, 'ترانيمنا');
    expect(AppDetails.kAppPackageName, 'com.increase.tarneemna');
  });

  test('Tarnemma filename sanitizer tests', () {
    expect(
      Tarnemma.sanitizeFileName('ترنيمة حلوة / جديدة * رائعة: 2024?'),
      'ترنيمة حلوة _ جديدة _ رائعة_ 2024_',
    );
    expect(Tarnemma.sanitizeFileName('Normal Song Title'), 'Normal Song Title');
  });

  test('Tarnemma.formatDuration drops zero hours', () {
    expect(Tarnemma.formatDuration(const Duration(minutes: 3, seconds: 30)), '03:30');
    expect(Tarnemma.formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
  });

  test('Tarnemma lazy initialization does not pre-fetch stream', () {
    final t = Tarnemma(
      title: 'ترنيمة تجريبية',
      id: 'test_id_123',
      duration: '04:15',
      author: 'مرنم',
      thumbnail: 'https://example.com/thumb.jpg',
    );
    expect(t.title, 'ترنيمة تجريبية');
    expect(t.id, 'test_id_123');
    expect(t.duration, '04:15');
    expect(t.downloadUrl, isNull);
    expect(t.isResolvingStream.value, false);
  });

  test('Tarnemma.filterDownloaded matches title or singer, ignoring diacritics', () {
    final d = DownloadedHymn(
      id: '1',
      title: 'يا صاحب الحنان',
      singer: 'مرنم',
      localFilePath: '/tmp/1.mp3',
      fileSizeBytes: 1,
      downloadedAt: DateTime(2026),
    );
    expect(Tarnemma.filterDownloaded([d], 'الحَنان').map((t) => t.id), ['1']);
    expect(Tarnemma.filterDownloaded([d], 'مرنم').map((t) => t.id), ['1']);
    expect(Tarnemma.filterDownloaded([d], 'شيء آخر'), isEmpty);
  });
}
