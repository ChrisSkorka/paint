import '../canvas/document.dart';
import '../canvas/layer.dart';
import 'document_structure.dart';
import 'history_entry.dart';

class StructureHistoryEntry implements HistoryEntry {
  const StructureHistoryEntry({
    required this.name,
    required this.before,
    required this.after,
    required this.thumbnail,
  });

  @override
  final String name;
  final DocumentStructure before;
  final DocumentStructure after;
  @override
  final Layer thumbnail;

  @override
  void undo(Document document) => before.restore(document);

  @override
  void redo(Document document) => after.restore(document);

  @override
  bool operator ==(Object other) =>
      other is StructureHistoryEntry &&
      other.name == name &&
      other.before == before &&
      other.after == after &&
      other.thumbnail == thumbnail;

  @override
  int get hashCode => Object.hash(name, before, after, thumbnail);

  @override
  String toString() =>
      'StructureHistoryEntry($name, layers: ${before.layers.length} → ${after.layers.length}, frames: ${before.frameDurations.length} → ${after.frameDurations.length})';
}
