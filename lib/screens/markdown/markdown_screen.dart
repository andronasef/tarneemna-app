import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

class MarkdownPage extends StatefulWidget {
  final String theMarkdownFilePath;
  const MarkdownPage(this.theMarkdownFilePath, {super.key});

  @override
  State<MarkdownPage> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  RxString markdown = "### جاري التحميل...".obs;

  Future<void> loadMarkdown() async {
    try {
      final content = await rootBundle.loadString(widget.theMarkdownFilePath);
      markdown.value = content;
    } catch (e) {
      markdown.value = "### تعذر تحميل الملف\n\nنعتذر، لم نتمكن من قراءة المحتوى في الوقت الحالي.";
    }
  }

  @override
  void initState() {
    super.initState();
    loadMarkdown();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سياسة الخصوصية'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Obx(
                  () => Markdown(
                    data: markdown.value,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    "إغلاق",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
