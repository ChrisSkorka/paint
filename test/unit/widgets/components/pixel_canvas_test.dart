import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';

import '../../../support/stub_canvas.dart';

void main() {
  group('class PixelLayersPainter', () {
    group('method paint', () {
      group('layers', () {
        test('none', () {
          const pixelLayersPainter = PixelLayersPainter(layers: [], zoom: 1);
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(2, 2));
          final actual = stubCanvas.drawnRectangles;
          const expected = <(Rect, int)>[];
          expect(actual, equals(expected));
        });
        test('transparent', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              Layer.filled(width: 2, height: 2, color: PixelColor.transparent),
            ],
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(2, 2));
          final actual = stubCanvas.drawnRectangles;
          const expected = <(Rect, int)>[];
          expect(actual, equals(expected));
        });
        test('stacked', () {
          final bottom = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.white,
          );
          final top = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          top.setPixel(
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [bottom, top],
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(2, 1));
          final actual = stubCanvas.drawnRectangles;
          const expected = [
            (Rect.fromLTRB(0, 0, 2, 1), 0xFFFFFFFF),
            (Rect.fromLTRB(1, 0, 2, 1), 0xFF000000),
          ];
          expect(actual, equals(expected));
        });
      });

      group('runs', () {
        test('single pixel', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              Layer.filled(width: 1, height: 1, color: PixelColor.black),
            ],
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(0, 0, 1, 1), 0xFF000000)];
          expect(actual, equals(expected));
        });
        test('different colors', () {
          final layer = Layer.filled(
            width: 3,
            height: 1,
            color: PixelColor.black,
          );
          layer.setPixel(
            point: const PixelPoint(x: 2, y: 0),
            color: const PixelColor(argb: 0x80112233),
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [layer],
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(3, 1));
          final actual = stubCanvas.drawnRectangles;
          const expected = [
            (Rect.fromLTRB(0, 0, 2, 1), 0xFF000000),
            (Rect.fromLTRB(2, 0, 3, 1), 0x80112233),
          ];
          expect(actual, equals(expected));
        });
        test('gap', () {
          final layer = Layer.filled(
            width: 3,
            height: 1,
            color: PixelColor.black,
          );
          layer.setPixel(
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.transparent,
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [layer],
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(3, 1));
          final actual = stubCanvas.drawnRectangles;
          const expected = [
            (Rect.fromLTRB(0, 0, 1, 1), 0xFF000000),
            (Rect.fromLTRB(2, 0, 3, 1), 0xFF000000),
          ];
          expect(actual, equals(expected));
        });
        test('multiple rows', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              Layer.filled(width: 2, height: 2, color: PixelColor.black),
            ],
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(2, 2));
          final actual = stubCanvas.drawnRectangles;
          const expected = [
            (Rect.fromLTRB(0, 0, 2, 1), 0xFF000000),
            (Rect.fromLTRB(0, 1, 2, 2), 0xFF000000),
          ];
          expect(actual, equals(expected));
        });
      });

      group('zoom', () {
        test('scaled', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: 1, y: 1),
            color: PixelColor.black,
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [layer],
            zoom: 3,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(6, 6));
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(3, 3, 6, 6), 0xFF000000)];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('old delegate', () {
        test('same painter', () {
          const pixelLayersPainter = PixelLayersPainter(layers: [], zoom: 1);
          final actual = pixelLayersPainter.shouldRepaint(
            const PixelLayersPainter(layers: [], zoom: 1),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class SelectionOutlinePainter', () {
    group('method paint', () {
      group('areas', () {
        test('none', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: null,
            zoom: 2,
          );
          final stubCanvas = StubCanvas();
          selectionOutlinePainter.paint(stubCanvas, const Size(4, 4));
          final actual = [stubCanvas.drawnRectangles, stubCanvas.drawnPaths];
          const expected = [<(Rect, int)>[], <(Rect, int)>[]];
          expect(actual, equals(expected));
        });
        test('zoomed', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: PixelRectangle(left: 1, top: 1, width: 5, height: 1),
            zoom: 2,
          );
          final stubCanvas = StubCanvas();
          selectionOutlinePainter.paint(stubCanvas, const Size(12, 4));
          final actual = [stubCanvas.drawnRectangles, stubCanvas.drawnPaths];
          const expected = [
            [(Rect.fromLTRB(2.5, 2.5, 11.5, 3.5), 0xFFFFFFFF)],
            [(Rect.fromLTRB(2.5, 2.5, 11.5, 3.5), 0xFF000000)],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('old delegate', () {
        test('same values', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            zoom: 1,
          );
          final actual = selectionOutlinePainter.shouldRepaint(
            const SelectionOutlinePainter(
              area: PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              zoom: 1,
            ),
          );
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different area', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            zoom: 1,
          );
          final actual = selectionOutlinePainter.shouldRepaint(
            const SelectionOutlinePainter(area: null, zoom: 1),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different zoom', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: null,
            zoom: 1,
          );
          final actual = selectionOutlinePainter.shouldRepaint(
            const SelectionOutlinePainter(area: null, zoom: 2),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
