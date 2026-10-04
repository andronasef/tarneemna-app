import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/taranim_arabia/data/sources/taranim_arabia_remote_data_source.dart';
import 'package:tarneemna/features/taranim_arabia/domain/exceptions/taranim_arabia_exception.dart';

void main() {
  group('TaranimArabiaRemoteDataSource Tests', () {
    const searchHtmlFixture = '''
      <div class="col-lg-6">
        <div class="song-info-box">
          <img class="float-right" src="https://taranimarabia.org/images/album/136.jpg" />
          <div class="song-info">
            <a href="https://taranimarabia.org/song/7">
              <h4 class="text-right">نعظم اسم يسوع <span>(3814)</span></h4>
            </a>
            <p class="text-right">المرنم : <a href="https://taranimarabia.org/singer/270">فريق أنهار الحياة</a></p>
          </div>
        </div>
      </div>
    ''';

    const songDetailHtmlFixture = '''
      <div class="song-info-box">
        <a href="https://taranimarabia.org/song/7">
          <h4 class="text-right">نعظم اسم يسوع</h4>
        </a>
        <p class="text-right">المرنم : <a href="https://taranimarabia.org/singer/270">فريق أنهار الحياة</a></p>
        <p class="text-right">الألبوم : <a href="https://taranimarabia.org/album/136">يفتح وليس من يغلق</a></p>
        <p class="text-right">المؤلف : <a href="https://taranimarabia.org/poet/223">سماح وليم</a></p>
      </div>
      <div class="single_player_container">
        <li track="https://taranimarabia.org/music/7.mp3" title="نعظم اسم يسوع"></li>
        <a href="https://taranimarabia.org/Files/Chords/7.pdf">كورد</a>
        <a href="https://taranimarabia.org/Files/MusicNotes/7.gif">نوتة</a>
      </div>
      <div id="words7" class="container">
        <p dir="rtl" align="center">القرار- نعظم اسم يسوع<br>ليس بغيره الخلاص</p>
      </div>
    ''';

    const singersHtmlFixture = '''
      <div class="playlist-item">
        <a href="https://taranimarabia.org/singer/423">
          <img src="images/singer/423.jpg" />
          <h4>Kings Movement Team</h4>
        </a>
      </div>
    ''';

    const albumsHtmlFixture = '''
      <div class="playlist-item">
        <a href="https://taranimarabia.org/album/136">
          <img src="https://taranimarabia.org/images/album/136.jpeg" />
          <h4>يفتح وليس من يغلق</h4>
        </a>
      </div>
    ''';

    const homepageHtmlFixture = '''
      <div class="premium-item">
        <img src="images/album/featured.jpg" />
        <a href="https://taranimarabia.org/song/16088">
          <h4>الليلة يوم جديد</h4>
        </a>
        <a href="https://taranimarabia.org/singer/1594">
          <h4>ترانيم سودانية</h4>
        </a>
      </div>
    ''';

    test('searchSongs returns parsed list of hymns', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/search') {
          return http.Response(searchHtmlFixture, 200, headers: {'content-type': 'text/html; charset=utf-8'});
        }
        return http.Response('Not Found', 404);
      });

      final dataSource = TaranimArabiaRemoteDataSource(client: mockClient);
      final results = await dataSource.searchSongs('يسوع');

      expect(results.length, 1);
      final hymn = results.first;
      expect(hymn.id, '7');
      expect(hymn.title, 'نعظم اسم يسوع');
      expect(hymn.singer, 'فريق أنهار الحياة');
      expect(hymn.singerId, '270');
      expect(hymn.audioUrl, 'https://taranimarabia.org/music/7.mp3');
      expect(hymn.artworkUrl, 'https://taranimarabia.org/images/album/136.jpg');
      expect(hymn.source, HymnSource.taranimar);
    });

    test('getSongDetails parses full metadata, lyrics, and direct mp3 URL', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/song/7') {
          return http.Response(songDetailHtmlFixture, 200, headers: {'content-type': 'text/html; charset=utf-8'});
        }
        return http.Response('Not Found', 404);
      });

      final dataSource = TaranimArabiaRemoteDataSource(client: mockClient);
      final hymn = await dataSource.getSongDetails('7');

      expect(hymn.id, '7');
      expect(hymn.title, 'نعظم اسم يسوع');
      expect(hymn.singer, 'فريق أنهار الحياة');
      expect(hymn.album, 'يفتح وليس من يغلق');
      expect(hymn.albumId, '136');
      expect(hymn.audioUrl, 'https://taranimarabia.org/music/7.mp3');
      expect(hymn.lyrics, 'القرار- نعظم اسم يسوع\nليس بغيره الخلاص');
      expect(hymn.chordsUrl, 'https://taranimarabia.org/Files/Chords/7.pdf');
      expect(hymn.notesUrl, 'https://taranimarabia.org/Files/MusicNotes/7.gif');
      expect(hymn.metadata['poet'], 'سماح وليم');
    });

    test('getSingers parses singers directory', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/allsingers') {
          return http.Response(singersHtmlFixture, 200, headers: {'content-type': 'text/html; charset=utf-8'});
        }
        return http.Response('Not Found', 404);
      });

      final dataSource = TaranimArabiaRemoteDataSource(client: mockClient);
      final singers = await dataSource.getSingers();

      expect(singers.length, 1);
      expect(singers.first.id, '423');
      expect(singers.first.name, 'Kings Movement Team');
      expect(singers.first.imageUrl, 'https://taranimarabia.org/images/singer/423.jpg');
    });

    test('getAlbums parses albums directory', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/albums') {
          return http.Response(albumsHtmlFixture, 200, headers: {'content-type': 'text/html; charset=utf-8'});
        }
        return http.Response('Not Found', 404);
      });

      final dataSource = TaranimArabiaRemoteDataSource(client: mockClient);
      final albums = await dataSource.getAlbums();

      expect(albums.length, 1);
      expect(albums.first.id, '136');
      expect(albums.first.title, 'يفتح وليس من يغلق');
    });

    test('getHymnOfTheDay parses homepage featured item', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/') {
          return http.Response(homepageHtmlFixture, 200, headers: {'content-type': 'text/html; charset=utf-8'});
        }
        return http.Response('Not Found', 404);
      });

      final dataSource = TaranimArabiaRemoteDataSource(client: mockClient);
      final hymn = await dataSource.getHymnOfTheDay();

      expect(hymn, isNotNull);
      expect(hymn!.id, '16088');
      expect(hymn.title, 'الليلة يوم جديد');
      expect(hymn.singer, 'ترانيم سودانية');
      expect(hymn.singerId, '1594');
    });

    test('HTTP error throws TaranimArabiaException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final dataSource = TaranimArabiaRemoteDataSource(client: mockClient);

      expect(
        () => dataSource.searchSongs('test'),
        throwsA(isA<TaranimArabiaNetworkException>()),
      );
    });
  });
}
