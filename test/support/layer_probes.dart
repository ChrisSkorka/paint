import 'dart:typed_data';

import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';

List<List<int>> pixelRows(Layer layer) => [
  for (var y = 0; y < layer.height; y++)
    [
      for (var x = 0; x < layer.width; x++)
        layer.getPixel(PixelPoint(x: x, y: y)).argb,
    ],
];

Layer layerFromRows(List<List<int>> rows) {
  final layer = Layer.filled(
    width: rows.first.length,
    height: rows.length,
    color: PixelColor.transparent,
  );
  for (var y = 0; y < layer.height; y++) {
    for (var x = 0; x < layer.width; x++) {
      layer.setPixel(
        point: PixelPoint(x: x, y: y),
        color: PixelColor(argb: rows[y][x]),
      );
    }
  }
  return layer;
}

Uint8List rgbaOf(List<int> colors) => Uint8List.fromList([
  for (final argb in colors) ...[
    PixelColor(argb: argb).red,
    PixelColor(argb: argb).green,
    PixelColor(argb: argb).blue,
    PixelColor(argb: argb).alpha,
  ],
]);
