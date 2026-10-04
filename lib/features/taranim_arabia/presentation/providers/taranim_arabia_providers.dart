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

final albumsListProvider = FutureProvider<List<Album>>((ref) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  return repo.getAlbums();
});

final randomizedAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final albums = await ref.watch(albumsListProvider.future);
  if (albums.isEmpty) return const [];
  final random = Random(DateTime.now().day + DateTime.now().month * 100);
  final shuffled = List<Album>.from(albums)..shuffle(random);
  return shuffled.take(12).toList();
});

final singerSongsProvider = FutureProvider.family<List<Hymn>, String>((ref, singerId) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  return repo.getSingerSongs(singerId);
});

final albumSongsProvider = FutureProvider.family<List<Hymn>, String>((ref, albumId) async {
  final repo = ref.watch(taranimArabiaRepositoryProvider);
  return repo.getAlbumSongs(albumId);
});
