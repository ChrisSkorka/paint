import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/canvas_margin.dart';

void main() {
  group('standalone', () {
    group('function canvasMargin', () {
      group('extents', () {
        test('smaller than visible', () {
          final actual = canvasMargin(
            available: 100,
            extent: 20,
            visible: 30,
            scrollbar: 10,
          );
          const expected = (leading: 70.0, trailing: 80.0);
          expect(actual, equals(expected));
        });
        test('larger than visible', () {
          final actual = canvasMargin(
            available: 100,
            extent: 400,
            visible: 30,
            scrollbar: 10,
          );
          const expected = (leading: 60.0, trailing: 70.0);
          expect(actual, equals(expected));
        });
        test('tiny viewport', () {
          final actual = canvasMargin(
            available: 20,
            extent: 400,
            visible: 30,
            scrollbar: 10,
          );
          const expected = (leading: 0.0, trailing: 0.0);
          expect(actual, equals(expected));
        });
      });
    });
    group('function canvasOffset', () {
      group('positions', () {
        test('within range', () {
          final actual = canvasOffset(
            margin: (leading: 60, trailing: 70),
            available: 100,
            extent: 400,
            position: -18,
          );
          const expected = 78.0;
          expect(actual, equals(expected));
        });
        test('beyond end', () {
          final actual = canvasOffset(
            margin: (leading: 60, trailing: 70),
            available: 100,
            extent: 400,
            position: -1000,
          );
          const expected = 430.0;
          expect(actual, equals(expected));
        });
        test('before start', () {
          final actual = canvasOffset(
            margin: (leading: 60, trailing: 70),
            available: 100,
            extent: 400,
            position: 80,
          );
          const expected = 0.0;
          expect(actual, equals(expected));
        });
        test('content smaller than viewport', () {
          final actual = canvasOffset(
            margin: (leading: 0, trailing: 0),
            available: 100,
            extent: 50,
            position: -10,
          );
          const expected = 0.0;
          expect(actual, equals(expected));
        });
      });
    });
    group('function zoomedCanvasOffset', () {
      group('scales', () {
        test('larger', () {
          final actual = zoomedCanvasOffset(
            available: 100,
            length: 100,
            visible: 30,
            scrollbar: 10,
            offset: 48,
            focus: 50,
            oldScale: 1,
            newScale: 2,
          );
          const expected = 86.0;
          expect(actual, equals(expected));
        });
        test('smaller', () {
          final actual = zoomedCanvasOffset(
            available: 100,
            length: 100,
            visible: 30,
            scrollbar: 10,
            offset: 86,
            focus: 50,
            oldScale: 2,
            newScale: 1,
          );
          const expected = 48.0;
          expect(actual, equals(expected));
        });
      });
    });
    group('function fittingScale', () {
      group('lengths', () {
        test('document', () {
          final actual = fittingScale(
            available: 100,
            length: 20,
            edge: 15,
            scrollbar: 10,
          );
          const expected = 3.0;
          expect(actual, equals(expected));
        });
      });
    });
    group('function centeredCanvasOffset', () {
      group('extents', () {
        test('smaller', () {
          final actual = centeredCanvasOffset(
            available: 100,
            length: 20,
            visible: 30,
            scrollbar: 10,
            scale: 3,
          );
          const expected = 45.0;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
