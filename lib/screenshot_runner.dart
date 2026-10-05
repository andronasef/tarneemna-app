import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/values.dart';
import 'features/audio/data/sources/tarneemna_audio_handler.dart';
import 'features/audio/presentation/providers/audio_providers.dart';
import 'features/audio/presentation/widgets/full_player_view.dart';
import 'features/downloads/data/sources/offline_storage_service.dart';
import 'features/downloads/domain/entities/downloaded_hymn.dart';
import 'features/downloads/presentation/providers/download_providers.dart';
import 'features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'features/hymns/data/sources/local_hymn_cache.dart';
import 'features/hymns/domain/entities/hymn.dart';
import 'features/library/data/sources/personal_library_service.dart';
import 'features/library/presentation/providers/library_providers.dart';
import 'features/library/presentation/screens/playlists_screen.dart';
import 'features/search/data/sources/search_history_service.dart';
import 'features/settings/data/sources/settings_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'player.dart';
import 'screens/home/home_controller.dart';
import 'screens/home/home_screen.dart';
import 'tarnemma.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final localHymnCache = LocalHymnCache();
  await localHymnCache.init();

  final offlineStorageService = OfflineStorageService();
  await offlineStorageService.init();

  final personalLibraryService = PersonalLibraryService();
  await personalLibraryService.init();

  await SearchHistoryService().init();

  final settingsService = SettingsService();
  await settingsService.init();

  // Populate Playlists if fewer than 4
  final existingPlaylists = personalLibraryService.getPlaylists();
  if (existingPlaylists.length < 4) {
    const sampleHymns = [
      Hymn(id: 'h1', title: 'مشيئتك صالحة', singer: 'زياد شحاتة', album: 'مشيئتك', source: HymnSource.taranimar),
      Hymn(id: 'h2', title: 'يسوع أنت ترنيمتي', singer: 'كورال قلب داود', album: 'يسوع ترنيمتي', source: HymnSource.taranimar),
      Hymn(id: 'h3', title: 'علمني أنتظرك يارب', singer: 'ماهر فايز', album: 'انتظار الرب', source: HymnSource.taranimar),
    ];
    final p1 = await personalLibraryService.createPlaylist('صباح الخير يارب');
    for (final h in sampleHymns) {
      await personalLibraryService.addHymnToPlaylist(p1.id, h);
    }
    final p2 = await personalLibraryService.createPlaylist('ترانيم الصوم الكبير');
    for (final h in sampleHymns.take(2)) {
      await personalLibraryService.addHymnToPlaylist(p2.id, h);
    }
    final p3 = await personalLibraryService.createPlaylist('تسبيح وترنيم');
    for (final h in sampleHymns) {
      await personalLibraryService.addHymnToPlaylist(p3.id, h);
    }
    final p4 = await personalLibraryService.createPlaylist('ترانيم أسبوع الآلام');
    for (final h in sampleHymns.take(1)) {
      await personalLibraryService.addHymnToPlaylist(p4.id, h);
    }
    final p5 = await personalLibraryService.createPlaylist('ترانيم القيامة والفرح');
    for (final h in sampleHymns) {
      await personalLibraryService.addHymnToPlaylist(p5.id, h);
    }
    final p6 = await personalLibraryService.createPlaylist('ترانيم السهرة والهدوء');
    for (final h in sampleHymns.take(2)) {
      await personalLibraryService.addHymnToPlaylist(p6.id, h);
    }
  }

  // Populate Offline Downloads
  final existingDownloads = offlineStorageService.getDownloadedHymns();
  if (existingDownloads.length < 5) {
    final downloads = [
      DownloadedHymn(
        id: 'd1',
        title: 'مشيئتك صالحة',
        singer: 'زياد شحاتة',
        album: 'مشيئتك',
        localFilePath: '/tmp/mock/1.mp3',
        fileSizeBytes: 4500000,
        downloadedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 4, seconds: 35),
      ),
      DownloadedHymn(
        id: 'd2',
        title: 'يسوع أنت ترنيمتي',
        singer: 'كورال قلب داود',
        album: 'يسوع ترنيمتي',
        localFilePath: '/tmp/mock/2.mp3',
        fileSizeBytes: 5200000,
        downloadedAt: DateTime.now().subtract(const Duration(hours: 3)),
        duration: const Duration(minutes: 5, seconds: 12),
      ),
      DownloadedHymn(
        id: 'd3',
        title: 'علمني أنتظرك يارب',
        singer: 'ماهر فايز',
        album: 'انتظار الرب',
        localFilePath: '/tmp/mock/3.mp3',
        fileSizeBytes: 3800000,
        downloadedAt: DateTime.now().subtract(const Duration(hours: 5)),
        duration: const Duration(minutes: 3, seconds: 50),
      ),
      DownloadedHymn(
        id: 'd4',
        title: 'يا صاحب الحنان',
        singer: 'ناصف صبحي',
        album: 'يا صاحب الحنان',
        localFilePath: '/tmp/mock/4.mp3',
        fileSizeBytes: 4100000,
        downloadedAt: DateTime.now().subtract(const Duration(hours: 8)),
        duration: const Duration(minutes: 4, seconds: 15),
      ),
      DownloadedHymn(
        id: 'd5',
        title: 'في وقت ضعفي',
        singer: 'هايدي منتصر',
        album: 'في وقت ضعفي',
        localFilePath: '/tmp/mock/5.mp3',
        fileSizeBytes: 4900000,
        downloadedAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 4, seconds: 48),
      ),
      DownloadedHymn(
        id: 'd6',
        title: 'كل يوم تحت صليبك',
        singer: 'كورال أم النور',
        album: 'تحت الصليب',
        localFilePath: '/tmp/mock/6.mp3',
        fileSizeBytes: 3600000,
        downloadedAt: DateTime.now().subtract(const Duration(days: 2)),
        duration: const Duration(minutes: 3, seconds: 30),
      ),
    ];
    for (final d in downloads) {
      await offlineStorageService.saveDownloadedHymn(d);
    }
  }

  final audioHandler = await AudioService.init(
    builder: () => TarneemnaAudioHandler(
      offlineStorageService: offlineStorageService,
      personalLibraryService: personalLibraryService,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.increase.tarneemna.audio',
      androidNotificationChannelName: 'تشغيل الترانيم',
    ),
  );
  Player.init(audioHandler);

  // Set playing item for the full player
  audioHandler.mediaItem.add(
    const MediaItem(
      id: 'd1',
      title: 'مشيئتك صالحة',
      artist: 'زياد شحاتة',
      album: 'مشيئتك',
      duration: Duration(minutes: 4, seconds: 35),
      artUri: null,
    ),
  );
  audioHandler.playbackState.add(
    PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: AudioProcessingState.ready,
      playing: true,
      updatePosition: const Duration(minutes: 1, seconds: 42),
      bufferedPosition: const Duration(minutes: 3, seconds: 15),
      speed: 1.0,
      queueIndex: 0,
    ),
  );

  // Register HomeController early and populate search
  final hc = Get.put(HomeController());
  hc.songText.text = 'يسوع';
  hc.traneem.assignAll([
    Tarnemma(title: 'يسوع أنت ترنيمتي', duration: '4:20', author: 'كورال قلب داود', id: 's1', thumbnail: ''),
    Tarnemma(title: 'يسوع يرعاني فلا يعوزني شيء', duration: '5:15', author: 'ماهر فايز', id: 's2', thumbnail: ''),
    Tarnemma(title: 'يسوع يدخل بيتنا', duration: '3:45', author: 'كورال أم النور', id: 's3', thumbnail: ''),
    Tarnemma(title: 'يسوع رفيقي في كل خطوة', duration: '4:10', author: 'زياد شحاتة', id: 's4', thumbnail: ''),
    Tarnemma(title: 'يسوع المسيح هو هو أمساً واليوم', duration: '6:00', author: 'كورال تي أوجي', id: 's5', thumbnail: ''),
  ]);

  runApp(
    ProviderScope(
      overrides: [
        localHymnCacheProvider.overrideWithValue(localHymnCache),
        offlineStorageServiceProvider.overrideWithValue(offlineStorageService),
        personalLibraryServiceProvider.overrideWithValue(personalLibraryService),
        settingsServiceProvider.overrideWithValue(settingsService),
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const ScreenshotApp(),
    ),
  );
}

