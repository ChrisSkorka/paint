import '../canvas/document.dart';
import '../canvas/layer.dart';

abstract interface class HistoryEntry {
  String get name;
  Layer get thumbnail;

  void undo(Document document);

  void redo(Document document);
}
