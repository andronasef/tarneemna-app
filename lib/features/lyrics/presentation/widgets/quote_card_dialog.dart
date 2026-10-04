import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

class QuoteCardDialog extends StatefulWidget {
  final Hymn hymn;

  const QuoteCardDialog({super.key, required this.hymn});

  @override
  State<QuoteCardDialog> createState() => _QuoteCardDialogState();
}

class _QuoteCardDialogState extends State<QuoteCardDialog> {
  final GlobalKey _cardKey = GlobalKey();
  late List<String> _lines;
  final Set<int> _selectedIndices = {};
  int _selectedThemeIndex = 0;
  bool _isExporting = false;

  final List<List<Color>> _gradientPresets = [
    [const Color(0xFF1E1E2C), const Color(0xFF2D1B36)], // Dark Velvet
    [const Color(0xFF2C3E50), const Color(0xFF000000)], // Midnight OLED
    [const Color(0xFF0D324D), const Color(0xFF7F5A83)], // Celestial Purple
    [const Color(0xFF1A3038), const Color(0xFF2A5298)], // Deep Ocean
  ];

  @override
  void initState() {
    super.initState();
    final rawLyrics = widget.hymn.lyrics ?? '';
    _lines = rawLyrics
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('القرار') && !l.startsWith('1-') && !l.startsWith('2-'))
        .toList();

    // Default select first 2 lines if available
    if (_lines.isNotEmpty) {
      _selectedIndices.add(0);
      if (_lines.length > 1) _selectedIndices.add(1);
    }
  }

  Future<void> _exportAndShareCard() async {
    setState(() => _isExporting = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/tarneemna_quote_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ترنيمة: ${widget.hymn.title}\nتطبيق ترانيمنا',
      );
    } catch (e) {
      if (kDebugMode) print('Error generating quote card: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = _selectedIndices.map((i) => _lines[i]).join('\n');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مشاركة كبطاقة صورة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Card Preview (Captured by RepaintBoundary)
              RepaintBoundary(
                key: _cardKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: _gradientPresets[_selectedThemeIndex],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.format_quote_rounded, size: 36, color: Colors.amberAccent),
                      const SizedBox(height: 14),
                      Text(
                        selectedText.isNotEmpty ? selectedText : widget.hymn.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '— ${widget.hymn.title} —',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      if (widget.hymn.singer != null)
                        Text(
                          widget.hymn.singer!,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'تطبيق ترانيمنا',
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Theme Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_gradientPresets.length, (idx) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedThemeIndex = idx),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _gradientPresets[idx],
                        ),
                        border: _selectedThemeIndex == idx
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Line Selector
              if (_lines.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اختر السطور المراد مشاركتها:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _lines.length,
                    itemBuilder: (ctx, idx) {
                      final isSelected = _selectedIndices.contains(idx);
                      return CheckboxListTile(
                        value: isSelected,
                        dense: true,
                        title: Text(_lines[idx], maxLines: 1, overflow: TextOverflow.ellipsis),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              if (_selectedIndices.length < 4) {
                                _selectedIndices.add(idx);
                              }
                            } else {
                              if (_selectedIndices.length > 1) {
                                _selectedIndices.remove(idx);
                              }
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportAndShareCard,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: const Text('مشاركة الصورة الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
