import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

class MarkdownPage extends StatefulWidget {
  final String theMarkdownFilePath;
  const MarkdownPage(this.theMarkdownFilePath, {Key? key}) : super(key: key);

  @override
  _MarkdownPageState createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  RxString markdown = "### Loading".obs;

  Future<void> loadMarkdown() async =>
      markdown.value = await rootBundle.loadString(widget.theMarkdownFilePath);

  @override
  void initState() {
    super.initState();
    loadMarkdown();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
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
                      backgroundColor: context.theme.colorScheme.secondary),
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
