import 'package:flutter/foundation.dart';

class AppDetails {
  static const String kAppName = "ترانيمنا";
  static const String kAppPackageName = "com.increase.tarneemna";
  static const String kAppShortname = "tarneemna";
}

/// YouTube search/playback is Android-only: App Store guideline 5.2.3 bars
/// streaming or downloading YouTube audio inside an iOS app.
bool get kYouTubeEnabled => defaultTargetPlatform != TargetPlatform.iOS;

class AppUrls {
  static const String whatsapp = "";
  static const String rate =
      "market://details?id=${AppDetails.kAppPackageName}";
  static const String share =
      "https://play.google.com/store/apps/details?id=${AppDetails.kAppPackageName}";
  static const String moreapps = "market://search?q=pub:Increasing%20Labs";
  static const String support = "https://forms.gle/DGKYCQwtfdtGcnTH6";
  static const String privacy =
      "https://increasinglabs.github.io/apps-privacy-policy/${AppDetails.kAppShortname}";
}

// ignore: avoid_classes_with_only_static_members
