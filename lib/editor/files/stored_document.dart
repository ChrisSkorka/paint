import 'dart:convert';

import '../canvas/layer.dart';
import 'image_codec.dart';

class StoredDocument {
  const StoredDocument({
    required this.id,
    required this.name,
    required this.modified,
    required this.thumbnail,
  });

  factory StoredDocument.fromJson(Map<String, Object?> json) {
    return StoredDocument(
      id: json['id']! as String,
      name: json['name']! as String,
      modified: DateTime.fromMillisecondsSinceEpoch(json['modified']! as int),
      thumbnail: ImageCodec.decode(
        bytes: base64.decode(json['thumbnail']! as String),
      )!,
    );
  }

  final String id;
  final String name;
  final DateTime modified;
  final Layer thumbnail;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'modified': modified.millisecondsSinceEpoch,
    'thumbnail': base64.encode(ImageCodec.encodePng(layer: thumbnail)),
  };

  @override
  bool operator ==(Object other) =>
      other is StoredDocument &&
      other.id == id &&
      other.name == name &&
      other.modified == modified &&
      other.thumbnail == thumbnail;

  @override
  int get hashCode => Object.hash(id, name, modified, thumbnail);

  @override
  String toString() => 'StoredDocument($id, $name, $modified)';
}
