import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_explode_webview/youtube_explode_webview.dart';

class YouTubeAudioResolver {
  static WebviewEJSSolver? _jsSolver;
  static YoutubeExplode? _yt;

  static YoutubeExplode get yt {
    _yt ??= YoutubeExplode(jsSolver: _jsSolver);
    return _yt!;
  }

  static Future<void> init() async {
    try {
      _jsSolver = await WebviewEJSSolver.init();
      _yt = YoutubeExplode(jsSolver: _jsSolver);
      if (kDebugMode) print('WebviewEJSSolver initialized successfully!');
    } catch (e) {
      if (kDebugMode) print('Failed to initialize WebviewEJSSolver: $e');
      _yt = YoutubeExplode();
    }
  }

  /// Resolves the stream using Innertube VISIONOS client.
  /// Yields playable URLs with no 403 or 1MB stream throttling.
  static Future<String?> resolveVisionOsAudio(String videoId) async {
    final client = HttpClient();
    try {
      final webPayload = jsonEncode({
        'context': {
          'client': {
            'clientName': 'WEB',
            'clientVersion': '2.20240105.01.00',
            'hl': 'en',
            'gl': 'US',
          }
        },
        'videoId': videoId,
      });

      final req1 = await client.postUrl(
        Uri.parse('https://www.youtube.com/youtubei/v1/player?prettyPrint=false'),
      );
      req1.headers.set('Content-Type', 'application/json');
      req1.headers.set('User-Agent', 'Mozilla/5.0');
      req1.write(webPayload);
      final resp1 = await req1.close();
      final body1 = await resp1.transform(utf8.decoder).join();
      final data1 = jsonDecode(body1) as Map<String, dynamic>;
      final visitorData = data1['responseContext']?['visitorData'] as String?;

      final visionPayload = jsonEncode({
        'context': {
          'client': {
            'clientName': 'VISIONOS',
            'clientVersion': '1.02',
            'deviceMake': 'Apple',
            'platform': 'MOBILE',
            'osName': 'visionOS',
            'osVersion': '26.5.23O471',
            'deviceModel': 'RealityDevice17,1',
            'hl': 'en',
            'timeZone': 'UTC',
            'utcOffsetMinutes': 0,
            if (visitorData != null) 'visitorData': visitorData,
          }
        },
        'videoId': videoId,
      });

      final req2 = await client.postUrl(
        Uri.parse(
          'https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false',
        ),
      );
      req2.headers.set('Content-Type', 'application/json');
      req2.headers.set(
        'User-Agent',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_7_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15',
      );
      req2.headers.set('X-Youtube-Client-Name', '101');
      req2.write(visionPayload);
      final resp2 = await req2.close();
      final body2 = await resp2.transform(utf8.decoder).join();
      final data2 = jsonDecode(body2) as Map<String, dynamic>;

      final streamingData = data2['streamingData'] as Map<String, dynamic>?;
      final formats =
          (streamingData?['adaptiveFormats'] as List<dynamic>?) ?? [];

      for (final f in formats) {
        if (f['itag'] == 140 && f['url'] != null) {
          return f['url'] as String;
        }
      }

      for (final f in formats) {
        final mime = (f['mimeType'] as String? ?? '');
        if (mime.contains('audio') && f['url'] != null) {
          return f['url'] as String;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error in resolveVisionOsAudio: $e');
    } finally {
      client.close();
    }
    return null;
  }

  /// Get playable audio stream URL (with fallback to youtube_explode)
  static Future<String?> getAudioUrl(String videoId) async {
    final vUrl = await resolveVisionOsAudio(videoId);
    if (vUrl != null && vUrl.isNotEmpty) {
      return vUrl;
    }

    try {
      StreamManifest manifest;
      try {
        manifest = await yt.videos.streamsClient.getManifest(
          videoId,
          ytClients: [YoutubeApiClient.androidSdkless],
          requireWatchPage: false,
        );
      } catch (e) {
        manifest = await yt.videos.streamsClient.getManifest(videoId);
      }
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      if (kDebugMode) print('YouTube explode error getting stream: $e');
      return null;
    }
  }

  /// Search YouTube and return Hymn domain entities
  static Future<List<Hymn>> searchVideos(String query) async {
    final List<Hymn> list = [];
    if (query.trim().isEmpty) return list;

    try {
      final searchList = await yt.search.search(query);
      for (final video in searchList) {
        try {
          final thumbnail = video.thumbnails.standardResUrl.isNotEmpty
              ? video.thumbnails.standardResUrl
              : video.thumbnails.highResUrl;

          list.add(
            Hymn(
              id: video.id.value,
              title: video.title,
              singer: video.author,
              artworkUrl: thumbnail.isNotEmpty ? thumbnail : null,
              duration: video.duration,
              source: HymnSource.youtube,
            ),
          );
        } catch (e) {
          if (kDebugMode) print('Error parsing video search result: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) print('YouTube search error: $e');
    }
    return list;
  }
}
