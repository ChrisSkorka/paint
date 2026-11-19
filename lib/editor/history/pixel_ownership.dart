import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../canvas/layer.dart';
import '../canvas/pixel_rectangle.dart';
import 'image_edit.dart';
import 'layer_snapshot.dart';

class PixelOwnership {
  const PixelOwnership({
    required this.image,
    required this.area,
    required this.owned,
    required this.fallback,
  });

  factory PixelOwnership.resolved({
    required Layer image,
    required List<ImageEdit> edits,
    required Set<int> checkedEntries,
  }) {
    final imageEdits = [
      for (final edit in edits)
        if (identical(edit.image, image)) edit,
    ];
    final area = imageEdits
        .where((edit) => checkedEntries.contains(edit.entryIndex))
        .fold(_noArea, (area, edit) => area.union(edit.after.area));
    final owned = List.filled(area.width * area.height, false);
    final fallback = Uint8List(area.width * area.height * 4);
    for (final edit in imageEdits) {
      final checked = checkedEntries.contains(edit.entryIndex);
      final editArea = edit.after.area;
      final overlap = editArea.intersection(area);
      for (var y = overlap.top; y < overlap.bottom; y++) {
        for (var x = overlap.left; x < overlap.right; x++) {
          final editOffset =
              ((y - editArea.top) * editArea.width + x - editArea.left) * 4;
          if (_samePixel(
            first: edit.before.rgba,
            second: edit.after.rgba,
            firstOffset: editOffset,
            secondOffset: editOffset,
          )) {
            continue;
          }
          final index = (y - area.top) * area.width + x - area.left;
          if (!checked) {
            owned[index] = false;
          } else if (!owned[index]) {
            owned[index] = true;
            fallback.setRange(
              index * 4,
              index * 4 + 4,
              edit.before.rgba,
              editOffset,
            );
          }
        }
      }
    }
    final current = LayerSnapshot.capture(layer: image, area: area).rgba;
    for (var index = 0; index < owned.length; index++) {
      if (owned[index] &&
          _samePixel(
            first: current,
            second: fallback,
            firstOffset: index * 4,
            secondOffset: index * 4,
          )) {
        owned[index] = false;
      }
      if (!owned[index]) fallback.fillRange(index * 4, index * 4 + 4, 0);
    }
    return PixelOwnership(
      image: image,
      area: area,
      owned: owned,
      fallback: fallback,
    );
  }

  static const _noArea = PixelRectangle(left: 0, top: 0, width: 0, height: 0);

  final Layer image;
  final PixelRectangle area;
  final List<bool> owned;
  final Uint8List fallback;

  bool get isEmpty => !owned.contains(true);

  LayerSnapshot reverted() {
    final reverted = LayerSnapshot.capture(layer: image, area: area);
    for (var index = 0; index < owned.length; index++) {
      if (!owned[index]) continue;
      reverted.rgba.setRange(index * 4, index * 4 + 4, fallback, index * 4);
    }
    return reverted;
  }

  ({LayerSnapshot source, LayerSnapshot lifted}) layerized() {
    final source = LayerSnapshot.capture(layer: image, area: area);
    final lifted = LayerSnapshot(
      area: area,
      rgba: Uint8List(source.rgba.length),
    );
    for (var index = 0; index < owned.length; index++) {
      final offset = index * 4;
      final opaque = source.rgba[offset + 3] == 255;
      final uncovering = fallback[offset + 3] == 0;
      if (!owned[index] || !(opaque || uncovering)) continue;
      lifted.rgba.setRange(offset, offset + 4, source.rgba, offset);
      source.rgba.setRange(offset, offset + 4, fallback, offset);
    }
    return (source: source, lifted: lifted);
  }

  static bool _samePixel({
    required Uint8List first,
    required Uint8List second,
    required int firstOffset,
    required int secondOffset,
  }) {
    for (var channel = 0; channel < 4; channel++) {
      if (first[firstOffset + channel] != second[secondOffset + channel]) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is PixelOwnership &&
      identical(other.image, image) &&
      other.area == area &&
      const ListEquality<bool>().equals(other.owned, owned) &&
      const ListEquality<int>().equals(other.fallback, fallback);

  @override
  int get hashCode => Object.hash(
    identityHashCode(image),
    area,
    const ListEquality<bool>().hash(owned),
    const ListEquality<int>().hash(fallback),
  );

  @override
  String toString() =>
      'PixelOwnership($area, owned: ${owned.where((owned) => owned).length})';
}
