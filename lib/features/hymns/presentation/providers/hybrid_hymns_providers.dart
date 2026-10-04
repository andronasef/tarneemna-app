import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/hymns/data/repositories/hybrid_hymns_repository_impl.dart';
import 'package:tarneemna/features/hymns/data/sources/local_hymn_cache.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/hymns/domain/repositories/hybrid_hymns_repository.dart';
import 'package:tarneemna/features/taranim_arabia/presentation/providers/taranim_arabia_providers.dart';

final hybridHymnsRepositoryProvider = Provider<HybridHymnsRepository>((ref) {
  final taranimRepo = ref.watch(taranimArabiaRepositoryProvider);
  final cache = ref.watch(localHymnCacheProvider);
  return HybridHymnsRepositoryImpl(
    taranimArabiaRepo: taranimRepo,
    cache: cache,
  );
});

final hymnSearchQueryProvider = StateProvider<String>((ref) => '');

final hybridSearchResultsProvider = FutureProvider<List<Hymn>>((ref) async {
  final query = ref.watch(hymnSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.watch(hybridHymnsRepositoryProvider);
  return repo.searchHymns(query);
});
