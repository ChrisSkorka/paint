import '../canvas/document.dart';
import 'layer_snapshot.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.name,
    required this.layerIndex,
    required this.before,
    required this.after,
  });

  final String name;
  final int layerIndex;
  final LayerSnapshot before;
  final LayerSnapshot after;

  void undo(Document document) => before.restore(document.layers[layerIndex]);

  void redo(Document document) => after.restore(document.layers[layerIndex]);

  @override
  bool operator ==(Object other) =>
      other is HistoryEntry &&
      other.name == name &&
      other.layerIndex == layerIndex &&
      other.before == before &&
      other.after == after;

  @override
  int get hashCode => Object.hash(name, layerIndex, before, after);

  @override
  String toString() => 'HistoryEntry($name, layer: $layerIndex)';
}
