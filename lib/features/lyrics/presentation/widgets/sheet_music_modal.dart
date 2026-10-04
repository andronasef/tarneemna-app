import 'package:flutter/material.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:url_launcher/url_launcher.dart';

class SheetMusicModal extends StatelessWidget {
  final Hymn hymn;

  const SheetMusicModal({super.key, required this.hymn});

  Future<void> _openUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر فتح الرابط المطلوب')),
          );
        }
      }
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
              const SizedBox(height: 16),
              const Text(
                'النوتة الموسيقية والكوردات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              if (!hasChords && !hasNotes)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.music_off_outlined, size: 54, color: Colors.grey[600]),
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
                    subtitle: const Text('صورة النوتة الموسيقية الأصلية'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(context, notesUrl),
                  ),
                if (hasChords)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.piano, color: Colors.black),
                    ),
                    title: const Text('عرض الكوردات (Chords PDF)'),
                    subtitle: const Text('كوردات الجيتار والأورج بصيغة PDF'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl(context, chordsUrl),
                  ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
