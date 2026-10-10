import 'package:collection/collection.dart';

import '../canvas/document.dart';
import '../canvas/document_layer.dart';

class DocumentStructure {
  const DocumentStructure({
    required this.layers,
    required this.activeLayerIndex,
    required this.frameHolds,
    required this.fps,
    required this.activeFrameIndex,
  });

  factory DocumentStructure.capture({required Document document}) {
    return DocumentStructure(
      layers: List.unmodifiable(document.layers),
      activeLayerIndex: document.activeLayerIndex,
      frameHolds: List.unmodifiable(document.frameHolds),
      fps: document.fps,
      activeFrameIndex: document.activeFrameIndex,
    );
  }

  final List<DocumentLayer> layers;
  final int activeLayerIndex;
  final List<int> frameHolds;
  final int fps;
  final int activeFrameIndex;

  void restore(Document document) {
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
      const ListEquality<DocumentLayer>().equals(other.layers, layers) &&
      other.activeLayerIndex == activeLayerIndex &&
      const ListEquality<int>().equals(other.frameHolds, frameHolds) &&
      other.fps == fps &&
      other.activeFrameIndex == activeFrameIndex;

  @override
  int get hashCode => Object.hash(
    const ListEquality<DocumentLayer>().hash(layers),
    activeLayerIndex,
    const ListEquality<int>().hash(frameHolds),
    fps,
    activeFrameIndex,
  );

  @override
  String toString() =>
      'DocumentStructure(layers: ${layers.length}, active: $activeLayerIndex, frames: ${frameHolds.length}, frame: $activeFrameIndex, fps: $fps)';
}
