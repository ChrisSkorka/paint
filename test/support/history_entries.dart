import 'dart:typed_data';
import 'dart:ui';

import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/image_edit.dart';
import 'package:paint/editor/history/layer_snapshot.dart';
import 'package:paint/editor/history/pixel_history_entry.dart';

import 'layer_probes.dart';

PixelHistoryEntry pixelEntry({
  required String name,
  required int x,
  required int before,
  required int after,
  int layerIndex = 0,
  int frameIndex = 0,
}) => PixelHistoryEntry(
  name: name,
  layerIndex: layerIndex,
  frameIndex: frameIndex,
  before: LayerSnapshot(
    area: PixelRectangle(left: x, top: 0, width: 1, height: 1),
    rgba: Uint8List.fromList([before, before, before, before]),
  ),
  after: LayerSnapshot(
    area: PixelRectangle(left: x, top: 0, width: 1, height: 1),
    rgba: Uint8List.fromList([after, after, after, after]),
  ),
  thumbnail: Layer.filled(width: 1, height: 1, color: PixelColor.transparent),
  outline: Rect.zero,
);

ImageEdit rowEdit({
  required int entryIndex,
  required Layer image,
  int left = 0,
  required List<int> before,
  required List<int> after,
}) => ImageEdit(
  entryIndex: entryIndex,
  image: image,
  before: LayerSnapshot(
    area: PixelRectangle(left: left, top: 0, width: before.length, height: 1),
    rgba: rgbaOf(before),
  ),
  after: LayerSnapshot(
    area: PixelRectangle(left: left, top: 0, width: after.length, height: 1),
    rgba: rgbaOf(after),
  ),
);
