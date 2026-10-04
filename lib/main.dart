import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'tarnemma.dart';

Future<void> main(List<String> args) async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Wait for the native splash screen to finish (2 seconds)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(2.seconds, () => FlutterNativeSplash.remove());
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterDownloader.initialize(debug: kDebugMode);

  // Initialize YouTube solver
  await initYoutubeExplode();

  runApp(const App());
}
