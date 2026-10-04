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

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReceivePort _port = ReceivePort();
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();

    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    _port.listen((dynamic data) {
      if (data is List && data.length >= 3) {
        final String id = data[0] as String;
        final int rawStatus = data[1] as int;
        final int progress = data[2] as int;
        final status = DownloadTaskStatus.values[rawStatus];
        controller.updateDownloadStatus(id, status, progress);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () async {
                  await Get.to(() => const SettingsScreen());
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
                const SizedBox(height: 10),
                TarnemaSearch(controller: controller),
                const SizedBox(height: 10),
                Expanded(
                  child: Stack(
                    children: [
                      TraneemList(controller: controller),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: MiniPlayer(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
