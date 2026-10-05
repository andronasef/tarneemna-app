import 'package:flutter/material.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/utils/open_urls.dart';

class SheetMusicModal extends StatelessWidget {
  final Hymn hymn;

  const SheetMusicModal({super.key, required this.hymn});

  Future<void> _openUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    if (!await openUrl(urlString) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الرابط المطلوب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chordsUrl = hymn.chordsUrl;
    final notesUrl = hymn.notesUrl;
    final hasChords = chordsUrl != null && chordsUrl.isNotEmpty;
    final hasNotes = notesUrl != null && notesUrl.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'النوتة الموسيقية والكوردات',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!hasChords && !hasNotes)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.music_off_outlined,
                          size: 54, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      const Text(
                        'لا تتوفر نوتة موسيقية أو كوردات لهذه الترنيمة',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                )
              else ...[
                if (hasNotes)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.music_note, color: Colors.white),
                    ),
                    title: const Text('عرض النوتة الموسيقية (Music Sheet)'),
                    subtitle: Text(
                      notesUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(context, notesUrl),
                  ),
                if (hasChords)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.queue_music, color: Colors.black),
                    ),
                    title: const Text('عرض الكوردات الموسيقية (Chords)'),
                    subtitle: Text(
                      chordsUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(context, chordsUrl),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
