import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'document_layer.dart';
import 'layer.dart';
import 'pixel_color.dart';

class Document {
  Document({
    this.name = untitledName,
    required this.width,
    required this.height,
    required this.layers,
    required this.activeLayerIndex,
    this.storeId,
  });

  factory Document.blank({
    String name = untitledName,
    required int width,
    required int height,
    PixelColor background = PixelColor.transparent,
  }) {
    return Document(
      name: name,
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

  factory Document.fromImage({
    String name = untitledName,
    required Layer image,
  }) {
    return Document(
      name: name,
      width: image.width,
      height: image.height,
      layers: [DocumentLayer(name: 'Background', pixels: image)],
      activeLayerIndex: 0,
    );
  }

  static const untitledName = 'Untitled';
  static const minimumSize = 1;
  static const maximumSize = 4096;

  final String name;
  final int width;
  final int height;
  final List<DocumentLayer> layers;
  int activeLayerIndex;
  String? storeId;

  Layer get activeLayer => layers[activeLayerIndex].pixels;

  Layer flatten({required PixelColor background}) {
    final flattened = Layer.filled(
      width: width,
      height: height,
      color: background,
    );
    for (final layer in layers.where((layer) => layer.visible)) {
      _blend(
        target: flattened.rgba,
        source: layer.pixels.rgba,
        opacity: layer.opacity / DocumentLayer.maximumOpacity,
      );
    }
    return flattened;
  }

  static void _blend({
    required Uint8List target,
    required Uint8List source,
    required double opacity,
  }) {
    for (var offset = 0; offset < target.length; offset += 4) {
      final sourceAlpha = source[offset + 3] / 255 * opacity;
      if (sourceAlpha == 0) continue;
      final targetAlpha = target[offset + 3] / 255;
      final targetWeight = targetAlpha * (1 - sourceAlpha);
      final alpha = sourceAlpha + targetWeight;
      for (var channel = 0; channel < 3; channel++) {
        target[offset + channel] =
            ((source[offset + channel] * sourceAlpha +
                        target[offset + channel] * targetWeight) /
                    alpha)
                .round();
      }
      target[offset + 3] = (alpha * 255).round();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Document &&
      other.name == name &&
      other.width == width &&
      other.height == height &&
      other.activeLayerIndex == activeLayerIndex &&
      other.storeId == storeId &&
      const ListEquality<DocumentLayer>().equals(other.layers, layers);

  @override
  int get hashCode => Object.hash(
    name,
    width,
    height,
    activeLayerIndex,
    storeId,
    const ListEquality<DocumentLayer>().hash(layers),
  );

  @override
  String toString() =>
      'Document($name, $width, $height, layers: ${layers.length}, active: $activeLayerIndex)';
}
