import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/settings/presentation/screens/settings_screen.dart';

import 'home_controller.dart';
import 'widgets/miniplayer.dart';
import 'widgets/tarnema_search.dart';
import 'widgets/tarneem_list.dart';

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
  final HomeController controller = Get.put(HomeController());
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    _port.listen((dynamic data) {
      if (data is List && data.length >= 3) {
        final id = data[0] as String;
        final rawStatus = data[1] as int;
        final progress = data[2] as int;
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
          body: Stack(
            children: [
              // Main View: App Bar + Search + Lists
              SafeArea(
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const OfflineDownloadsScreen()),
                            );
                          },
                          icon: const Icon(Icons.cloud_download_outlined),
                          tooltip: "الترانيم المحملة",
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ModernSettingsScreen()),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          tooltip: "الإعدادات والمظهر",
                        ),
                        const SizedBox(width: 10),
                      ],
                      title: const Text(AppDetails.kAppName),
                    ),
                    const SizedBox(height: 4),
                    TarnemaSearch(controller: controller),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TraneemList(controller: controller),
                    ),
                  ],
                ),
              ),

              // Miniplayer with Container Transform
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
