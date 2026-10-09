import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/tools/eraser.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;
  const grey = 0x88888888;

  group('class Eraser', () {
    group('method start', () {
      group('sizes', () {
        test('two', () {
          const eraser = Eraser(size: 2);
          final layer = Layer.filled(
            width: 3,
            height: 3,
            color: PixelColor.black,
          );
          final area = eraser.start(
            layer: layer,
            point: const PixelPoint(x: 1, y: 1),
            color: PixelColor.white,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            [
              [transparent, transparent, black],
              [transparent, transparent, black],
              [black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method stroke', () {
      group('lines', () {
        test('gap between points', () {
          const eraser = Eraser(size: 1);
          final layer = Layer.filled(
            width: 4,
            height: 1,
            color: PixelColor.black,
          );
          final area = eraser.stroke(
            layer: layer,
            previous: const PixelPoint(x: 0, y: 0),
            point: const PixelPoint(x: 2, y: 0),
            color: PixelColor.white,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 1),
            [
              [transparent, transparent, transparent, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method end', () {
      group('points', () {
        test('inside', () {
          const eraser = Eraser(size: 1);
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.black,
          );
          final area = eraser.end(
            layer: layer,
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.white,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 0, width: 0, height: 0),
            [
              [black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method drawPointer', () {
      group('colors', () {
        test('pointer color', () {
          const eraser = Eraser(size: 1);
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          final area = eraser.drawPointer(
            layer: layer,
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            [
              [transparent, grey],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
