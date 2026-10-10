import 'dart:typed_data';

import 'package:image/image.dart' as image;

import '../canvas/layer.dart';

abstract final class ImageCodec {
  static Uint8List encodePng({required Layer layer}) {
    return image.encodePng(
      image.Image.fromBytes(
        width: layer.width,
        height: layer.height,
        bytes: Uint8List.fromList(layer.rgba).buffer,
        numChannels: 4,
      ),
    );
  }

  static Layer? decode({required Uint8List bytes}) {
    final decoded = _tryDecode(bytes: bytes);
    if (decoded == null) return null;
    final rgba = decoded
        .convert(format: image.Format.uint8, numChannels: 4)
        .getBytes(order: image.ChannelOrder.rgba);
    return Layer(width: decoded.width, height: decoded.height, rgba: rgba);
  }

  static image.Image? _tryDecode({required Uint8List bytes}) {
    try {
      return image.decodeImage(bytes);
    } on RangeError {
      return null;
    }
  }
}
