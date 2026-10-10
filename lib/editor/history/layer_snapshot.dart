import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../canvas/layer.dart';
import '../canvas/pixel_rectangle.dart';

class LayerSnapshot {
  const LayerSnapshot({required this.area, required this.rgba});

  factory LayerSnapshot.capture({
    required Layer layer,
    required PixelRectangle area,
  }) {
    final clipped = area.intersection(layer.bounds);
    final rgba = Uint8List(clipped.width * clipped.height * 4);
    for (var row = 0; row < clipped.height; row++) {
      final layerOffset =
          ((clipped.top + row) * layer.width + clipped.left) * 4;
      rgba.setRange(
        row * clipped.width * 4,
        (row + 1) * clipped.width * 4,
        layer.rgba,
        layerOffset,
      );
    }
    return LayerSnapshot(area: clipped, rgba: rgba);
  }

  final PixelRectangle area;
  final Uint8List rgba;

  void restore(Layer layer) {
    for (var row = 0; row < area.height; row++) {
      final layerOffset = ((area.top + row) * layer.width + area.left) * 4;
      layer.rgba.setRange(
        layerOffset,
        layerOffset + area.width * 4,
        rgba,
        row * area.width * 4,
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is LayerSnapshot &&
      other.area == area &&
      const ListEquality<int>().equals(other.rgba, rgba);

  @override
  int get hashCode => Object.hash(area, const ListEquality<int>().hash(rgba));

  @override
  String toString() => 'LayerSnapshot($area)';
}
