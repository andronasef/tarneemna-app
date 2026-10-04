import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/audio/presentation/providers/audio_providers.dart';
import 'package:tarneemna/features/library/presentation/providers/library_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(playbackHistoryListProvider);
    final audioHandler = ref.watch(audioHandlerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل الاستماع'),
          actions: [
            if (history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'مسح السجل',
                onPressed: () => _confirmClearHistory(context, ref),
              ),
          ],
        ),
        body: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 72,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'سجل الاستماع فارغ',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الترانيم التي تستمع إليها ستظهر هنا تلقائياً',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (ctx, idx) {
                  final hymn = history[idx];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).cardColor,
                      child: const Icon(Icons.play_circle_fill),
                    ),
                    title: Text(
                      hymn.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: hymn.singer != null
                        ? Text(hymn.singer!, maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: () => audioHandler.playHymn(hymn),
                    ),
                    onTap: () => audioHandler.playHymn(hymn),
                  );
                },
              ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مسح سجل الاستماع'),
          content: const Text('هل أنت متأكد من مسح جميع الترانيم من سجل الاستماع؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(playbackHistoryListProvider.notifier).clear();
              },
              child: const Text('مسح', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
