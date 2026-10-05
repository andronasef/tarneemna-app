import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app. Returns false if nothing could handle it.
/// [fallback] is tried when [url] fails (e.g. `market://` without the Play Store).
Future<bool> openUrl(String url, {String? fallback}) async {
  for (final candidate in [url, if (fallback != null) fallback]) {
    final uri = Uri.tryParse(candidate);
    if (uri == null) continue;
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {}
  }
  return false;
}
