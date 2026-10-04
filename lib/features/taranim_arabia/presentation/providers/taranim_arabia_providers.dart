import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tarneemna/features/hymns/data/sources/local_hymn_cache.dart';
import 'package:tarneemna/features/hymns/domain/entities/album.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/hymns/domain/entities/singer.dart';
import 'package:tarneemna/features/taranim_arabia/domain/repositories/taranim_arabia_repository.dart';
import 'package:tarneemna/features/taranim_arabia/data/repositories/taranim_arabia_repository_impl.dart';
import 'package:tarneemna/features/taranim_arabia/data/sources/taranim_arabia_remote_data_source.dart';

final taranimArabiaRemoteDataSourceProvider =
    Provider<TaranimArabiaRemoteDataSource>((ref) {
  return TaranimArabiaRemoteDataSource();
});

final taranimArabiaRepositoryProvider = Provider<TaranimArabiaRepository>((ref) {
  final remoteDataSource = ref.watch(taranimArabiaRemoteDataSourceProvider);
  final cache = ref.watch(localHymnCacheProvider);
  return TaranimArabiaRepositoryImpl(
    remoteDataSource: remoteDataSource,
    cache: cache,
  );
});

final hymnOfTheDayProvider = FutureProvider<Hymn?>((ref) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  return repo.getHymnOfTheDay();
});

final singersListProvider = FutureProvider<List<Singer>>((ref) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  return repo.getSingers();
});

/// Fetches random singers across the entire 24 pages of the website library
final randomizedSingersProvider = FutureProvider<List<Singer>>((ref) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  final rng = Random();
  // Fetch from 2 distinct random pages (total 24 pages in library) to give rich variety
  final page1 = rng.nextInt(24) + 1;
  var page2 = rng.nextInt(24) + 1;
  while (page2 == page1) {
    page2 = rng.nextInt(24) + 1;
  }

  try {
    final results = await Future.wait([
      repo.getSingers(page: page1),
      repo.getSingers(page: page2),
    ]);
    final combined = [...results[0], ...results[1]];
    if (combined.isEmpty) {
      return repo.getSingers(page: 1);
    }
    combined.shuffle(rng);
    return combined;
  } catch (_) {
    return repo.getSingers(page: 1);
  }
});

/// Fetches random albums across the entire 91 pages of the website library
final randomizedAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  final rng = Random();
  // Pick 2 distinct random pages from the entire catalog (91 pages total)
  final page1 = rng.nextInt(91) + 1;
  var page2 = rng.nextInt(91) + 1;
  while (page2 == page1) {
    page2 = rng.nextInt(91) + 1;
  }

  try {
    final results = await Future.wait([
      repo.getAlbums(page: page1),
      repo.getAlbums(page: page2),
    ]);
    // Album == is by id, so the Set drops duplicates; skip albums without a cover.
    final combined = {...results[0], ...results[1]}
        .where((a) => a.imageUrl != null)
        .toList();
    if (combined.isEmpty) {
      return repo.getAlbums(page: 1);
    }
    combined.shuffle(rng);
    return combined.take(12).toList();
  } catch (_) {
    return repo.getAlbums(page: 1);
  }
});

/// Search/list results lack lyrics, chords and notes; fetch them on demand.
/// Falls back to the given hymn if it's not from Taranim Arabia or the fetch fails.
final hymnDetailsProvider = FutureProvider.family<Hymn, Hymn>((ref, hymn) async {
  final hasDetails = hymn.lyrics != null && hymn.lyrics!.trim().isNotEmpty;
  if (hymn.source != HymnSource.taranimar || hasDetails) return hymn;
  try {
    final details = await ref.watch(taranimArabiaRepositoryProvider).getSongDetails(hymn.id);
    // Keep what we already know (e.g. artwork from the list page).
    return details.copyWith(
      title: hymn.title,
      singer: hymn.singer,
      artworkUrl: hymn.artworkUrl ?? details.artworkUrl,
    );
  } catch (_) {
    return hymn;
  }
});

final singerSongsProvider = FutureProvider.family<List<Hymn>, String>((ref, singerId) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  return repo.getSingerSongs(singerId);
});

final albumSongsProvider = FutureProvider.family<List<Hymn>, String>((ref, albumId) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  return repo.getAlbumSongs(albumId);
});
