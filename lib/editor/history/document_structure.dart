import 'package:collection/collection.dart';

import '../canvas/document.dart';
import '../canvas/document_layer.dart';

class DocumentStructure {
  const DocumentStructure({
    required this.width,
    required this.height,
    required this.layers,
    required this.activeLayerIndex,
    required this.frameHolds,
    required this.fps,
    required this.activeFrameIndex,
  });

  factory DocumentStructure.capture({required Document document}) {
    return DocumentStructure(
      width: document.width,
      height: document.height,
      layers: List.unmodifiable(document.layers),
      activeLayerIndex: document.activeLayerIndex,
      frameHolds: List.unmodifiable(document.frameHolds),
      fps: document.fps,
      activeFrameIndex: document.activeFrameIndex,
    );
  }

  final int width;
  final int height;
  final List<DocumentLayer> layers;
  final int activeLayerIndex;
  final List<int> frameHolds;
  final int fps;
  final int activeFrameIndex;

  void restore(Document document) {
    document.width = width;
    document.height = height;
    document.layers
      ..clear()
      ..addAll(layers);
    document.activeLayerIndex = activeLayerIndex;
    document.frameHolds = frameHolds;
    document.fps = fps;
    document.activeFrameIndex = activeFrameIndex;
  }

  @override
  bool operator ==(Object other) =>
      other is DocumentStructure &&
      other.width == width &&
      other.height == height &&
      const ListEquality<DocumentLayer>().equals(other.layers, layers) &&
      other.activeLayerIndex == activeLayerIndex &&
      const ListEquality<int>().equals(other.frameHolds, frameHolds) &&
      other.fps == fps &&
      other.activeFrameIndex == activeFrameIndex;

  @override
  int get hashCode => Object.hash(
    width,
    height,
    const ListEquality<DocumentLayer>().hash(layers),
    activeLayerIndex,
    const ListEquality<int>().hash(frameHolds),
    fps,
    activeFrameIndex,
  );

  @override
  String toString() =>
      'DocumentStructure($width, $height, layers: ${layers.length}, active: $activeLayerIndex, frames: ${frameHolds.length}, frame: $activeFrameIndex, fps: $fps)';
}
