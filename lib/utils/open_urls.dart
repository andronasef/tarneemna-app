import 'package:url_launcher/url_launcher.dart';

/// Launch URL in browser
Future<void> openUrl(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

