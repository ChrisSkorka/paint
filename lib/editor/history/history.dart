import '../canvas/document.dart';
import 'history_entry.dart';

class History {
  History({required this.document});

  final Document document;
  final _entries = <HistoryEntry>[];
  var _position = 0;

  List<HistoryEntry> get entries => List.unmodifiable(_entries);
  int get position => _position;
  bool get canUndo => _position > 0;
  bool get canRedo => _position < _entries.length;

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
