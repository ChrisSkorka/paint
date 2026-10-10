import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';

void main() {
  group('class PixelRectangle', () {
    group('factory fromEdges', () {
      group('edge order', () {
        test('positive area', () {
          final actual = PixelRectangle.fromEdges(
            left: 1,
            top: 2,
            right: 4,
            bottom: 6,
          );
          const expected = PixelRectangle(left: 1, top: 2, width: 3, height: 4);
          expect(actual, equals(expected));
        });
        test('zero area', () {
          final actual = PixelRectangle.fromEdges(
            left: 1,
            top: 1,
            right: 1,
            bottom: 1,
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 0, height: 0);
          expect(actual, equals(expected));
        });
        test('inverted edges', () {
          final actual = PixelRectangle.fromEdges(
            left: 4,
            top: 6,
            right: 1,
            bottom: 2,
          );
          const expected = PixelRectangle(
            left: 4,
            top: 6,
            width: -3,
            height: -4,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('factory spanning', () {
      group('corners', () {
        test('forward', () {
          final actual = PixelRectangle.spanning(
            from: const PixelPoint(x: 1, y: 2),
            to: const PixelPoint(x: 3, y: 5),
          );
          const expected = PixelRectangle(left: 1, top: 2, width: 3, height: 4);
          expect(actual, equals(expected));
        });
        test('reversed', () {
          final actual = PixelRectangle.spanning(
            from: const PixelPoint(x: 3, y: 5),
            to: const PixelPoint(x: 1, y: 2),
          );
          const expected = PixelRectangle(left: 1, top: 2, width: 3, height: 4);
          expect(actual, equals(expected));
        });
        test('same point', () {
          final actual = PixelRectangle.spanning(
            from: const PixelPoint(x: 1, y: 1),
            to: const PixelPoint(x: 1, y: 1),
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 1, height: 1);
          expect(actual, equals(expected));
        });
      });
    });

    group('getter isEmpty', () {
      group('not empty', () {
        test('positive size', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
          );
          final actual = pixelRectangle.isEmpty;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
      group('empty', () {
        test('zero width', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 0,
            height: 1,
          );
          final actual = pixelRectangle.isEmpty;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('zero height', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 1,
            height: 0,
          );
          final actual = pixelRectangle.isEmpty;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('negative width', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: -1,
            height: 1,
          );
          final actual = pixelRectangle.isEmpty;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('negative height', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 1,
            height: -1,
          );
          final actual = pixelRectangle.isEmpty;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('method contains', () {
      group('inside', () {
        test('interior', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 3,
            height: 3,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 2, y: 2));
          const expected = true;
          expect(actual, equals(expected));
        });
        test('top left corner', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 1, y: 1));
          const expected = true;
          expect(actual, equals(expected));
        });
        test('bottom right corner', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 2, y: 2));
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('outside', () {
        test('left of', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 0, y: 1));
          const expected = false;
          expect(actual, equals(expected));
        });
        test('right edge', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 3, y: 1));
          const expected = false;
          expect(actual, equals(expected));
        });
        test('above', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 1, y: 0));
          const expected = false;
          expect(actual, equals(expected));
        });
        test('bottom edge', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 1, y: 3));
          const expected = false;
          expect(actual, equals(expected));
        });
      });
      group('empty rectangle', () {
        test('at origin', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 0,
            height: 0,
          );
          final actual = pixelRectangle.contains(const PixelPoint(x: 1, y: 1));
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method union', () {
      group('empty', () {
        test('both', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 0,
            height: 0,
          );
          final actual = pixelRectangle.union(
            const PixelRectangle(left: 5, top: 5, width: 0, height: 0),
          );
          const expected = PixelRectangle(left: 5, top: 5, width: 0, height: 0);
          expect(actual, equals(expected));
        });
        test('this', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 0,
            height: 0,
          );
          final actual = pixelRectangle.union(
            const PixelRectangle(left: 2, top: 3, width: 4, height: 5),
          );
          const expected = PixelRectangle(left: 2, top: 3, width: 4, height: 5);
          expect(actual, equals(expected));
        });
        test('other', () {
          const pixelRectangle = PixelRectangle(
            left: 2,
            top: 3,
            width: 4,
            height: 5,
          );
          final actual = pixelRectangle.union(
            const PixelRectangle(left: 0, top: 0, width: 0, height: 0),
          );
          const expected = PixelRectangle(left: 2, top: 3, width: 4, height: 5);
          expect(actual, equals(expected));
        });
      });
      group('not empty', () {
        test('overlapping', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.union(
            const PixelRectangle(left: 1, top: 1, width: 2, height: 2),
          );
          const expected = PixelRectangle(left: 0, top: 0, width: 3, height: 3);
          expect(actual, equals(expected));
        });
        test('disjoint', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
          );
          final actual = pixelRectangle.union(
            const PixelRectangle(left: 3, top: 3, width: 1, height: 1),
          );
          const expected = PixelRectangle(left: 0, top: 0, width: 4, height: 4);
          expect(actual, equals(expected));
        });
        test('other contained', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 4,
            height: 4,
          );
          final actual = pixelRectangle.union(
            const PixelRectangle(left: 1, top: 1, width: 1, height: 1),
          );
          const expected = PixelRectangle(left: 0, top: 0, width: 4, height: 4);
          expect(actual, equals(expected));
        });
        test('this contained', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 1,
            height: 1,
          );
          final actual = pixelRectangle.union(
            const PixelRectangle(left: 0, top: 0, width: 4, height: 4),
          );
          const expected = PixelRectangle(left: 0, top: 0, width: 4, height: 4);
          expect(actual, equals(expected));
        });
      });
    });

    group('method intersection', () {
      group('overlapping', () {
        test('partial', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.intersection(
            const PixelRectangle(left: 1, top: 1, width: 2, height: 2),
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 1, height: 1);
          expect(actual, equals(expected));
        });
        test('other contained', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 4,
            height: 4,
          );
          final actual = pixelRectangle.intersection(
            const PixelRectangle(left: 1, top: 1, width: 1, height: 1),
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 1, height: 1);
          expect(actual, equals(expected));
        });
        test('this contained', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 1,
            width: 1,
            height: 1,
          );
          final actual = pixelRectangle.intersection(
            const PixelRectangle(left: 0, top: 0, width: 4, height: 4),
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 1, height: 1);
          expect(actual, equals(expected));
        });
      });
      group('not overlapping', () {
        test('other after', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
          );
          final actual = pixelRectangle.intersection(
            const PixelRectangle(left: 3, top: 3, width: 1, height: 1),
          );
          const expected = PixelRectangle(left: 3, top: 3, width: 0, height: 0);
          expect(actual, equals(expected));
        });
        test('other before', () {
          const pixelRectangle = PixelRectangle(
            left: 3,
            top: 3,
            width: 1,
            height: 1,
          );
          final actual = pixelRectangle.intersection(
            const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          );
          const expected = PixelRectangle(left: 3, top: 3, width: 0, height: 0);
          expect(actual, equals(expected));
        });
        test('touching edges', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
          );
          final actual = pixelRectangle.intersection(
            const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
          );
          const expected = PixelRectangle(left: 1, top: 0, width: 0, height: 1);
          expect(actual, equals(expected));
        });
        test('other empty', () {
          const pixelRectangle = PixelRectangle(
            left: 0,
            top: 0,
            width: 2,
            height: 2,
          );
          final actual = pixelRectangle.intersection(
            const PixelRectangle(left: 1, top: 1, width: 0, height: 0),
          );
          const expected = PixelRectangle(left: 1, top: 1, width: 0, height: 0);
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const other = PixelRectangle(left: 1, top: 2, width: 3, height: 4);
          final actual = pixelRectangle == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different left', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const other = PixelRectangle(left: 0, top: 2, width: 3, height: 4);
          final actual = pixelRectangle == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different top', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const other = PixelRectangle(left: 1, top: 0, width: 3, height: 4);
          final actual = pixelRectangle == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different width', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const other = PixelRectangle(left: 1, top: 2, width: 0, height: 4);
          final actual = pixelRectangle == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different height', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const other = PixelRectangle(left: 1, top: 2, width: 3, height: 0);
          final actual = pixelRectangle == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const Object other = (1, 2, 3, 4);
          final actual = pixelRectangle == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const other = PixelRectangle(left: 1, top: 2, width: 3, height: 4);
          final actual = pixelRectangle.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('reversed fields', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          const other = PixelRectangle(left: 4, top: 3, width: 2, height: 1);
          final actual = pixelRectangle.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('positive', () {
          const pixelRectangle = PixelRectangle(
            left: 1,
            top: 2,
            width: 3,
            height: 4,
          );
          final actual = pixelRectangle.toString();
          const expected = 'PixelRectangle(1, 2, 3, 4)';
          expect(actual, equals(expected));
        });
        test('negative', () {
          const pixelRectangle = PixelRectangle(
            left: -1,
            top: -2,
            width: -3,
            height: -4,
          );
          final actual = pixelRectangle.toString();
          const expected = 'PixelRectangle(-1, -2, -3, -4)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
