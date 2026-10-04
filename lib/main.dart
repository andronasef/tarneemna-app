import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/hymns/data/sources/local_hymn_cache.dart';
import 'firebase_options.dart';
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
      ],
      child: const App(),
    ),
  );
}
