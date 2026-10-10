import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

import '../canvas/document.dart';
import '../canvas/document_layer.dart';
import '../canvas/frame_timing.dart';
import '../canvas/layer.dart';
import '../canvas/layer_timeframe.dart';
import '../canvas/pixel_color.dart';
import 'document_format_exception.dart';
import 'image_codec.dart';

abstract final class GifCodec {
  static const mimeType = 'image/gif';
  static const paletteSize = 256;
  static const alphaThreshold = 128;
  static const _transparentIndex = 0;
  static int holdCentiseconds({required int fps}) =>
      max(1, (FrameTiming.centisecondsPerSecond / fps).round());

  static Uint8List encode({required Document document}) {
    final encoder = image.GifEncoder(dither: image.DitherKernel.none);
    final hold = holdCentiseconds(fps: document.fps);
    for (final frame in document.shownFrames) {
      encoder.addFrame(
        _toPaletteImage(
          layer: document.flatten(
            background: PixelColor.transparent,
            frame: frame,
          ),
        ),
        duration: hold * document.frameHolds[frame],
      );
    }
    return encoder.finish()!;
  }

  static Document decode({required String name, required Uint8List bytes}) {
    final decoded = _tryDecode(bytes: bytes);
    if (decoded == null) throw DocumentFormatException.unsupported();
    DocumentFormatException.checkSize(
      width: decoded.width,
      height: decoded.height,
    );
    final timing = FrameTiming.fromDurations(
      centiseconds: [
        for (final frame in decoded.frames)
          frame.frameDuration ~/ FrameTiming.millisecondsPerCentisecond,
      ],
    );
    return Document(
      name: name,
      width: decoded.width,
      height: decoded.height,
      layers: [
        DocumentLayer(
          name: 'Background',
          images: [
            for (final frame in decoded.frames)
              ImageCodec.toLayer(decoded: frame),
          ],
          timeframe: LayerTimeframe.perFrame,
        ),
      ],
      activeLayerIndex: 0,
      frameHolds: timing.holds,
      fps: timing.fps,
    );
  }

  static image.Image? _tryDecode({required Uint8List bytes}) {
    try {
      return image.GifDecoder().decode(bytes);
    } on RangeError {
      return null;
    }
  }

  static image.Image _toPaletteImage({required Layer layer}) {
    final rgba = layer.rgba;
    final colors = <int, int>{};
    for (var offset = 0; offset < rgba.length; offset += 4) {
      if (rgba[offset + 3] < alphaThreshold) continue;
      colors.putIfAbsent(
        _rgb(rgba: rgba, offset: offset),
        () => colors.length + 1,
      );
    }
    final quantizer = colors.length < paletteSize
        ? null
        : image.OctreeQuantizer(
            ImageCodec.toImage(layer: layer),
            numberOfColors: paletteSize - 1,
          );
    final palette = image.PaletteUint8(paletteSize, 4);
    if (quantizer == null) {
      for (final color in colors.entries) {
        _setPaletteColor(palette: palette, index: color.value, rgb: color.key);
      }
    } else {
      for (var index = 0; index < quantizer.palette.numColors; index++) {
        palette.setRgba(
          index + 1,
          quantizer.palette.getRed(index),
          quantizer.palette.getGreen(index),
          quantizer.palette.getBlue(index),
          255,
        );
      }
    }
    palette.setRgba(_transparentIndex, 0, 0, 0, 0);
    final indexed = image.Image(
      width: layer.width,
      height: layer.height,
      numChannels: 1,
      palette: palette,
    );
    for (final pixel in indexed) {
      final offset = (pixel.y * layer.width + pixel.x) * 4;
      pixel.index = switch (rgba[offset + 3] < alphaThreshold) {
        true => _transparentIndex,
        false when quantizer == null =>
          colors[_rgb(rgba: rgba, offset: offset)]!,
        false =>
          quantizer!.getColorIndexRgb(
                rgba[offset],
                rgba[offset + 1],
                rgba[offset + 2],
              ) +
              1,
      };
    }
    return indexed;
  }

  static int _rgb({required Uint8List rgba, required int offset}) =>
      rgba[offset] << 16 | rgba[offset + 1] << 8 | rgba[offset + 2];

  static void _setPaletteColor({
    required image.PaletteUint8 palette,
    required int index,
    required int rgb,
  }) => palette.setRgba(index, rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF, 255);
}
