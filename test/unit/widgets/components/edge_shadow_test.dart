import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/edge_shadow.dart';

import '../../../support/stub_canvas.dart';

void main() {
  group('class EdgeShadowPainter', () {
    group('method paint', () {
      group('sizes', () {
        test('zero', () {
          const edgeShadowPainter = EdgeShadowPainter();
          final stubCanvas = StubCanvas();
          edgeShadowPainter.paint(stubCanvas, Size.zero);
          final actual = [stubCanvas.clippedRectangles, stubCanvas.drawnPaths];
          const expected = [
            [Rect.fromLTRB(0, 0, 0, 0)],
            [(Rect.fromLTRB(-10, -10, 10, 10), 0x1A000000)],
          ];
          expect(actual, equals(expected));
        });
        test('area', () {
          const edgeShadowPainter = EdgeShadowPainter();
          final stubCanvas = StubCanvas();
          edgeShadowPainter.paint(stubCanvas, const Size(100, 50));
          final actual = [stubCanvas.clippedRectangles, stubCanvas.drawnPaths];
          const expected = [
            [Rect.fromLTRB(0, 0, 100, 50)],
            [(Rect.fromLTRB(-10, -10, 110, 60), 0x1A000000)],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('instances', () {
        test('other instance', () {
          const edgeShadowPainter = EdgeShadowPainter();
          const other = EdgeShadowPainter();
          final actual = edgeShadowPainter.shouldRepaint(other);
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
