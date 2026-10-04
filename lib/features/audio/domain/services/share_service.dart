import 'package:share_plus/share_plus.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

class ShareService {
  static const String appPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.increase.tarneemna';

  static String formatTimestamp(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static Future<void> shareHymnWithTimestamp(Hymn hymn, Duration position) async {
    final singer = hymn.singer != null ? ' - ${hymn.singer}' : '';
    final timeStr = formatTimestamp(position);
    final text = 'استمع لترنيمة «${hymn.title}»$singer عند الدقيقة $timeStr عبر تطبيق ترانيمنا:\n$appPlayStoreUrl';
    await Share.share(text);
  }

  static Future<void> shareHymn(Hymn hymn) async {
    final singer = hymn.singer != null ? ' - ${hymn.singer}' : '';
    final text = 'استمع لترنيمة «${hymn.title}»$singer عبر تطبيق ترانيمنا:\n$appPlayStoreUrl';
    await Share.share(text);
  }
}
