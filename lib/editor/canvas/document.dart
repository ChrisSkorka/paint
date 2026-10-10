import 'package:collection/collection.dart';

import 'document_layer.dart';
import 'layer.dart';
import 'pixel_color.dart';

class Document {
  Document({
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
      layers: [
        DocumentLayer(
          name: 'Background',
          pixels: Layer.filled(width: width, height: height, color: background),
        ),
      ],
      activeLayerIndex: 0,
    );
  }

  factory Document.fromImage({required Layer image}) {
    return Document(
      width: image.width,
      height: image.height,
      layers: [DocumentLayer(name: 'Background', pixels: image)],
      activeLayerIndex: 0,
    );
  }

  static const minimumSize = 1;
  static const maximumSize = 4096;

  final int width;
  final int height;
  final List<DocumentLayer> layers;
  int activeLayerIndex;

  Layer get activeLayer => layers[activeLayerIndex].pixels;

  @override
  bool operator ==(Object other) =>
      other is Document &&
      other.width == width &&
      other.height == height &&
      other.activeLayerIndex == activeLayerIndex &&
      const ListEquality<DocumentLayer>().equals(other.layers, layers);

  @override
  int get hashCode => Object.hash(
    width,
    height,
    activeLayerIndex,
    const ListEquality<DocumentLayer>().hash(layers),
  );

  @override
  String toString() =>
      'Document($width, $height, layers: ${layers.length}, active: $activeLayerIndex)';
}
