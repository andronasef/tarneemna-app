import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarneemna/features/youtube/data/sources/youtube_audio_resolver.dart';

void main() {
  test('YouTube is disabled on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(YouTubeAudioResolver.enabled, isFalse);
    expect(await YouTubeAudioResolver.searchVideos('ترنيمة'), isEmpty);
    expect(await YouTubeAudioResolver.getAudioUrl('dQw4w9WgXcQ'), isNull);
  });

  test('YouTube stays enabled on Android', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(YouTubeAudioResolver.enabled, isTrue);
  });
}
