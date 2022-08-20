import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'firebase_options.dart';

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

  runApp(const App());
}


// [x]: Stop and play song
// [x]: Check Internet connection => https://pub.dev/packages/internet_connection_checker
// [x]: Add Firebase Analytics
// [x]: صغر خط الترانيم
// [x]: Make App Color Better
// [x]: Audio Player UI
// [x]: Elvation Mini Player
// [x]: Add App Share
// [x]: Complete UI (Settings & Info)

//* For Future
// TODO: Add Animations (Fade - List Animations)
// TODO: Radio Mode
// TODO: Recently Played From Other Users

