import 'package:tarneemna/features/hymns/domain/entities/hymn.dart';

class Playlist {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Hymn> hymns;

  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    this.hymns = const [],
  });

  Playlist copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<Hymn>? hymns,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      hymns: hymns ?? this.hymns,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'hymns': hymns.map((h) => h.toMap()).toList(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      hymns: (map['hymns'] as List<dynamic>? ?? [])
          .map((item) => Hymn.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}
