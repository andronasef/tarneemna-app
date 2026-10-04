import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

class DownloadedHymn {
  final String id;
  final String title;
  final String? singer;
  final String? album;
  final String? artworkUrl;
  final String localFilePath;
  final int fileSizeBytes;
  final DateTime downloadedAt;
  final String? lyrics;
  final HymnSource source;
  final Duration? duration;

  const DownloadedHymn({
    required this.id,
    required this.title,
    this.singer,
    this.album,
    this.artworkUrl,
    required this.localFilePath,
    required this.fileSizeBytes,
    required this.downloadedAt,
    this.lyrics,
    this.source = HymnSource.taranimar,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'singer': singer,
      'album': album,
      'artworkUrl': artworkUrl,
      'localFilePath': localFilePath,
      'fileSizeBytes': fileSizeBytes,
      'downloadedAt': downloadedAt.toIso8601String(),
      'lyrics': lyrics,
      'source': source.name,
      'durationMs': duration?.inMilliseconds,
    };
  }

  factory DownloadedHymn.fromMap(Map<dynamic, dynamic> map) {
    return DownloadedHymn(
      id: map['id'] as String,
      title: map['title'] as String,
      singer: map['singer'] as String?,
      album: map['album'] as String?,
      artworkUrl: map['artworkUrl'] as String?,
      localFilePath: map['localFilePath'] as String,
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt() ?? 0,
      downloadedAt: DateTime.tryParse(map['downloadedAt'] as String? ?? '') ?? DateTime.now(),
      lyrics: map['lyrics'] as String?,
      source: (map['source'] == HymnSource.youtube.name)
          ? HymnSource.youtube
          : HymnSource.taranimar,
      duration: map['durationMs'] != null
          ? Duration(milliseconds: map['durationMs'] as int)
          : null,
    );
  }

  Hymn toHymn() {
    return Hymn(
      id: id,
      title: title,
      singer: singer,
      album: album,
      artworkUrl: artworkUrl,
      duration: duration,
      audioUrl: localFilePath,
      lyrics: lyrics,
      source: source,
    );
  }
}
