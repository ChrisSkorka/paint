import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';

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
        pixels: Layer.filled(
          width: 2,
          height: 1,
          color: PixelColor.transparent,
        ),
      ),
  ],
  activeLayerIndex: activeLayerIndex,
);

List<Object> layerStructure(Document document) => [
  [for (final layer in document.layers) layer.name],
  document.activeLayerIndex,
];
