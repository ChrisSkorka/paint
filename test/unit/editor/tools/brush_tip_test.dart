import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/tools/brush_tip.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;

  group('enum BrushTip', () {
    group('method area', () {
      group('sizes', () {
        test('one', () {
          final actual = BrushTip.square.area(
            center: const PixelPoint(x: 2, y: 2),
            size: 1,
          );
          const expected = PixelRectangle(left: 2, top: 2, width: 1, height: 1);
          expect(actual, equals(expected));
        });
        test('even', () {
          final actual = BrushTip.square.area(
            center: const PixelPoint(x: 2, y: 2),
            size: 2,
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 2, height: 2);
          expect(actual, equals(expected));
        });
        test('odd', () {
          final actual = BrushTip.circle.area(
            center: const PixelPoint(x: 2, y: 2),
            size: 3,
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 3, height: 3);
          expect(actual, equals(expected));
        });
      });
    });

    group('method stamp', () {
      group('square', () {
        test('size one', () {
          final layer = Layer.filled(
            width: 3,
            height: 3,
            color: PixelColor.transparent,
          );
          final area = BrushTip.square.stamp(
            layer: layer,
            center: const PixelPoint(x: 1, y: 1),
            size: 1,
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 1, width: 1, height: 1),
            [
              [transparent, transparent, transparent],
              [transparent, black, transparent],
              [transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('size two', () {
          final layer = Layer.filled(
            width: 3,
            height: 3,
            color: PixelColor.transparent,
          );
          final area = BrushTip.square.stamp(
            layer: layer,
            center: const PixelPoint(x: 1, y: 1),
            size: 2,
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
      });

      group('circle', () {
        test('size one', () {
          final layer = Layer.filled(
            width: 3,
            height: 3,
            color: PixelColor.transparent,
          );
          final area = BrushTip.circle.stamp(
            layer: layer,
            center: const PixelPoint(x: 1, y: 1),
            size: 1,
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 1, width: 1, height: 1),
            [
              [transparent, transparent, transparent],
              [transparent, black, transparent],
              [transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('size three', () {
          final layer = Layer.filled(
            width: 3,
            height: 3,
            color: PixelColor.transparent,
          );
          final area = BrushTip.circle.stamp(
            layer: layer,
            center: const PixelPoint(x: 1, y: 1),
            size: 3,
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 3),
            [
              [black, black, black],
              [black, black, black],
              [black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('size four', () {
          final layer = Layer.filled(
            width: 4,
            height: 4,
            color: PixelColor.transparent,
          );
          final area = BrushTip.circle.stamp(
            layer: layer,
            center: const PixelPoint(x: 2, y: 2),
            size: 4,
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

      group('clipping', () {
        test('square partly outside', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final area = BrushTip.square.stamp(
            layer: layer,
            center: const PixelPoint(x: 0, y: 0),
            size: 3,
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            [
              [black, black],
              [black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('circle partly outside', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final area = BrushTip.circle.stamp(
            layer: layer,
            center: const PixelPoint(x: 0, y: 0),
            size: 4,
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            [
              [black, black],
              [black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('fully outside', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final area = BrushTip.square.stamp(
            layer: layer,
            center: const PixelPoint(x: 5, y: 5),
            size: 1,
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 5, top: 5, width: 0, height: 0),
            [
              [transparent, transparent],
              [transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
