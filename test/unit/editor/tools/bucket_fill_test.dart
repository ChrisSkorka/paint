import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/tools/bucket_fill.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;
  const red = 0xFFFF0000;

  group('class BucketFill', () {
    group('method start', () {
      group('regions', () {
        test('whole layer', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ]);
          final area = const BucketFill().start(
            layer: layer,
            point: const PixelPoint(x: 1, y: 1),
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
        test('enclosed area', () {
          final layer = layerFromRows([
            [transparent, black, transparent, transparent],
            [black, transparent, black, transparent],
            [transparent, black, transparent, transparent],
          ]);
          final area = const BucketFill().start(
            layer: layer,
            point: const PixelPoint(x: 1, y: 1),
            color: PixelColor(argb: red),
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 1, top: 1, width: 1, height: 1),
            [
              [transparent, black, transparent, transparent],
              [black, red, black, transparent],
              [transparent, black, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('diagonal neighbours', () {
          final layer = layerFromRows([
            [transparent, black],
            [black, transparent],
          ]);
          final area = const BucketFill().start(
            layer: layer,
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor(argb: red),
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            [
              [red, black],
              [black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('around obstacle', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
            [transparent, black, transparent],
            [transparent, transparent, transparent],
          ]);
          final area = const BucketFill().start(
            layer: layer,
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor(argb: red),
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 3),
            [
              [red, red, red],
              [red, black, red],
              [red, red, red],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('similar color', () {
          final layer = layerFromRows([
            [black, 0xFF000001, black],
          ]);
          final area = const BucketFill().start(
            layer: layer,
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor(argb: red),
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            [
              [red, 0xFF000001, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('no change', () {
        test('same color', () {
          final layer = layerFromRows([
            [black, black],
          ]);
          final area = const BucketFill().start(
            layer: layer,
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
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
        test('outside layer', () {
          final layer = layerFromRows([
            [transparent, transparent],
          ]);
          final area = const BucketFill().start(
            layer: layer,
            point: const PixelPoint(x: 5, y: 0),
            color: PixelColor.black,
          );
          final actual = [area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 5, top: 0, width: 0, height: 0),
            [
              [transparent, transparent],
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
            [transparent, transparent],
          ]);
          final area = const BucketFill().stroke(
            layer: layer,
            previous: const PixelPoint(x: 0, y: 0),
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

    group('method end', () {
      group('points', () {
        test('inside', () {
          final layer = layerFromRows([
            [transparent, transparent],
          ]);
          final area = const BucketFill().end(
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
      group('points', () {
        test('single pixel', () {
          final layer = layerFromRows([
            [transparent, transparent, transparent],
          ]);
          final area = const BucketFill().drawPointer(
            layer: layer,
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
      });
    });
  });
}
