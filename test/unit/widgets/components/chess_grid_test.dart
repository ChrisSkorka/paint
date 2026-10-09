import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/chess_grid.dart';

import '../../../support/stub_canvas.dart';

void main() {
  group('class ChessGridPainter', () {
    group('method paint', () {
      group('sizes', () {
        test('zero', () {
          const chessGridPainter = ChessGridPainter();
          final stubCanvas = StubCanvas();
          chessGridPainter.paint(stubCanvas, Size.zero);
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(0, 0, 0, 0), 0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
        test('smaller than a cell', () {
          const chessGridPainter = ChessGridPainter();
          final stubCanvas = StubCanvas();
          chessGridPainter.paint(stubCanvas, const Size(4, 4));
          final actual = stubCanvas.drawnRectangles;
          const expected = [
            (Rect.fromLTRB(0, 0, 4, 4), 0xFFFFFFFF),
            (Rect.fromLTRB(0, 0, 4, 4), 0xFFDDDDDD),
          ];
          expect(actual, equals(expected));
        });
        test('whole cells', () {
          const chessGridPainter = ChessGridPainter();
          final stubCanvas = StubCanvas();
          chessGridPainter.paint(stubCanvas, const Size(16, 16));
          final actual = stubCanvas.drawnRectangles;
          const expected = [
            (Rect.fromLTRB(0, 0, 16, 16), 0xFFFFFFFF),
            (Rect.fromLTRB(0, 0, 8, 8), 0xFFDDDDDD),
            (Rect.fromLTRB(8, 8, 16, 16), 0xFFDDDDDD),
          ];
          expect(actual, equals(expected));
        });
        test('partial cells', () {
          const chessGridPainter = ChessGridPainter();
          final stubCanvas = StubCanvas();
          chessGridPainter.paint(stubCanvas, const Size(20, 10));
          final actual = stubCanvas.drawnRectangles;
          const expected = [
            (Rect.fromLTRB(0, 0, 20, 10), 0xFFFFFFFF),
            (Rect.fromLTRB(0, 0, 8, 8), 0xFFDDDDDD),
            (Rect.fromLTRB(16, 0, 20, 8), 0xFFDDDDDD),
            (Rect.fromLTRB(8, 8, 16, 10), 0xFFDDDDDD),
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
