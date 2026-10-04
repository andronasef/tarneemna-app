import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/audio/domain/services/share_service.dart';

void main() {
  group('Lyrics & ShareService Tests', () {
    test('formatTimestamp correctly formats various durations', () {
      expect(ShareService.formatTimestamp(Duration.zero), '00:00');
      expect(ShareService.formatTimestamp(const Duration(seconds: 45)), '00:45');
      expect(ShareService.formatTimestamp(const Duration(minutes: 1, seconds: 23)), '01:23');
      expect(ShareService.formatTimestamp(const Duration(minutes: 12, seconds: 5)), '12:05');
      expect(ShareService.formatTimestamp(const Duration(minutes: 65, seconds: 30)), '05:30');
    });

    test('Lyrics line filtering preserves spiritual text while ignoring labels', () {
      const rawLyrics = '''
القرار
يسوع أنت ربي وإلهي
لك أهدي حياتي وحبي

1-
في وقت ضيقي ألتجئ إليك
تمسك بيميني وترعاني

2-
سلامك يملأ فؤادي
''';

      final lines = rawLyrics
          .split('\n')
          .map((l) => l.trim())
          .where((l) =>
              l.isNotEmpty &&
              !l.startsWith('القرار') &&
              !l.startsWith('1-') &&
              !l.startsWith('2-'))
          .toList();

      expect(lines.length, 5);
      expect(lines[0], 'يسوع أنت ربي وإلهي');
      expect(lines[1], 'لك أهدي حياتي وحبي');
      expect(lines[2], 'في وقت ضيقي ألتجئ إليك');
      expect(lines[3], 'تمسك بيميني وترعاني');
      expect(lines[4], 'سلامك يملأ فؤادي');
    });
  });
}
