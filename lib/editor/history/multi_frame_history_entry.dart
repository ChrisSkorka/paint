import 'dart:ui';

import 'package:collection/collection.dart';

import '../canvas/document.dart';
import '../canvas/layer.dart';
import 'history_entry.dart';
import 'pixel_history_entry.dart';

class MultiFrameHistoryEntry implements HistoryEntry {
  const MultiFrameHistoryEntry({required this.entries});

  final List<PixelHistoryEntry> entries;

  @override
  String get name => entries.first.name;

  @override
  Layer get thumbnail => entries.first.thumbnail;

  Rect get outline => entries.first.outline;

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
      other is MultiFrameHistoryEntry &&
      const ListEquality<PixelHistoryEntry>().equals(other.entries, entries);

  @override
  int get hashCode => const ListEquality<PixelHistoryEntry>().hash(entries);

  @override
  String toString() =>
      'MultiFrameHistoryEntry($name, frames: ${entries.length})';
}
