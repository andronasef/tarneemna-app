class Singer {
  final String id;
  final String name;
  final String? imageUrl;
  final int? songCount;

  const Singer({
    required this.id,
    required this.name,
    this.imageUrl,
    this.songCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'songCount': songCount,
    };
  }

  factory Singer.fromMap(Map<String, dynamic> map) {
    return Singer(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      songCount: map['songCount'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Singer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Singer(id: $id, name: $name)';
}
