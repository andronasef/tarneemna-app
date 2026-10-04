import 'package:flutter/foundation.dart';
import 'package:tarneemna/features/hymns/data/sources/local_hymn_cache.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/hymns/domain/repositories/hybrid_hymns_repository.dart';
import 'package:tarneemna/features/taranim_arabia/domain/repositories/taranim_arabia_repository.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';

class HybridHymnsRepositoryImpl implements HybridHymnsRepository {
  final TaranimArabiaRepository _taranimArabiaRepo;
  final LocalHymnCache? _cache;

  HybridHymnsRepositoryImpl({
    required TaranimArabiaRepository taranimArabiaRepo,
    LocalHymnCache? cache,
  })  : _taranimArabiaRepo = taranimArabiaRepo,
        _cache = cache;

  static String normalizeTitle(String title) {
    var s = title.trim();
    // Remove diacritics
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // Normalize alef
    s = s.replaceAll(RegExp(r'[أإآ]'), 'ا');
    // Normalize teh marbuta
    s = s.replaceAll('ة', 'ه');
    // Normalize yaa
    s = s.replaceAll('ى', 'ي');
    // Remove punctuation, brackets, parentheses
    s = s.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
    // Collapse multiple spaces
    s = s.replaceAll(RegExp(r'\s+'), ' ').toLowerCase().trim();
    return s;
  }

  @override
  Future<List<Hymn>> searchHymns(String query, {bool includeYouTube = true}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    // 1 & 2. Query Taranim Arabia and YouTube in parallel
    final results = await Future.wait([
      _taranimArabiaRepo.searchSongs(cleanQuery).catchError((Object e) {
        if (kDebugMode) print('Taranim Arabia search error: $e');
        return <Hymn>[];
      }),
      if (includeYouTube) YouTubeAudioResolver.searchVideos(cleanQuery),
    ]);
    final taranimResults = results[0];
    final youtubeResults = results.length > 1 ? results[1] : const <Hymn>[];

    // 3. Deduplicate: prioritize Taranim Arabia results
    final seenNormalizedTitles = <String>{};
    final combined = <Hymn>[];

    for (final hymn in taranimResults) {
      final norm = normalizeTitle(hymn.title);
      if (norm.isNotEmpty) {
        seenNormalizedTitles.add(norm);
      }
      combined.add(hymn);
    }

    for (final hymn in youtubeResults) {
      final norm = normalizeTitle(hymn.title);
      // Check if title is already represented by a Taranim Arabia track
      final alreadyPresent = seenNormalizedTitles.any((seen) =>
          norm.contains(seen) || seen.contains(norm) && seen.length > 4);

      if (!alreadyPresent) {
        if (norm.isNotEmpty) {
          seenNormalizedTitles.add(norm);
        }
        combined.add(hymn);
      }
    }

    final cache = _cache;
    if (cache != null && combined.isNotEmpty) {
      await cache.cacheHymns(combined);
    }

    return combined;
  }

  @override
  Future<Hymn> getHymnDetails(Hymn hymn) async {
    if (hymn.source == HymnSource.taranimar) {
      return _taranimArabiaRepo.getSongDetails(hymn.id);
    }

    // YouTube source: resolve audioUrl if not present
    if (hymn.audioUrl == null || hymn.audioUrl!.isEmpty) {
      final url = await YouTubeAudioResolver.getAudioUrl(hymn.id);
      final updated = hymn.copyWith(audioUrl: url);
      final cache = _cache;
      if (cache != null) {
        await cache.cacheHymn(updated);
      }
      return updated;
    }

    return hymn;
  }

  @override
  Future<Hymn?> getHymnOfTheDay() {
    return _taranimArabiaRepo.getHymnOfTheDay();
  }
}
