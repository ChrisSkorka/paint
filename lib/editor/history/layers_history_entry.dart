import 'package:collection/collection.dart';

import '../canvas/document.dart';
import '../canvas/document_layer.dart';
import '../canvas/layer.dart';
import 'history_entry.dart';

class LayersHistoryEntry implements HistoryEntry {
  const LayersHistoryEntry({
    required this.name,
    required this.layersBefore,
    required this.activeIndexBefore,
    required this.layersAfter,
    required this.activeIndexAfter,
    required this.thumbnail,
  });

  @override
  final String name;
  final List<DocumentLayer> layersBefore;
  final int activeIndexBefore;
  final List<DocumentLayer> layersAfter;
  final int activeIndexAfter;
  @override
  final Layer thumbnail;

  @override
  void undo(Document document) => _restore(
    document: document,
    layers: layersBefore,
    activeIndex: activeIndexBefore,
  );

  @override
  void redo(Document document) => _restore(
    document: document,
    layers: layersAfter,
    activeIndex: activeIndexAfter,
  );

  void _restore({
    required Document document,
    required List<DocumentLayer> layers,
    required int activeIndex,
  }) {
    document.layers
      ..clear()
      ..addAll(layers);
    document.activeLayerIndex = activeIndex;
  }

  @override
  bool operator ==(Object other) =>
      other is LayersHistoryEntry &&
      other.name == name &&
      const ListEquality<DocumentLayer>().equals(
        other.layersBefore,
        layersBefore,
      ) &&
      other.activeIndexBefore == activeIndexBefore &&
      const ListEquality<DocumentLayer>().equals(
        other.layersAfter,
        layersAfter,
      ) &&
      other.activeIndexAfter == activeIndexAfter &&
      other.thumbnail == thumbnail;

  @override
  int get hashCode => Object.hash(
    name,
    const ListEquality<DocumentLayer>().hash(layersBefore),
    activeIndexBefore,
    const ListEquality<DocumentLayer>().hash(layersAfter),
    activeIndexAfter,
    thumbnail,
  );

  @override
  String toString() =>
      'LayersHistoryEntry($name, layers: ${layersBefore.length} → ${layersAfter.length})';
}
