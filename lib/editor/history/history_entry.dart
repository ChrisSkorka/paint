import '../canvas/document.dart';
import '../canvas/layer.dart';
import 'layer_snapshot.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.name,
    required this.layerIndex,
    required this.before,
    required this.after,
    required this.thumbnail,
  });

  final String name;
  final int layerIndex;
  final LayerSnapshot before;
  final LayerSnapshot after;
  final Layer thumbnail;

  void undo(Document document) => before.restore(document.layers[layerIndex]);

  void redo(Document document) => after.restore(document.layers[layerIndex]);

  @override
  bool operator ==(Object other) =>
      other is HistoryEntry &&
      other.name == name &&
      other.layerIndex == layerIndex &&
      other.before == before &&
      other.after == after &&
      other.thumbnail == thumbnail;

  @override
  int get hashCode => Object.hash(name, layerIndex, before, after, thumbnail);

  @override
  String toString() => 'HistoryEntry($name, layer: $layerIndex)';
}
