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
