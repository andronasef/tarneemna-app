import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:tarneemna/features/lyrics/presentation/widgets/quote_card_dialog.dart';

class LyricsBottomSheet extends StatefulWidget {
  final Hymn hymn;

  const LyricsBottomSheet({super.key, required this.hymn});

  @override
  State<LyricsBottomSheet> createState() => _LyricsBottomSheetState();
}

class _LyricsBottomSheetState extends State<LyricsBottomSheet> {
  double _fontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final lyrics = widget.hymn.lyrics;
    final hasLyrics = lyrics != null && lyrics.trim().isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hymn.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (widget.hymn.singer != null)
                          Text(
                            widget.hymn.singer!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  if (hasLyrics) ...[
                    IconButton(
                      icon: const Icon(Icons.format_quote_outlined),
                      tooltip: 'مشاركة كبطاقة صورة',
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => QuoteCardDialog(hymn: widget.hymn),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      tooltip: 'نسخ الكلمات',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: lyrics));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ كلمات الترنيمة إلى الحافظة')),
                        );
                      },
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Font Scaling Toolbar
            if (hasLyrics)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('حجم الخط: ', style: TextStyle(color: Colors.grey)),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: _fontSize > 14
                          ? () => setState(() => _fontSize = (_fontSize - 2).clamp(14, 30))
                          : null,
                    ),
                    Text('${_fontSize.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: _fontSize < 30
                          ? () => setState(() => _fontSize = (_fontSize + 2).clamp(14, 30))
                          : null,
                    ),
                  ],
                ),
              ),

            // Lyrics Text
            Expanded(
              child: hasLyrics
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        lyrics,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: 1.8,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lyrics_outlined, size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          const Text(
                            'الكلمات غير متوفرة لهذه الترنيمة حالياً',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
