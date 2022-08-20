import 'package:url_launcher/url_launcher.dart';

/// Lanuch URL in browser
Future<void> openUrl(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

//Lanuch URL in WebView
Future<void> openUrlWebView(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
  } else {
    throw 'Could not launch $url';
  }
}
