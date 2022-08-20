import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/state_manager.dart';

import '../../../tarnemma.dart';
import '../home_controller.dart';

class TraneemList extends StatelessWidget {
  const TraneemList({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: controller.traneem.length,
      itemBuilder: (context, index) {
        final t = controller.traneem[index] as Tarnemma;
        return ListTile(
          title: Text(
            t.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              t.downloadProcess.value == DownloadTaskStatus.complete
                  ? const IconButton(icon: Icon(Icons.check), onPressed: null)
                  : Obx(() =>
                      t.downloadProcess.value == DownloadTaskStatus.running
                          ? const Center(
                              child: IconButton(
                              onPressed: null,
                              icon: SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator()),
                            ))
                          : IconButton(
                              onPressed: () => t.download(),
                              icon: const Icon(Icons.download))),
              IconButton(
                  onPressed: () => t.play(),
                  icon: const Icon(Icons.play_arrow)),
            ],
          ),
        );
      },
    );
  }
}
