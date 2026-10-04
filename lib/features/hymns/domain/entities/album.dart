class Album {
  final String id;
  final String title;
  final String? imageUrl;
  final String? singerName;
  final int? trackCount;

  const Album({
    required this.id,
    required this.title,
    this.imageUrl,
    this.singerName,
    this.trackCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'singerName': singerName,
      'trackCount': trackCount,
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      singerName: map['singerName'] as String?,
      trackCount: map['trackCount'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Album(id: $id, title: $title)';
}
