import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/tools/shape.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;

  List<Object> drawOnBlank({
    required Shape shape,
    required int layerWidth,
    required int layerHeight,
    required PixelPoint from,
    required PixelPoint to,
    required int width,
  }) {
    final layer = layerFromRows([
      for (var y = 0; y < layerHeight; y++)
        [for (var x = 0; x < layerWidth; x++) transparent],
    ]);
    final area = shape.draw(
      layer: layer,
      from: from,
      to: to,
      width: width,
      color: PixelColor.black,
    );
    return [area, pixelRows(layer)];
  }

  group('enum Shape', () {
    group('method draw', () {
      group('line', () {
        test('horizontal', () {
          final actual = drawOnBlank(
            shape: Shape.line,
            layerWidth: 4,
            layerHeight: 1,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 2, y: 0),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 1),
            [
              [black, black, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('diagonal', () {
          final actual = drawOnBlank(
            shape: Shape.line,
            layerWidth: 3,
            layerHeight: 3,
            from: const PixelPoint(x: 2, y: 0),
            to: const PixelPoint(x: 0, y: 2),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 3),
            [
              [transparent, transparent, black],
              [transparent, black, transparent],
              [black, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('thick', () {
          final actual = drawOnBlank(
            shape: Shape.line,
            layerWidth: 4,
            layerHeight: 3,
            from: const PixelPoint(x: 1, y: 1),
            to: const PixelPoint(x: 2, y: 1),
            width: 2,
          );
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

      group('rectangle', () {
        test('outline', () {
          final actual = drawOnBlank(
            shape: Shape.rectangle,
            layerWidth: 4,
            layerHeight: 4,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 3, y: 3),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 4, height: 4),
            [
              [black, black, black, black],
              [black, transparent, transparent, black],
              [black, transparent, transparent, black],
              [black, black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('reversed corners', () {
          final actual = drawOnBlank(
            shape: Shape.rectangle,
            layerWidth: 4,
            layerHeight: 3,
            from: const PixelPoint(x: 3, y: 2),
            to: const PixelPoint(x: 1, y: 0),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 1, top: 0, width: 3, height: 3),
            [
              [transparent, black, black, black],
              [transparent, black, transparent, black],
              [transparent, black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('thick', () {
          final actual = drawOnBlank(
            shape: Shape.rectangle,
            layerWidth: 5,
            layerHeight: 5,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 4, y: 4),
            width: 2,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 5, height: 5),
            [
              [black, black, black, black, black],
              [black, black, black, black, black],
              [black, black, transparent, black, black],
              [black, black, black, black, black],
              [black, black, black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('wider than box', () {
          final actual = drawOnBlank(
            shape: Shape.rectangle,
            layerWidth: 4,
            layerHeight: 3,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 1, y: 1),
            width: 3,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            [
              [black, black, transparent, transparent],
              [black, black, transparent, transparent],
              [transparent, transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('clipped', () {
          final actual = drawOnBlank(
            shape: Shape.rectangle,
            layerWidth: 2,
            layerHeight: 2,
            from: const PixelPoint(x: 1, y: 1),
            to: const PixelPoint(x: 3, y: 3),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 1, top: 1, width: 1, height: 1),
            [
              [transparent, transparent],
              [transparent, black],
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('ellipse', () {
        test('circle', () {
          final actual = drawOnBlank(
            shape: Shape.ellipse,
            layerWidth: 5,
            layerHeight: 5,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 4, y: 4),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 5, height: 5),
            [
              [transparent, black, black, black, transparent],
              [black, transparent, transparent, transparent, black],
              [black, transparent, transparent, transparent, black],
              [black, transparent, transparent, transparent, black],
              [transparent, black, black, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('narrow', () {
          final actual = drawOnBlank(
            shape: Shape.ellipse,
            layerWidth: 12,
            layerHeight: 3,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 11, y: 2),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 12, height: 3),
            [
              [
                transparent,
                transparent,
                black,
                black,
                black,
                black,
                black,
                black,
                black,
                black,
                transparent,
                transparent,
              ],
              [
                black,
                black,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                black,
                black,
              ],
              [
                transparent,
                transparent,
                black,
                black,
                black,
                black,
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
        test('single row', () {
          final actual = drawOnBlank(
            shape: Shape.ellipse,
            layerWidth: 5,
            layerHeight: 1,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 4, y: 0),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 5, height: 1),
            [
              [black, black, black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('clipped', () {
          final actual = drawOnBlank(
            shape: Shape.ellipse,
            layerWidth: 3,
            layerHeight: 3,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 4, y: 4),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 3),
            [
              [transparent, black, black],
              [black, transparent, transparent],
              [black, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
      group('arrow', () {
        test('horizontal', () {
          final actual = drawOnBlank(
            shape: Shape.arrow,
            layerWidth: 7,
            layerHeight: 7,
            from: const PixelPoint(x: 0, y: 3),
            to: const PixelPoint(x: 6, y: 3),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 1, width: 7, height: 5),
            [
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
                black,
                transparent,
                transparent,
              ],
              [
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                black,
                transparent,
              ],
              [black, black, black, black, black, black, black],
              [
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                black,
                transparent,
              ],
              [
                transparent,
                transparent,
                transparent,
                transparent,
                black,
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
            ],
          ];
          expect(actual, equals(expected));
        });
        test('diagonal', () {
          final actual = drawOnBlank(
            shape: Shape.arrow,
            layerWidth: 5,
            layerHeight: 5,
            from: const PixelPoint(x: 0, y: 0),
            to: const PixelPoint(x: 4, y: 4),
            width: 1,
          );
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 5, height: 5),
            [
              [black, transparent, transparent, transparent, transparent],
              [transparent, black, transparent, transparent, black],
              [transparent, transparent, black, transparent, black],
              [transparent, transparent, transparent, black, black],
              [transparent, black, black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('single point', () {
          final actual = drawOnBlank(
            shape: Shape.arrow,
            layerWidth: 3,
            layerHeight: 3,
            from: const PixelPoint(x: 1, y: 1),
            to: const PixelPoint(x: 1, y: 1),
            width: 1,
          );
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
      });
    });
  });
}
