import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_point.dart';

List<List<int>> pixelRows(Layer layer) => [
  for (var y = 0; y < layer.height; y++)
    [
      for (var x = 0; x < layer.width; x++)
        layer.getPixel(PixelPoint(x: x, y: y)).argb,
    ],
];
