import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/core/routes.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/tarnemma.dart';

void main() {
  test('App constants and routes validation', () {
    expect(AppDetails.kAppName, 'ترانيمنا');
    expect(AppDetails.kAppPackageName, 'com.increase.tarneemna');
    expect(AppPages.initial, Routes.home);
    expect(AppPages.routes.isNotEmpty, true);
  });

  test('Tarnemma filename sanitizer tests', () {
    expect(
      Tarnemma.sanitizeFileName('ترنيمة حلوة / جديدة * رائعة: 2024?'),
      'ترنيمة حلوة _ جديدة _ رائعة_ 2024_',
    );
    expect(Tarnemma.sanitizeFileName('Normal Song Title'), 'Normal Song Title');
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
}
