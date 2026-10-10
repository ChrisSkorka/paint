import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'pixel_color.dart';
import 'pixel_point.dart';
import 'pixel_rectangle.dart';

class Layer {
  const Layer({required this.width, required this.height, required this.rgba});

  factory Layer.filled({
    required int width,
    required int height,
    required PixelColor color,
  }) {
    final layer = Layer(
      width: width,
      height: height,
      rgba: Uint8List(width * height * 4),
    );
    layer.fillRectangle(rectangle: layer.bounds, color: color);
    return layer;
  }

  factory Layer.copyOf(Layer layer) {
    return Layer(
      width: layer.width,
      height: layer.height,
      rgba: Uint8List.fromList(layer.rgba),
    );
  }

  factory Layer.thumbnail({required Layer layer, required int maximumSize}) {
    final scale = min(1.0, maximumSize / max(layer.width, layer.height));
    final thumbnail = Layer.filled(
      width: max(1, (layer.width * scale).round()),
      height: max(1, (layer.height * scale).round()),
      color: PixelColor.transparent,
    );
    for (var y = 0; y < thumbnail.height; y++) {
      for (var x = 0; x < thumbnail.width; x++) {
        final source = PixelPoint(
          x: (x * 2 + 1) * layer.width ~/ (thumbnail.width * 2),
          y: (y * 2 + 1) * layer.height ~/ (thumbnail.height * 2),
        );
        thumbnail.setPixel(
          point: PixelPoint(x: x, y: y),
          color: layer.getPixel(source),
        );
      }
    }
    return thumbnail;
  }

  factory Layer.cropped({required Layer layer, required PixelRectangle area}) {
    final cropped = Layer.filled(
      width: area.width,
      height: area.height,
      color: PixelColor.transparent,
    );
    cropped.paste(
      source: layer,
      at: PixelPoint(x: -area.left, y: -area.top),
    );
    return cropped;
  }

  factory Layer.rotated({required Layer layer, required bool clockwise}) {
    final rotated = Layer.filled(
      width: layer.height,
      height: layer.width,
      color: PixelColor.transparent,
    );
    for (var y = 0; y < layer.height; y++) {
      for (var x = 0; x < layer.width; x++) {
        rotated.setPixel(
          point: clockwise
              ? PixelPoint(x: layer.height - 1 - y, y: x)
              : PixelPoint(x: y, y: layer.width - 1 - x),
          color: layer.getPixel(PixelPoint(x: x, y: y)),
        );
      }
    }
    return rotated;
  }

  factory Layer.mirrored({required Layer layer, required bool horizontally}) {
    final mirrored = Layer.filled(
      width: layer.width,
      height: layer.height,
      color: PixelColor.transparent,
    );
    for (var y = 0; y < layer.height; y++) {
      for (var x = 0; x < layer.width; x++) {
        mirrored.setPixel(
          point: horizontally
              ? PixelPoint(x: layer.width - 1 - x, y: y)
              : PixelPoint(x: x, y: layer.height - 1 - y),
          color: layer.getPixel(PixelPoint(x: x, y: y)),
        );
      }
    }
    return mirrored;
  }

  final int width;
  final int height;
  final Uint8List rgba;

  PixelRectangle get bounds =>
      PixelRectangle(left: 0, top: 0, width: width, height: height);

  bool contains(PixelPoint point) => bounds.contains(point);

  PixelColor getPixel(PixelPoint point) {
    final offset = _offset(x: point.x, y: point.y);
    return PixelColor.fromChannels(
      red: rgba[offset],
      green: rgba[offset + 1],
      blue: rgba[offset + 2],
      alpha: rgba[offset + 3],
    );
  }

  void setPixel({required PixelPoint point, required PixelColor color}) {
    if (!contains(point)) return;
    _write(
      offset: _offset(x: point.x, y: point.y),
      color: color,
    );
  }

  void fillRectangle({
    required PixelRectangle rectangle,
    required PixelColor color,
  }) {
    final clipped = rectangle.intersection(bounds);
    for (var y = clipped.top; y < clipped.bottom; y++) {
      for (var x = clipped.left; x < clipped.right; x++) {
        _write(
          offset: _offset(x: x, y: y),
          color: color,
        );
      }
    }
  }

  void paste({required Layer source, required PixelPoint at}) {
    final overlap = PixelRectangle(
      left: at.x,
      top: at.y,
      width: source.width,
      height: source.height,
    ).intersection(bounds);
    for (var y = overlap.top; y < overlap.bottom; y++) {
      for (var x = overlap.left; x < overlap.right; x++) {
        _write(
          offset: _offset(x: x, y: y),
          color: source.getPixel(PixelPoint(x: x - at.x, y: y - at.y)),
        );
      }
    }
  }

  int _offset({required int x, required int y}) => (y * width + x) * 4;

  void _write({required int offset, required PixelColor color}) {
    rgba[offset] = color.red;
    rgba[offset + 1] = color.green;
    rgba[offset + 2] = color.blue;
    rgba[offset + 3] = color.alpha;
  }

  @override
  bool operator ==(Object other) =>
      other is Layer &&
      other.width == width &&
      other.height == height &&
      const ListEquality<int>().equals(other.rgba, rgba);

  @override
  int get hashCode =>
      Object.hash(width, height, const ListEquality<int>().hash(rgba));

  @override
  String toString() => 'Layer($width, $height)';
}
