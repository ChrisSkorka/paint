import 'package:collection/collection.dart';

import 'layer.dart';
import 'pixel_color.dart';

class Document {
  const Document({
    required this.width,
    required this.height,
    required this.layers,
    required this.activeLayerIndex,
  });

  factory Document.blank({
    required int width,
    required int height,
    PixelColor background = PixelColor.transparent,
  }) {
    return Document(
      width: width,
      height: height,
      layers: [Layer.filled(width: width, height: height, color: background)],
      activeLayerIndex: 0,
    );
  }

  static const minimumSize = 1;
  static const maximumSize = 4096;

  final int width;
  final int height;
  final List<Layer> layers;
  final int activeLayerIndex;

  Layer get activeLayer => layers[activeLayerIndex];

  @override
  bool operator ==(Object other) =>
      other is Document &&
      other.width == width &&
      other.height == height &&
      other.activeLayerIndex == activeLayerIndex &&
      const ListEquality<Layer>().equals(other.layers, layers);

  @override
  int get hashCode => Object.hash(
    width,
    height,
    activeLayerIndex,
    const ListEquality<Layer>().hash(layers),
  );

  @override
  String toString() =>
      'Document($width, $height, layers: ${layers.length}, active: $activeLayerIndex)';
}
