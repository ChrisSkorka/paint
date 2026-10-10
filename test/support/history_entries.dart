import 'dart:typed_data';

import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/layer_snapshot.dart';
import 'package:paint/editor/history/pixel_history_entry.dart';

PixelHistoryEntry pixelEntry({
  required String name,
  required int x,
  required int before,
  required int after,
}) => PixelHistoryEntry(
  name: name,
  layerIndex: 0,
  frameIndex: 0,
  before: LayerSnapshot(
    area: PixelRectangle(left: x, top: 0, width: 1, height: 1),
    rgba: Uint8List.fromList([before, before, before, before]),
  ),
  after: LayerSnapshot(
    area: PixelRectangle(left: x, top: 0, width: 1, height: 1),
    rgba: Uint8List.fromList([after, after, after, after]),
  ),
  thumbnail: Layer.filled(width: 1, height: 1, color: PixelColor.transparent),
);
