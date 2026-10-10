import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
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
            origin: PixelPoint(x: 0, y: 0),
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
            origin: PixelPoint(x: 0, y: 0),
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
            origin: PixelPoint(x: 0, y: 0),
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
            origin: PixelPoint(x: 0, y: 0),
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
          const tool = ShapeTool(shape: Shape.line, width: 2, origin: null);
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
    });
  });
}
