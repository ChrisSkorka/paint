import 'dart:typed_data';

import '../canvas/document.dart';
import '../canvas/pixel_color.dart';
import 'image_codec.dart';
import 'ora_codec.dart';

enum ExportFormat {
  png(label: 'PNG', extension: 'png', mimeType: 'image/png'),
  jpg(label: 'JPG', extension: 'jpg', mimeType: 'image/jpeg'),
  ora(label: 'ORA', extension: 'ora', mimeType: OraCodec.mimeType);

  const ExportFormat({
    required this.label,
    required this.extension,
    required this.mimeType,
  });

  final String label;
  final String extension;
  final String mimeType;

  String fileName({required Document document}) =>
      '${document.name}.$extension';

  Uint8List encode({required Document document}) => switch (this) {
    png => ImageCodec.encodePng(
      layer: document.flatten(background: PixelColor.transparent),
    ),
    jpg => ImageCodec.encodeJpg(
      layer: document.flatten(background: PixelColor.white),
    ),
    ora => OraCodec.encode(document: document),
  };
}
