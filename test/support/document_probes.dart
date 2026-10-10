import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/layer_timeframe.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';

Document layeredDocument({
  required List<String> names,
  required int activeLayerIndex,
}) => Document(
  width: 2,
  height: 1,
  layers: [
    for (final name in names)
      DocumentLayer(
        name: name,
        images: [
          Layer.filled(width: 2, height: 1, color: PixelColor.transparent),
        ],
      ),
  ],
  activeLayerIndex: activeLayerIndex,
);

List<Object> layerStructure(Document document) => [
  [for (final layer in document.layers) layer.name],
  document.activeLayerIndex,
];

Document animatedDocument({
  required List<int> spriteColors,
  required int activeFrameIndex,
}) => Document(
  width: 1,
  height: 1,
  layers: [
    DocumentLayer(
      name: 'Background',
      images: [Layer.filled(width: 1, height: 1, color: PixelColor.white)],
    ),
    DocumentLayer(
      name: 'Sprite',
      images: [
        for (final color in spriteColors)
          Layer.filled(width: 1, height: 1, color: PixelColor(argb: color)),
      ],
      timeframe: LayerTimeframe.perFrame,
    ),
  ],
  activeLayerIndex: 1,
  frameHolds: [
    for (var frame = 0; frame < spriteColors.length; frame++) frame + 1,
  ],
  activeFrameIndex: activeFrameIndex,
);

List<Object> frameStructure(Document document) => [
  document.frameHolds,
  document.activeFrameIndex,
  [
    for (final layer in document.layers)
      [
        for (final image in layer.images)
          image.getPixel(const PixelPoint(x: 0, y: 0)).argb,
      ],
  ],
];
