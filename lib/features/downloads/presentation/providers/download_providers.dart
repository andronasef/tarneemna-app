import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/downloads/data/sources/download_manager_service.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';

final offlineStorageServiceProvider = Provider<OfflineStorageService>((ref) {
  throw UnimplementedError('offlineStorageServiceProvider must be initialized in ProviderScope');
});

final downloadManagerServiceProvider = Provider<DownloadManagerService>((ref) {
  return DownloadManagerService();
});

class DownloadedHymnsNotifier extends StateNotifier<List<DownloadedHymn>> {
  final OfflineStorageService _storageService;

  DownloadedHymnsNotifier(this._storageService) : super([]) {
    refresh();
  }

  void refresh() {
    state = _storageService.getDownloadedHymns();
    _storageService.syncWithDiskAndDownloader().then((_) {
      // The notifier is recreated by ref.invalidate after each download.
      if (mounted) state = _storageService.getDownloadedHymns();
    });
  }

  Future<void> deleteHymn(String id) async {
    await _storageService.deleteDownloadedHymn(id);
    refresh();
  }

  Future<void> clearAll() async {
    await _storageService.clearAll();
    refresh();
  }
}

final downloadedHymnsListProvider =
    StateNotifierProvider<DownloadedHymnsNotifier, List<DownloadedHymn>>((ref) {
  final storage = ref.watch(offlineStorageServiceProvider);
  return DownloadedHymnsNotifier(storage);
});

final isHymnDownloadedProvider = Provider.family<bool, String>((ref, id) {
  final hymns = ref.watch(downloadedHymnsListProvider);
  return hymns.any((h) => h.id == id);
});

final totalStorageUsageProvider = Provider<int>((ref) {
  final hymns = ref.watch(downloadedHymnsListProvider);
  return hymns.fold(0, (sum, h) => sum + h.fileSizeBytes);
});