class ScreenshotApp extends ConsumerStatefulWidget {
  const ScreenshotApp({super.key});

  @override
  ConsumerState<ScreenshotApp> createState() => _ScreenshotAppState();
}

class _ScreenshotAppState extends ConsumerState<ScreenshotApp> {
  int _currentScreen = 0;

  @override
  void initState() {
    super.initState();
    _startCycle();
  }

  Future<void> _startCycle() async {
    // Give initial frame time to paint
    await Future.delayed(const Duration(seconds: 4));

    // Ensure search text stays populated
    try {
      final hc = Get.find<HomeController>();
      hc.songText.text = 'يسوع';
    } catch (_) {}

    debugPrint('=== CAPTURE 01-search ===');
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) setState(() => _currentScreen = 1);
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('=== CAPTURE 02-player ===');
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) setState(() => _currentScreen = 2);
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('=== CAPTURE 03-downloads ===');
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) setState(() => _currentScreen = 3);
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('=== CAPTURE 04-playlists ===');
    await Future.delayed(const Duration(seconds: 4));

    debugPrint('=== ALL CAPTURES COMPLETE ===');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppDetails.kAppName,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      debugShowCheckedModeBanner: false,
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: ThemeMode.light,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentScreen) {
      case 0:
        return const HomeScreen();
      case 1:
        return const FullPlayerView();
      case 2:
        return const OfflineDownloadsScreen();
      case 3:
        return const PlaylistsScreen();
      default:
        return const HomeScreen();
    }
  }
}
