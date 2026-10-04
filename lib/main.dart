import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/audio/data/sources/tarneemna_audio_handler.dart';
import 'features/audio/presentation/providers/audio_providers.dart';
import 'features/downloads/data/sources/offline_storage_service.dart';
import 'features/downloads/presentation/providers/download_providers.dart';
import 'features/hymns/data/sources/local_hymn_cache.dart';
import 'features/library/data/sources/personal_library_service.dart';
import 'features/library/presentation/providers/library_providers.dart';
import 'features/search/data/sources/search_history_service.dart';
import 'features/search/presentation/providers/search_providers.dart';
import 'firebase_options.dart';
import 'player.dart';
import 'tarnemma.dart';

Future<void> main(List<String> args) async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Wait for the native splash screen to finish (2 seconds)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(const Duration(seconds: 2), () => FlutterNativeSplash.remove());

  // Initialize Hive
  await Hive.initFlutter();
  final localHymnCache = LocalHymnCache();
  await localHymnCache.init();

  final offlineStorageService = OfflineStorageService();
  await offlineStorageService.init();

  final personalLibraryService = PersonalLibraryService();
  await personalLibraryService.init();

  final searchHistoryService = SearchHistoryService();
  await searchHistoryService.init();

  // Initialize Audio Service for background playback
  final audioHandler = await AudioService.init(
    builder: () => TarneemnaAudioHandler(
      offlineStorageService: offlineStorageService,
      personalLibraryService: personalLibraryService,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.increase.tarneemna.audio',
      androidNotificationChannelName: 'تشغيل الترانيم',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  Player.init(audioHandler);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterDownloader.initialize(debug: kDebugMode);

  // Initialize YouTube solver
  await initYoutubeExplode();

  runApp(
    ProviderScope(
      overrides: [
        localHymnCacheProvider.overrideWithValue(localHymnCache),
        offlineStorageServiceProvider.overrideWithValue(offlineStorageService),
        personalLibraryServiceProvider.overrideWithValue(personalLibraryService),
        searchHistoryServiceProvider.overrideWithValue(searchHistoryService),
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const App(),
    ),
  );
}
