import 'dart:typed_data';

import 'package:paint/editor/history/history_entry.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/layer_snapshot.dart';

HistoryEntry pixelEntry({
  required String name,
  required int x,
  required int before,
  required int after,
}) => HistoryEntry(
  name: name,
  layerIndex: 0,
  before: LayerSnapshot(
    area: PixelRectangle(left: x, top: 0, width: 1, height: 1),
    rgba: Uint8List.fromList([before, before, before, before]),
  ),
  after: LayerSnapshot(
    area: PixelRectangle(left: x, top: 0, width: 1, height: 1),
    rgba: Uint8List.fromList([after, after, after, after]),
  ),
);
