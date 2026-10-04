import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/features/downloads/data/sources/offline_storage_service.dart';
import 'package:tarneemna/features/downloads/presentation/providers/download_providers.dart';

class StorageManagerScreen extends ConsumerStatefulWidget {
  const StorageManagerScreen({super.key});

  @override
  ConsumerState<StorageManagerScreen> createState() => _StorageManagerScreenState();
}

class _StorageManagerScreenState extends ConsumerState<StorageManagerScreen> {
  final Set<String> _selectedHymnIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final downloadedHymns = ref.watch(downloadedHymnsListProvider);
    final totalBytes = ref.watch(totalStorageUsageProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة التخزين'),
          actions: [
            if (_isSelectionMode && _selectedHymnIds.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                tooltip: 'حذف المحدد (${_selectedHymnIds.length})',
                onPressed: () => _confirmDeleteSelected(context, ref),
              ),
            if (downloadedHymns.isNotEmpty)
              IconButton(
                icon: Icon(_isSelectionMode ? Icons.close : Icons.select_all),
                tooltip: _isSelectionMode ? 'إلغاء التحديد' : 'تحديد متعدد',
                onPressed: () {
                  setState(() {
                    _isSelectionMode = !_isSelectionMode;
                    _selectedHymnIds.clear();
                  });
                },
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Overview Storage Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المساحة المستخدمة للترانيم:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          OfflineStorageService.formatBytes(totalBytes),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (totalBytes / (1024 * 1024 * 1024)).clamp(0.01, 1.0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي الترانيم المحملة: ${downloadedHymns.length}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (downloadedHymns.isNotEmpty)
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            icon: const Icon(Icons.delete_forever, size: 20),
                            label: const Text('مسح الكل'),
                            onPressed: () => _confirmClearAll(context, ref),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'الترانيم المخزنة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            if (downloadedHymns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      const Text(
                        'لا توجد ملفات صوتية مخزنة على الجهاز',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...downloadedHymns.map((hymn) {
                final isSelected = _selectedHymnIds.contains(hymn.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedHymnIds.add(hymn.id);
                                } else {
                                  _selectedHymnIds.remove(hymn.id);
                                }
                              });
                            },
                          )
                        : const Icon(Icons.audio_file_outlined),
                    title: Text(hymn.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${hymn.singer ?? "غير محدد"} • ${OfflineStorageService.formatBytes(hymn.fileSizeBytes)}',
                    ),
                    trailing: !_isSelectionMode
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              await ref
                                  .read(downloadedHymnsListProvider.notifier)
                                  .deleteHymn(hymn.id);
                            },
                          )
                        : null,
                    onTap: _isSelectionMode
                        ? () {
                            setState(() {
                              if (isSelected) {
                                _selectedHymnIds.remove(hymn.id);
                              } else {
                                _selectedHymnIds.add(hymn.id);
                              }
                            });
                          }
                        : null,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الترانيم المحددة'),
          content: Text('هل أنت متأكد من حذف ${_selectedHymnIds.length} ترنيمة محملة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                final notifier = ref.read(downloadedHymnsListProvider.notifier);
                for (final id in _selectedHymnIds) {
                  await notifier.deleteHymn(id);
                }
                setState(() {
                  _selectedHymnIds.clear();
                  _isSelectionMode = false;
                });
              },
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مسح كافة الترانيم المحملة'),
          content: const Text(
            'سيتم حذف كافة الملفات الصوتية للترانيم المحملة لتوفير مساحة التخزين على جهازك. هل تريد المتابعة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(downloadedHymnsListProvider.notifier).clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تفريغ كافة الترانيم المحملة بنجاح')),
                  );
                }
              },
              child: const Text('تفريغ الكل', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
