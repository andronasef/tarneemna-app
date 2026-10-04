enum HymnSource {
  taranimar,
  youtube,
}

class Hymn {
  final String id;
  final String title;
  final String? singer;
  final String? singerId;
  final String? album;
  final String? albumId;
  final String? audioUrl;
  final String? lyrics;
  final String? artworkUrl;
  final Duration? duration;
  final HymnSource source;
  final String? chordsUrl;
  final String? notesUrl;
  final Map<String, dynamic> metadata;

  const Hymn({
    required this.id,
    required this.title,
    this.singer,
    this.singerId,
    this.album,
    this.albumId,
    this.audioUrl,
    this.lyrics,
    this.artworkUrl,
    this.duration,
    required this.source,
    this.chordsUrl,
    this.notesUrl,
    this.metadata = const {},
  });

  Hymn copyWith({
    String? id,
    String? title,
    String? singer,
    String? singerId,
    String? album,
    String? albumId,
    String? audioUrl,
    String? lyrics,
    String? artworkUrl,
    Duration? duration,
    HymnSource? source,
    String? chordsUrl,
    String? notesUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Hymn(
      id: id ?? this.id,
      title: title ?? this.title,
      singer: singer ?? this.singer,
      singerId: singerId ?? this.singerId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      audioUrl: audioUrl ?? this.audioUrl,
      lyrics: lyrics ?? this.lyrics,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      source: source ?? this.source,
      chordsUrl: chordsUrl ?? this.chordsUrl,
      notesUrl: notesUrl ?? this.notesUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'singer': singer,
      'singerId': singerId,
      'album': album,
      'albumId': albumId,
      'audioUrl': audioUrl,
      'lyrics': lyrics,
      'artworkUrl': artworkUrl,
      'durationMs': duration?.inMilliseconds,
      'source': source.name,
      'chordsUrl': chordsUrl,
      'notesUrl': notesUrl,
      'metadata': metadata,
    };
  }

  factory Hymn.fromMap(Map<String, dynamic> map) {
    return Hymn(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      singer: map['singer'] as String?,
      singerId: map['singerId'] as String?,
      album: map['album'] as String?,
      albumId: map['albumId'] as String?,
      audioUrl: map['audioUrl'] as String?,
      lyrics: map['lyrics'] as String?,
      artworkUrl: map['artworkUrl'] as String?,
      duration: map['durationMs'] != null
          ? Duration(milliseconds: map['durationMs'] as int)
          : null,
      source: HymnSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => HymnSource.taranimar,
      ),
      chordsUrl: map['chordsUrl'] as String?,
      notesUrl: map['notesUrl'] as String?,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : const {},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hymn &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          source == other.source;

  @override
  int get hashCode => id.hashCode ^ source.hashCode;

  @override
  String toString() {
    return 'Hymn(id: $id, title: $title, singer: $singer, source: ${source.name})';
  }
}
