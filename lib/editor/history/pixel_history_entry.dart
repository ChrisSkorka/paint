import 'dart:ui';

import '../canvas/document.dart';
import '../canvas/layer.dart';
import 'history_entry.dart';
import 'layer_snapshot.dart';

class PixelHistoryEntry implements HistoryEntry {
  const PixelHistoryEntry({
    required this.name,
    required this.layerIndex,
    required this.frameIndex,
    required this.before,
    required this.after,
    required this.thumbnail,
    required this.outline,
  });

  factory PixelHistoryEntry.recorded({
    required String name,
    required int layerIndex,
    required int frameIndex,
    required LayerSnapshot before,
    required LayerSnapshot after,
    required Layer thumbnail,
    required int canvasWidth,
    required int canvasHeight,
  }) {
    final area = after.area;
    return PixelHistoryEntry(
      name: name,
      layerIndex: layerIndex,
      frameIndex: frameIndex,
      before: before,
      after: after,
      thumbnail: thumbnail,
      outline: Rect.fromLTWH(
        area.left / canvasWidth,
        area.top / canvasHeight,
        area.width / canvasWidth,
        area.height / canvasHeight,
      ),
    );
  }

  @override
  final String name;
  final int layerIndex;
  final int frameIndex;
  final LayerSnapshot before;
  final LayerSnapshot after;
  @override
  final Layer thumbnail;
  final Rect outline;

  @override
  void undo(Document document) => before.restore(_image(document));

  @override
  void redo(Document document) => after.restore(_image(document));

  Layer _image(Document document) =>
      document.layers[layerIndex].imageAt(frameIndex);

  @override
  bool operator ==(Object other) =>
      other is PixelHistoryEntry &&
      other.name == name &&
      other.layerIndex == layerIndex &&
      other.frameIndex == frameIndex &&
      other.before == before &&
      other.after == after &&
      other.thumbnail == thumbnail &&
      other.outline == outline;

  @override
  int get hashCode => Object.hash(
    name,
    layerIndex,
    frameIndex,
    before,
    after,
    thumbnail,
    outline,
  );

  @override
  String toString() =>
      'PixelHistoryEntry($name, layer: $layerIndex, frame: $frameIndex)';
}
