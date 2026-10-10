import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/selection/selection.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const red = 0xFFFF0000;
  const green = 0xFF00FF00;
  const blue = 0xFF0000FF;
  const cyan = 0xFF00FFFF;
  const magenta = 0xFFFF00FF;
  const yellow = 0xFFFFFF00;

  group('class Selection', () {
    group('factory lift', () {
      group('areas', () {
        test('part of layer', () {
          final layer = layerFromRows([
            [red, green, blue],
            [cyan, magenta, yellow],
          ]);
          final selection = Selection.lift(
            layer: layer,
            area: const PixelRectangle(left: 1, top: 0, width: 2, height: 1),
          );
          final actual = [
            selection.area,
            pixelRows(selection.content),
            pixelRows(selection.background),
            pixelRows(layer),
          ];
          final expected = [
            const PixelRectangle(left: 1, top: 0, width: 2, height: 1),
            [
              [green, blue],
            ],
            [
              [red, transparent, transparent],
              [cyan, magenta, yellow],
            ],
            [
              [red, green, blue],
              [cyan, magenta, yellow],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('factory pasted', () {
      group('positions', () {
        test('inside layer', () {
          final layer = layerFromRows([
            [red, green, blue],
            [cyan, magenta, yellow],
          ]);
          final selection = Selection.pasted(
            layer: layer,
            content: layerFromRows([
              [transparent],
            ]),
            at: const PixelPoint(x: 1, y: 1),
          );
          final actual = [
            selection.area,
            pixelRows(selection.content),
            pixelRows(selection.background),
            pixelRows(layer),
          ];
          final expected = [
            const PixelRectangle(left: 1, top: 1, width: 1, height: 1),
            [
              [transparent],
            ],
            [
              [red, green, blue],
              [cyan, magenta, yellow],
            ],
            [
              [red, green, blue],
              [cyan, transparent, yellow],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('beyond layer', () {
          final layer = layerFromRows([
            [red, green],
          ]);
          final selection = Selection.pasted(
            layer: layer,
            content: layerFromRows([
              [cyan, magenta, yellow],
              [cyan, magenta, yellow],
            ]),
            at: const PixelPoint(x: 0, y: 0),
          );
          final actual = [selection.area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 3, height: 2),
            [
              [cyan, magenta],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
      group('moved', () {
        test('restores background', () {
          final layer = layerFromRows([
            [red, green, blue],
          ]);
          final moved = Selection.pasted(
            layer: layer,
            content: layerFromRows([
              [cyan],
            ]),
            at: const PixelPoint(x: 0, y: 0),
          ).moved(layer: layer, offsetX: 2, offsetY: 0);
          final actual = [moved.area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 2, top: 0, width: 1, height: 1),
            [
              [red, green, cyan],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method moved', () {
      group('offsets', () {
        test('right', () {
          final layer = layerFromRows([
            [red, green, blue],
          ]);
          final selection = Selection.lift(
            layer: layer,
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          ).moved(layer: layer, offsetX: 2, offsetY: 0);
          final actual = [selection.area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 2, top: 0, width: 1, height: 1),
            [
              [transparent, green, red],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('off layer and back', () {
          final layer = layerFromRows([
            [red, green, blue],
          ]);
          final offLayer = Selection.lift(
            layer: layer,
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          ).moved(layer: layer, offsetX: -1, offsetY: 0);
          final offLayerRows = pixelRows(layer);
          offLayer.moved(layer: layer, offsetX: 1, offsetY: 0);
          final actual = [offLayerRows, pixelRows(layer)];
          final expected = [
            [
              [transparent, green, blue],
            ],
            [
              [red, green, blue],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method rotated', () {
      group('directions', () {
        test('clockwise', () {
          final layer = layerFromRows([
            [red, green, transparent],
            [transparent, transparent, transparent],
          ]);
          final selection = Selection.lift(
            layer: layer,
            area: const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
          ).rotated(layer: layer, clockwise: true);
          final actual = [selection.area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 1, height: 2),
            [
              [red, transparent, transparent],
              [green, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('counterclockwise', () {
          final layer = layerFromRows([
            [red, green, transparent],
            [transparent, transparent, transparent],
          ]);
          final selection = Selection.lift(
            layer: layer,
            area: const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
          ).rotated(layer: layer, clockwise: false);
          final actual = [selection.area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 1, height: 2),
            [
              [green, transparent, transparent],
              [red, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method mirrored', () {
      group('directions', () {
        test('horizontally', () {
          final layer = layerFromRows([
            [red, green, blue],
          ]);
          final selection = Selection.lift(
            layer: layer,
            area: const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
          ).mirrored(layer: layer, horizontally: true);
          final actual = [selection.area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
            [
              [green, red, blue],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('vertically', () {
          final layer = layerFromRows([
            [red, green],
            [cyan, magenta],
          ]);
          final selection = Selection.lift(
            layer: layer,
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 2),
          ).mirrored(layer: layer, horizontally: false);
          final actual = [selection.area, pixelRows(layer)];
          final expected = [
            const PixelRectangle(left: 0, top: 0, width: 1, height: 2),
            [
              [cyan, green],
              [red, magenta],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
