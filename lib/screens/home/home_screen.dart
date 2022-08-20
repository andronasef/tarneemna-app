import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:tarneemna/screens/settings/settings_screen.dart';

import 'home_controller.dart';
import 'widgets/miniplayer.dart';
import 'widgets/tarneem_list.dart';
import 'widgets/tarnema_search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () async {
                  // go to settings page using navigator
                  await Get.to(const SettingsScreen());
                },
                icon: const Icon(Icons.settings),
                tooltip: "الاعدادات",
              ),
              const SizedBox(width: 10),
            ],
            title: const Text('ترانيمنا'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                TarnemaSearch(controller: controller),
                Expanded(
                    child: Obx(
                  () => controller.loading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : controller.traneem.isNotEmpty
                          ? TraneemList(controller: controller)
                          : const Center(
                              child: Text(
                                  "ادخل اسم الترنيمة في مربع البحث من فضلك...")),
                )),
                const MiniPlayer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final ReceivePort _port = ReceivePort();
  final controller = Get.find<HomeController>();
  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) {
      // String id = data[0];
      // DownloadTaskStatus status = data[1];
      // int progress = data[2];
      // setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
}
