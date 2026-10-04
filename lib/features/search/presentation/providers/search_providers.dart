import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/search/data/sources/search_history_service.dart';

final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  throw UnimplementedError('searchHistoryServiceProvider must be initialized');
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final SearchHistoryService _service;

  SearchHistoryNotifier(this._service) : super(_service.getQueries()) {
    _service.listenable.addListener(_sync);
  }

  void _sync() {
    state = _service.getQueries();
  }

  Future<void> addQuery(String query) async {
    await _service.addQuery(query);
    _sync();
  }

  Future<void> removeQuery(String query) async {
    await _service.removeQuery(query);
    _sync();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    _sync();
  }

  @override
  void dispose() {
    _service.listenable.removeListener(_sync);
    super.dispose();
  }
}

final searchHistoryListProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  final service = ref.watch(searchHistoryServiceProvider);
  return SearchHistoryNotifier(service);
});
