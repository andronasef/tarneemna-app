import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/audio/data/sources/tarneemna_audio_handler.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioQueue & Converter Tests', () {
    test('Hymn to MediaItem and back preserves all properties', () {
      const hymn = Hymn(
        id: '42',
        title: 'نعظم اسم يسوع',
        singer: 'فريق أنهار الحياة',
        album: 'يفتح وليس من يغلق',
        audioUrl: 'https://taranimarabia.org/music/42.mp3',
        lyrics: 'كلمات الترنيمة',
        singerId: '10',
        albumId: '20',
        chordsUrl: 'https://taranimarabia.org/Files/Chords/42.pdf',
        notesUrl: 'https://taranimarabia.org/Files/MusicNotes/42.pdf',
        source: HymnSource.taranimar,
      );

      final mediaItem = TarneemnaAudioHandler.hymnToMediaItem(hymn);
      expect(mediaItem.id, '42');
      expect(mediaItem.title, 'نعظم اسم يسوع');
      expect(mediaItem.artist, 'فريق أنهار الحياة');
      expect(mediaItem.album, 'يفتح وليس من يغلق');
      expect(mediaItem.extras?['lyrics'], 'كلمات الترنيمة');

      final reconstructed = TarneemnaAudioHandler.mediaItemToHymn(mediaItem);
      expect(reconstructed.id, hymn.id);
      expect(reconstructed.title, hymn.title);
      expect(reconstructed.singer, hymn.singer);
      expect(reconstructed.album, hymn.album);
      expect(reconstructed.lyrics, hymn.lyrics);
      expect(reconstructed.source, HymnSource.taranimar);
      expect(reconstructed.chordsUrl, hymn.chordsUrl);
      expect(reconstructed.notesUrl, hymn.notesUrl);
    });

    test('Queue operations add and remove items properly', () async {
      final handler = TarneemnaAudioHandler();

      const item1 = MediaItem(id: '1', title: 'Track 1');
      const item2 = MediaItem(id: '2', title: 'Track 2');
      const item3 = MediaItem(id: '3', title: 'Track 3');

      await handler.addQueueItems([item1, item2, item3]);
      expect(handler.queue.value.length, 3);
      expect(handler.queue.value[0].id, '1');
      expect(handler.queue.value[1].id, '2');
      expect(handler.queue.value[2].id, '3');

      // Remove item at index 1
      await handler.removeQueueItemAt(1);
      expect(handler.queue.value.length, 2);
      expect(handler.queue.value[0].id, '1');
      expect(handler.queue.value[1].id, '3');
    });
  });
}
