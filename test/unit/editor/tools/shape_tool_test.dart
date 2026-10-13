import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/shape.dart';
import 'package:paint/editor/tools/shape_tool.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;

  group('class ShapeTool', () {
    group('method start', () {
      group('points', () {
        test('inside', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.line,
            width: 1,
            tip: BrushTip.square,
            origin: PixelPoint(x: 0, y: 0),
            constrained: false,
          );
          final area = tool.start(
            layer: layer,
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 0, height: 0),
            [
              [transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method stroke', () {
      group('points', () {
        test('drag', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.line,
            width: 1,
            tip: BrushTip.square,
            origin: PixelPoint(x: 0, y: 0),
            constrained: false,
          );
          final area = tool.stroke(
            layer: layer,
            previous: const PixelPoint(x: 0, y: 0),
            point: const PixelPoint(x: 2, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 2, top: 0, width: 0, height: 0),
            [
              [transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method end', () {
      group('origins', () {
        test('from origin', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.line,
            width: 1,
            tip: BrushTip.square,
            origin: PixelPoint(x: 0, y: 0),
            constrained: false,
          );
          final area = tool.end(
            layer: layer,
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
            [
              [black, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method drawPointer', () {
      group('origins', () {
        test('dragging', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.rectangle,
            width: 1,
            tip: BrushTip.square,
            origin: PixelPoint(x: 0, y: 0),
            constrained: false,
          );
          final area = tool.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 2, y: 1),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 2),
            [
              [black, black, black],
              [black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('hovering', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.line,
            width: 2,
            tip: BrushTip.square,
            origin: null,
            constrained: false,
          );
          final area = tool.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 1, y: 1),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            [
              [black, black, transparent],
              [black, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('hovering rectangle', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.rectangle,
            width: 2,
            tip: BrushTip.square,
            origin: null,
            constrained: false,
          );
          final area = tool.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 1, y: 1),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            [
              [black, black, transparent],
              [black, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
      group('tips', () {
        test('hovering round tip', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent, transparent],
            [transparent, transparent, transparent, transparent],
            [transparent, transparent, transparent, transparent],
            [transparent, transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.rectangle,
            width: 4,
            tip: BrushTip.circle,
            origin: null,
            constrained: false,
          );
          final area = tool.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 2, y: 2),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 4, height: 4),
            [
              [transparent, black, black, transparent],
              [black, black, black, black],
              [black, black, black, black],
              [transparent, black, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('dragging round tip', () {
          final layer = layerFromRows([
            [
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
            ],
            [
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
            ],
            [
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
            ],
            [
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
              transparent,
            ],
          ]);
          const tool = ShapeTool(
            shape: Shape.line,
            width: 4,
            tip: BrushTip.circle,
            origin: PixelPoint(x: 2, y: 2),
            constrained: false,
          );
          final area = tool.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 4, y: 2),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 6, height: 4),
            [
              [
                transparent,
                black,
                black,
                black,
                black,
                transparent,
                transparent,
              ],
              [black, black, black, black, black, black, transparent],
              [black, black, black, black, black, black, transparent],
              [
                transparent,
                black,
                black,
                black,
                black,
                transparent,
                transparent,
              ],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('constrained', () {
      group('points', () {
        test('square', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.rectangle,
            width: 1,
            tip: BrushTip.square,
            origin: PixelPoint(x: 0, y: 0),
            constrained: true,
          );
          final area = tool.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 2, y: 1),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 3),
            [
              [black, black, black],
              [black, transparent, black],
              [black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('diagonal line', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ]);
          const tool = ShapeTool(
            shape: Shape.line,
            width: 1,
            tip: BrushTip.square,
            origin: PixelPoint(x: 0, y: 0),
            constrained: true,
          );
          final area = tool.end(
            layer: layer,
            point: const PixelPoint(x: 2, y: 1),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 3),
            [
              [black, transparent, transparent],
              [transparent, black, transparent],
              [transparent, transparent, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
