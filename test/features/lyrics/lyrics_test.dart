import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lyrics Tests', () {
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
