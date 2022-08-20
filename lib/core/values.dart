class AppDetails {
  static const String kAppName = "ترانيمنا";
  static const String kAppPackageName = "com.increase.tarneemna";
  static const String kAppShortname = "tarneemna";
}

class AppUrls {
  static const String whatsapp = "";
  static const String rate =
      "market://details?id=${AppDetails.kAppPackageName}";
  static const String share =
      "https://play.google.com/store/apps/details?id=${AppDetails.kAppPackageName}";
  static const String moreapps = "market://search?q=pub:Increase Apps";
  static const String support =
      "https://feedback.userreport.com/f1e9eb42-d984-4cec-aa24-260ccc1487bc/";
  static const String privacy =
      "https://realincrease.github.io/apps-privacy-policy/${AppDetails.kAppShortname}";
}

// ignore: avoid_classes_with_only_static_members
class R {
  static const appUrls = AppUrls;
  static const appDetails = AppDetails;
}
