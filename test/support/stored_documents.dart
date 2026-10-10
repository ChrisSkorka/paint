import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/files/stored_document.dart';

StoredDocument storedDocument({
  required String id,
  String name = 'Cat',
  int minute = 0,
}) => StoredDocument(
  id: id,
  name: name,
  modified: DateTime(2026, 10, 10, 12, minute),
  thumbnail: Layer.filled(width: 2, height: 1, color: PixelColor.white),
);
