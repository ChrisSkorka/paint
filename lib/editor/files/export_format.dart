import 'dart:typed_data';

import '../canvas/document.dart';
import '../canvas/pixel_color.dart';
import 'gif_codec.dart';
import 'image_codec.dart';
import 'ora_codec.dart';

enum ExportFormat {
  png(label: 'PNG', extension: 'png', mimeType: 'image/png'),
  jpg(label: 'JPG', extension: 'jpg', mimeType: 'image/jpeg'),
  gif(label: 'GIF', extension: 'gif', mimeType: GifCodec.mimeType),
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
      layer: document.flatten(
        background: PixelColor.transparent,
        frame: document.activeFrameIndex,
      ),
    ),
    jpg => ImageCodec.encodeJpg(
      layer: document.flatten(
        background: PixelColor.white,
        frame: document.activeFrameIndex,
      ),
    ),
    gif => GifCodec.encode(document: document),
    ora => OraCodec.encode(document: document),
  };
}
