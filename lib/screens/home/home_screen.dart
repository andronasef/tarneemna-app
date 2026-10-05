import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/settings/presentation/screens/settings_screen.dart';

import '../../widgets/offline_banner.dart';
import 'home_controller.dart';
import 'widgets/miniplayer.dart';
import 'widgets/tarnema_search.dart';
import 'widgets/tarneem_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

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
                    const OfflineBanner(),
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
