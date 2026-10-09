import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/pen.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;

  group('class Pen', () {
    group('method start', () {
      group('tips', () {
        test('square', () {
          const pen = Pen(size: 2, tip: BrushTip.square);
          final layer = Layer.filled(
            width: 3,
            height: 3,
            color: PixelColor.transparent,
          );
          final area = pen.start(
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
              [transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('circle', () {
          const pen = Pen(size: 4, tip: BrushTip.circle);
          final layer = Layer.filled(
            width: 4,
            height: 4,
            color: PixelColor.transparent,
          );
          final area = pen.start(
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
      });
    });

    group('method stroke', () {
      group('lines', () {
        test('same point', () {
          const pen = Pen(size: 1, tip: BrushTip.square);
          final layer = Layer.filled(
            width: 3,
            height: 1,
            color: PixelColor.transparent,
          );
          final area = pen.stroke(
            layer: layer,
            previous: const PixelPoint(x: 1, y: 0),
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            [
              [transparent, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('gap between points', () {
          const pen = Pen(size: 1, tip: BrushTip.square);
          final layer = Layer.filled(
            width: 4,
            height: 1,
            color: PixelColor.transparent,
          );
          final area = pen.stroke(
            layer: layer,
            previous: const PixelPoint(x: 0, y: 0),
            point: const PixelPoint(x: 2, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 1),
            [
              [black, black, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('wide tip', () {
          const pen = Pen(size: 2, tip: BrushTip.square);
          final layer = Layer.filled(
            width: 4,
            height: 3,
            color: PixelColor.transparent,
          );
          final area = pen.stroke(
            layer: layer,
            previous: const PixelPoint(x: 1, y: 1),
            point: const PixelPoint(x: 2, y: 1),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 2),
            [
              [black, black, black, transparent],
              [black, black, black, transparent],
              [transparent, transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('clipping', () {
        test('leaving the layer', () {
          const pen = Pen(size: 1, tip: BrushTip.square);
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          final area = pen.stroke(
            layer: layer,
            previous: const PixelPoint(x: 1, y: 0),
            point: const PixelPoint(x: 3, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            [
              [transparent, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method end', () {
      group('points', () {
        test('inside', () {
          const pen = Pen(size: 1, tip: BrushTip.square);
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          final area = pen.end(
            layer: layer,
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 0, width: 0, height: 0),
            [
              [transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method drawPointer', () {
      group('tips', () {
        test('square', () {
          const pen = Pen(size: 2, tip: BrushTip.square);
          final layer = Layer.filled(
            width: 3,
            height: 3,
            color: PixelColor.transparent,
          );
          final area = pen.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 2, y: 2),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 1, width: 2, height: 2),
            [
              [transparent, transparent, transparent],
              [transparent, black, black],
              [transparent, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
