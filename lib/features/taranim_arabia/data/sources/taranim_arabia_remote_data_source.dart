import 'dart:math';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:tarneemna/features/hymns/domain/entities/album.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/singer.dart';
import 'package:tarneemna/features/taranim_arabia/domain/exceptions/taranim_arabia_exception.dart';

class TaranimArabiaRemoteDataSource {
  static const String baseUrl = 'https://taranimarabia.org';
  final http.Client _client;

  TaranimArabiaRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'ar,en-US;q=0.9,en;q=0.8',
      };

  static String _cleanUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.endsWith('/images/album/') || url.endsWith('/album/') || url.endsWith('/album') || url.endsWith('/images/album')) {
      return '';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }

  Future<Uint8List> _getHtml(String pathOrUrl) async {
    final uri = pathOrUrl.startsWith('http')
        ? Uri.parse(pathOrUrl)
        : Uri.parse('$baseUrl$pathOrUrl');

    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 404) {
        throw TaranimArabiaNotFoundException(
            'Resource not found at ${uri.toString()}', response.statusCode);
      }
      if (response.statusCode >= 400) {
        throw TaranimArabiaNetworkException(
          'HTTP ${response.statusCode} error fetching ${uri.toString()}',
          statusCode: response.statusCode,
        );
      }
      return response.bodyBytes;
    } on TaranimArabiaException {
      rethrow;
    } catch (e) {
      throw TaranimArabiaNetworkException(
        'Failed to connect to Taranim Arabia: $e',
        cause: e,
      );
    }
  }

  // Pages are large; decoding + parsing them on the UI isolate dropped frames
  // (home loads 3 pages at once). Static so the closure doesn't capture `this`.
  static Future<T> _parse<T>(Uint8List bytes, T Function(Document) parser) {
    return Isolate.run(() => parser(html_parser.parse(utf8.decode(bytes, allowMalformed: true))));
  }

  /// 1. Search hymns by title/keyword
  Future<List<Hymn>> searchSongs(String query, {int page = 1}) async {
    final encodedQuery = Uri.encodeComponent(query);
    final doc = await _getHtml('/search?searchByWord=$encodedQuery&searchBySinger=0');
    return _parse(doc, parseSearchResults);
  }

  static List<Hymn> parseSearchResults(Document doc) {
    final List<Hymn> results = [];
    final boxes = doc.querySelectorAll('.song-info-box');

    for (final box in boxes) {
      final songLink = box.querySelector('a[href*="/song/"]');
      if (songLink == null) continue;

      final href = songLink.attributes['href'] ?? '';
      final idMatch = RegExp(r'/song/(\d+)').firstMatch(href);
      if (idMatch == null) continue;
      final songId = idMatch.group(1)!;

      final titleElement = songLink.querySelector('h4');
      var title = titleElement?.text.trim() ?? '';
      // Remove listen counter in parentheses if present
      title = title.replaceAll(RegExp(r'\(\s*.*?\s*\)'), '').trim();

      final singerLink = box.querySelector('a[href*="/singer/"]');
      final singerName = singerLink?.text.trim();
      String? singerId;
      if (singerLink != null) {
        final singerHref = singerLink.attributes['href'] ?? '';
        final sMatch = RegExp(r'/singer/(\d+)').firstMatch(singerHref);
        if (sMatch != null) singerId = sMatch.group(1);
      }

      final img = box.querySelector('img');
      final artworkUrl = _cleanUrl(img?.attributes['src']);

      results.add(
        Hymn(
          id: songId,
          title: title.isNotEmpty ? title : 'ترنيمة $songId',
          singer: singerName,
          singerId: singerId,
          audioUrl: '$baseUrl/music/$songId.mp3',
          artworkUrl: artworkUrl.isNotEmpty ? artworkUrl : null,
          source: HymnSource.taranimar,
        ),
      );
    }

    return results;
  }

  /// 2. Get full song details (lyrics, MP3, album, chords, notes)
  Future<Hymn> getSongDetails(String songId) async {
    final doc = await _getHtml('/song/$songId');
    return _parseSongDetails(doc, songId);
  }

  static Future<Hymn> _parseSongDetails(Uint8List bytes, String songId) {
    return Isolate.run(
      () => parseSongDetails(html_parser.parse(utf8.decode(bytes, allowMalformed: true)), songId),
    );
  }

  static Hymn parseSongDetails(Document doc, String songId) {
    final songLink = doc.querySelector('a[href*="/song/$songId"]');
    var title = songLink?.querySelector('h4')?.text.trim() ?? '';
    title = title.replaceAll(RegExp(r'\(\s*.*?\s*\)'), '').trim();

    final singerLink = doc.querySelector('a[href*="/singer/"]');
    final singerName = singerLink?.text.trim();
    String? singerId;
    if (singerLink != null) {
      final sMatch = RegExp(r'/singer/(\d+)').firstMatch(singerLink.attributes['href'] ?? '');
      singerId = sMatch?.group(1);
    }

    final albumLink = doc.querySelector('a[href*="/album/"]');
    final albumName = albumLink?.text.trim();
    String? albumId;
    if (albumLink != null) {
      final aMatch = RegExp(r'/album/(\d+)').firstMatch(albumLink.attributes['href'] ?? '');
      albumId = aMatch?.group(1);
    }

    // Direct MP3 URL
    final trackLi = doc.querySelector('li[track]');
    var audioUrl = trackLi?.attributes['track'];
    if (audioUrl == null || audioUrl.isEmpty) {
      audioUrl = '$baseUrl/music/$songId.mp3';
    } else {
      audioUrl = _cleanUrl(audioUrl);
    }

    // Lyrics from div#words{id}
    final lyricsContainer = doc.querySelector('#words$songId') ??
        doc.querySelector('div[id^="words"]') ??
        doc.querySelector('.words-container');
    String? lyrics;
    if (lyricsContainer != null) {
      final p = lyricsContainer.querySelector('p') ?? lyricsContainer;
      final htmlStr = p.innerHtml;
      lyrics = htmlStr
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();
    }

    // Artwork
    final img = doc.querySelector('.song-info-box img') ?? doc.querySelector('img[src*="/album/"]');
    final artworkUrl = _cleanUrl(img?.attributes['src']);

    // Chords and notes
    final chordsLink = doc.querySelector('a[href*="/Files/Chords/"]');
    final chordsUrl = _cleanUrl(chordsLink?.attributes['href']);

    final notesLink = doc.querySelector('a[href*="/Files/MusicNotes/"]');
    final notesUrl = _cleanUrl(notesLink?.attributes['href']);

    final metadata = <String, dynamic>{};
    final poetLink = doc.querySelector('a[href*="/poet/"]');
    if (poetLink != null) metadata['poet'] = poetLink.text.trim();
    final composerLink = doc.querySelector('a[href*="/composer/"]');
    if (composerLink != null) metadata['composer'] = composerLink.text.trim();
    final distributorLink = doc.querySelector('a[href*="/distributer/"]');
    if (distributorLink != null) metadata['distributor'] = distributorLink.text.trim();

    return Hymn(
      id: songId,
      title: title.isNotEmpty ? title : 'ترنيمة $songId',
      singer: singerName,
      singerId: singerId,
      album: albumName,
      albumId: albumId,
      audioUrl: audioUrl,
      lyrics: lyrics,
      artworkUrl: artworkUrl.isNotEmpty ? artworkUrl : null,
      source: HymnSource.taranimar,
      chordsUrl: chordsUrl.isNotEmpty ? chordsUrl : null,
      notesUrl: notesUrl.isNotEmpty ? notesUrl : null,
      metadata: metadata,
    );
  }

  /// 3. Browse singers directory
  Future<List<Singer>> getSingers({int page = 1}) async {
    final path = page > 1 ? '/allsingers?page=$page' : '/allsingers';
    final doc = await _getHtml(path);
    return _parse(doc, parseSingers);
  }

  static List<Singer> parseSingers(Document doc) {
    final List<Singer> singers = [];
    final items = doc.querySelectorAll('.playlist-item');

    for (final item in items) {
      final link = item.querySelector('a[href*="/singer/"]');
      if (link == null) continue;

      final href = link.attributes['href'] ?? '';
      final match = RegExp(r'/singer/(\d+)').firstMatch(href);
      if (match == null) continue;
      final id = match.group(1)!;

      final name = link.querySelector('h4')?.text.trim() ?? '';
      final img = link.querySelector('img');
      final imageUrl = _cleanUrl(img?.attributes['src']);

      singers.add(
        Singer(
          id: id,
          name: name.isNotEmpty ? name : 'مرنم $id',
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        ),
      );
    }

    return singers;
  }

  /// 4. Get songs by singer
  Future<List<Hymn>> getSingerSongs(String singerId) =>
      _getAllPages('/singer/$singerId');

  /// The site serves ~10 songs per page; walk `?page=N` until one comes back
  /// empty or adds nothing new (guards against a repeated last page).
  /// Pages are fetched [batch] at a time; overshooting the end costs a few requests.
  Future<List<Hymn>> _getAllPages(String path, {int batch = 5}) async {
    final byId = <String, Hymn>{};
    for (var start = 1; start <= 200; start += batch) {
      final pages = await Future.wait([
        for (var page = start; page < start + batch; page++) _getPage(path, page),
      ]);
      for (final songs in pages) {
        final before = byId.length;
        for (final s in songs) {
          byId.putIfAbsent(s.id, () => s);
        }
        if (byId.length == before) return byId.values.toList();
      }
    }
    return byId.values.toList();
  }

  Future<List<Hymn>> _getPage(String path, int page) async {
    try {
      final doc = await _getHtml(page > 1 ? '$path?page=$page' : path);
      return await _parse(doc, parseSearchResults);
    } catch (_) {
      if (page == 1) rethrow; // a missing later page just means we're past the end
      return const [];
    }
  }

  /// 5. Browse albums directory
  Future<List<Album>> getAlbums({int page = 1}) async {
    final path = page > 1 ? '/albums?page=$page' : '/albums';
    final doc = await _getHtml(path);
    return _parse(doc, parseAlbums);
  }

  static List<Album> parseAlbums(Document doc) {
    final List<Album> albums = [];
    final items = doc.querySelectorAll('.playlist-item');

    for (final item in items) {
      final link = item.querySelector('a[href*="/album/"]');
      if (link == null) continue;

      final href = link.attributes['href'] ?? '';
      final match = RegExp(r'/album/(\d+)').firstMatch(href);
      if (match == null) continue;
      final id = match.group(1)!;

      final title = link.querySelector('h4')?.text.trim() ?? '';
      final img = link.querySelector('img');
      final imageUrl = _cleanUrl(img?.attributes['src']);

      albums.add(
        Album(
          id: id,
          title: title.isNotEmpty ? title : 'ألبوم $id',
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        ),
      );
    }

    return albums;
  }

  /// 6. Get songs from album
  Future<List<Hymn>> getAlbumSongs(String albumId) async {
    final doc = await _getHtml('/album/$albumId');
    return _parse(doc, parseSearchResults);
  }

  /// 7. Random Hymn across all 1275 pages of /allsongs catalog
  Future<Hymn?> getHymnOfTheDay({int? page}) async {
    final rng = Random();
    final targetPage = page ?? (rng.nextInt(1275) + 1);
    try {
      final doc = await _getHtml('/allsongs?page=$targetPage');
      final songs = await _parse(doc, parseSearchResults);
      final validSongs = songs.where((s) => s.title.isNotEmpty && !s.title.startsWith('(')).toList();
      if (validSongs.isNotEmpty) {
        validSongs.shuffle(rng);
        return validSongs.first;
      }
    } catch (_) {}

    // Fallback: Check homepage featured item
    try {
      final doc = await _getHtml('/');
      final hymn = await _parse(doc, parseHymnOfTheDay);
      if (hymn != null) return hymn;
    } catch (_) {}

    return null;
  }

  static Hymn? parseHymnOfTheDay(Document doc) {
    final premiumItems = doc.querySelectorAll('.premium-item');
    if (premiumItems.isEmpty) return null;

    final item = premiumItems.first;
    final songLink = item.querySelector('a[href*="/song/"]');
    if (songLink == null) return null;

    final href = songLink.attributes['href'] ?? '';
    final idMatch = RegExp(r'/song/(\d+)').firstMatch(href);
    if (idMatch == null) return null;
    final songId = idMatch.group(1)!;

    final title = songLink.querySelector('h4')?.text.trim() ?? '';

    final singerLink = item.querySelector('a[href*="/singer/"]');
    final singerName = singerLink?.querySelector('h4')?.text.trim() ?? singerLink?.text.trim();
    String? singerId;
    if (singerLink != null) {
      final sMatch = RegExp(r'/singer/(\d+)').firstMatch(singerLink.attributes['href'] ?? '');
      singerId = sMatch?.group(1);
    }

    final img = item.querySelector('img');
    final artworkUrl = _cleanUrl(img?.attributes['src']);

    return Hymn(
      id: songId,
      title: title.isNotEmpty ? title : 'ترنيمة اليوم',
      singer: singerName,
      singerId: singerId,
      audioUrl: '$baseUrl/music/$songId.mp3',
      artworkUrl: artworkUrl.isNotEmpty ? artworkUrl : null,
      source: HymnSource.taranimar,
    );
  }
}
