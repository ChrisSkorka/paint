import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/chess_grid.dart';

import '../../../support/image_probes.dart';
import '../../../support/stub_canvas.dart';

void main() {
  group('class ChessGridPainter', () {
    group('method paint', () {
      group('sizes', () {
        test('zero', () {
          const chessGridPainter = ChessGridPainter();
          final stubCanvas = StubCanvas();
          chessGridPainter.paint(stubCanvas, Size.zero);
          final actual = [stubCanvas.drawnRectangles, stubCanvas.drawnShaders];
          final expected = [
            [(Rect.zero, 0xFF000000)],
            [ChessGridPainter.shader],
          ];
          expect(actual, equals(expected));
        });
        test('smaller than a cell', () {
          const chessGridPainter = ChessGridPainter();
          final stubCanvas = StubCanvas();
          chessGridPainter.paint(stubCanvas, const Size(4, 4));
          final actual = [stubCanvas.drawnRectangles, stubCanvas.drawnShaders];
          final expected = [
            [(const Rect.fromLTRB(0, 0, 4, 4), 0xFF000000)],
            [ChessGridPainter.shader],
          ];
          expect(actual, equals(expected));
        });
        test('partial cells', () {
          const chessGridPainter = ChessGridPainter();
          final stubCanvas = StubCanvas();
          chessGridPainter.paint(stubCanvas, const Size(20, 10));
          final actual = [stubCanvas.drawnRectangles, stubCanvas.drawnShaders];
          final expected = [
            [(const Rect.fromLTRB(0, 0, 20, 10), 0xFF000000)],
            [ChessGridPainter.shader],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter pattern', () {
      group('cells', () {
        test('checkered cells', () async {
          const light = 0xFFFFFFFF;
          const dark = 0xFFDDDDDD;
          final actual = await imageRows(ChessGridPainter.pattern);
          const expected = [
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
            [
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              light,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
              dark,
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('old delegate', () {
        test('same painter', () {
          const chessGridPainter = ChessGridPainter();
          final actual = chessGridPainter.shouldRepaint(
            const ChessGridPainter(),
          );
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
