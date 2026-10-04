import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/domain/entities/downloaded_hymn.dart';
import 'package:tarneemna/features/downloads/presentation/providers/download_providers.dart';

class OfflineDownloadsScreen extends ConsumerStatefulWidget {
  const OfflineDownloadsScreen({super.key});

  @override
  ConsumerState<OfflineDownloadsScreen> createState() => _OfflineDownloadsScreenState();
}

class _OfflineDownloadsScreenState extends ConsumerState<OfflineDownloadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadedHymns = ref.watch(downloadedHymnsListProvider);
    final totalBytes = ref.watch(totalStorageUsageProvider);
    final audioHandler = ref.watch(audioHandlerProvider);

    final filtered = downloadedHymns.where((h) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final inTitle = h.title.toLowerCase().contains(q);
      final inSinger = h.singer?.toLowerCase().contains(q) ?? false;
      final inLyrics = h.lyrics?.toLowerCase().contains(q) ?? false;
      return inTitle || inSinger || inLyrics;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الترانيم المحملة'),
          actions: [
            if (downloadedHymns.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Chip(
                    label: Text(
                      OfflineStorageService.formatBytes(totalBytes),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'بحث في الترانيم المحملة...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Play All & Shuffle Buttons
            if (filtered.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('تشغيل الكل (${filtered.length})'),
                        onPressed: () {
                          final hymns = filtered.map((d) => d.toHymn()).toList();
                          audioHandler.playQueue(hymns, startIndex: 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.shuffle_rounded),
                      tooltip: 'تشغيل عشوائي',
                      onPressed: () {
                        final hymns = filtered.map((d) => d.toHymn()).toList()..shuffle();
                        audioHandler.playQueue(hymns, startIndex: 0);
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Hymns List or Empty State
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_download_outlined,
                            size: 72,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'لا توجد نتائج مطابقة لبحثك'
                                : 'لا توجد ترانيم محملة حالياً',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'يمكنك تحميل الترانيم للاستماع إليها بدون إنترنت',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final item = filtered[idx];
                        return _buildHymnTile(context, ref, item, audioHandler);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHymnTile(
    BuildContext context,
    WidgetRef ref,
    DownloadedHymn hymn,
    dynamic audioHandler,
  ) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: hymn.artworkUrl != null
            ? Image.network(
                hymn.artworkUrl!,
                fit: BoxFit.cover,
                cacheWidth: 150,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/icon.png',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/icon.png',
                fit: BoxFit.cover,
              ),
      ),
      title: Text(
        hymn.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${hymn.singer ?? "ترانيم عربية"} • ${OfflineStorageService.formatBytes(hymn.fileSizeBytes)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        tooltip: 'حذف من التحميلات',
        onPressed: () => _confirmDelete(context, ref, hymn),
      ),
      onTap: () {
        audioHandler.playHymn(hymn.toHymn());
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DownloadedHymn hymn) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الترنيمة المحملة'),
          content: Text('هل أنت متأكد من حذف «${hymn.title}» من الترانيم المحملة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(downloadedHymnsListProvider.notifier).deleteHymn(hymn.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حذف «${hymn.title}» من التحميلات')),
                  );
                }
              },
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
