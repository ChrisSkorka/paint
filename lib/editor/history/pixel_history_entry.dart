import '../canvas/document.dart';
import '../canvas/layer.dart';
import 'history_entry.dart';
import 'layer_snapshot.dart';

class PixelHistoryEntry implements HistoryEntry {
  const PixelHistoryEntry({
    required this.name,
    required this.layerIndex,
    required this.before,
    required this.after,
    required this.thumbnail,
  });

  @override
  final String name;
  final int layerIndex;
  final LayerSnapshot before;
  final LayerSnapshot after;
  @override
  final Layer thumbnail;

  @override
  void undo(Document document) =>
      before.restore(document.layers[layerIndex].pixels);

  @override
  void redo(Document document) =>
      after.restore(document.layers[layerIndex].pixels);

  @override
  bool operator ==(Object other) =>
      other is PixelHistoryEntry &&
      other.name == name &&
      other.layerIndex == layerIndex &&
      other.before == before &&
      other.after == after &&
      other.thumbnail == thumbnail;

  @override
  int get hashCode => Object.hash(name, layerIndex, before, after, thumbnail);

  @override
  String toString() => 'PixelHistoryEntry($name, layer: $layerIndex)';
}
