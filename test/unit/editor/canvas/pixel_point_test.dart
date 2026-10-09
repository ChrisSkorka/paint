import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_point.dart';

void main() {
  group('class PixelPoint', () {
    group('operator ==', () {
      group('equals', () {
        test('same coordinates', () {
          const pixelPoint = PixelPoint(x: 1, y: 2);
          const other = PixelPoint(x: 1, y: 2);
          final actual = pixelPoint == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different x', () {
          const pixelPoint = PixelPoint(x: 1, y: 2);
          const other = PixelPoint(x: 3, y: 2);
          final actual = pixelPoint == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different y', () {
          const pixelPoint = PixelPoint(x: 1, y: 2);
          const other = PixelPoint(x: 1, y: 3);
          final actual = pixelPoint == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          const pixelPoint = PixelPoint(x: 1, y: 2);
          const Object other = (1, 2);
          final actual = pixelPoint == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same coordinates', () {
          const pixelPoint = PixelPoint(x: 1, y: 2);
          const other = PixelPoint(x: 1, y: 2);
          final actual = pixelPoint.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('swapped coordinates', () {
          const pixelPoint = PixelPoint(x: 1, y: 2);
          const other = PixelPoint(x: 2, y: 1);
          final actual = pixelPoint.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('coordinates', () {
        test('positive', () {
          final x = int.parse('1');
          final pixelPoint = PixelPoint(x: x, y: 2);
          final actual = pixelPoint.toString();
          const expected = 'PixelPoint(1, 2)';
          expect(actual, equals(expected));
        });
        test('negative', () {
          const pixelPoint = PixelPoint(x: -1, y: -2);
          final actual = pixelPoint.toString();
          const expected = 'PixelPoint(-1, -2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
