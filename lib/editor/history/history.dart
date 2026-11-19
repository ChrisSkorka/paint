import '../canvas/document.dart';
import '../canvas/document_layer.dart';
import '../canvas/layer.dart';
import 'composite_history_entry.dart';
import 'history_entry.dart';
import 'image_edit.dart';
import 'multi_frame_history_entry.dart';
import 'pixel_history_entry.dart';
import 'structure_history_entry.dart';

typedef HistoryPoint = ({int position, HistoryEntry? entry});

class History {
  History({required this.document, required this.startThumbnail});

  factory History.forDocument({required Document document}) {
    return History(
      document: document,
      startThumbnail: Layer.thumbnail(
        layer: document.activeLayer,
        maximumSize: thumbnailSize,
      ),
    );
  }

  static const thumbnailSize = 24;

  final Document document;
  final Layer startThumbnail;
  final _entries = <HistoryEntry>[];
  var _position = 0;
  HistoryPoint _savedPoint = (position: 0, entry: null);

  List<HistoryEntry> get entries => List.unmodifiable(_entries);
  int get position => _position;
  bool get canUndo => _position > 0;
  bool get canRedo => _position < _entries.length;
  HistoryPoint get point => (
    position: _position,
    entry: _position == 0 ? null : _entries[_position - 1],
  );
  bool get isAtSavedPoint =>
      _savedPoint.position == _position &&
      identical(_savedPoint.entry, point.entry);

  List<ImageEdit> get imageEdits {
    final edits = <ImageEdit>[];
    List<DocumentLayer> layers = document.layers;
    for (var index = _position - 1; index >= 0; index--) {
      for (final entry in _leaves(_entries[index]).reversed) {
        switch (entry) {
          case PixelHistoryEntry():
            edits.add(
              ImageEdit(
                entryIndex: index,
                image: layers[entry.layerIndex].imageAt(entry.frameIndex),
                before: entry.before,
                after: entry.after,
              ),
            );
          case StructureHistoryEntry():
            layers = entry.before.layers;
        }
      }
    }
    return edits.reversed.toList();
  }

  static List<HistoryEntry> _leaves(HistoryEntry entry) => switch (entry) {
    MultiFrameHistoryEntry() => entry.entries,
    CompositeHistoryEntry() => [
      for (final child in entry.entries) ..._leaves(child),
    ],
    _ => [entry],
  };

  void markSaved(HistoryPoint point) => _savedPoint = point;

  void record(HistoryEntry entry) {
    _entries
      ..removeRange(_position, _entries.length)
      ..add(entry);
    _position = _entries.length;
  }

  void undo() => jumpTo(_position - 1);

  void redo() => jumpTo(_position + 1);

  void jumpTo(int position) {
    final target = position.clamp(0, _entries.length);
    while (_position > target) {
      _position--;
      _entries[_position].undo(document);
    }
    while (_position < target) {
      _entries[_position].redo(document);
      _position++;
    }
  }
}
