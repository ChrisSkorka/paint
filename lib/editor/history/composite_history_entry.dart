import 'package:collection/collection.dart';

import '../canvas/document.dart';
import '../canvas/layer.dart';
import 'history_entry.dart';

class CompositeHistoryEntry implements HistoryEntry {
  const CompositeHistoryEntry({
    required this.name,
    required this.thumbnail,
    required this.entries,
  });

  @override
  final String name;
  @override
  final Layer thumbnail;
  final List<HistoryEntry> entries;

  @override
  void undo(Document document) {
    for (final entry in entries.reversed) {
      entry.undo(document);
    }
  }

  @override
  void redo(Document document) {
    for (final entry in entries) {
      entry.redo(document);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CompositeHistoryEntry &&
      other.name == name &&
      other.thumbnail == thumbnail &&
      const ListEquality<HistoryEntry>().equals(other.entries, entries);

  @override
  int get hashCode => Object.hash(
    name,
    thumbnail,
    const ListEquality<HistoryEntry>().hash(entries),
  );

  @override
  String toString() =>
      'CompositeHistoryEntry($name, entries: ${entries.length})';
}
