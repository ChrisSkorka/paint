import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';

void main() {
  group('class Layer', () {
    group('factory filled', () {
      group('colors', () {
        test('transparent', () {
          final actual = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
        test('opaque', () {
          final actual = Layer.filled(
            width: 2,
            height: 1,
            color: const PixelColor(argb: 0xff112233),
          );
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([
              0x11,
              0x22,
              0x33,
              0xff,
              0x11,
              0x22,
              0x33,
              0xff,
            ]),
          );
          expect(actual, equals(expected));
        });
        test('translucent', () {
          final actual = Layer.filled(
            width: 1,
            height: 1,
            color: const PixelColor(argb: 0x80112233),
          );
          final expected = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([0x11, 0x22, 0x33, 0x80]),
          );
          expect(actual, equals(expected));
        });
      });
      group('sizes', () {
        test('multiple rows', () {
          final actual = Layer.filled(
            width: 1,
            height: 2,
            color: const PixelColor(argb: 0xff112233),
          );
          final expected = Layer(
            width: 1,
            height: 2,
            rgba: Uint8List.fromList([
              0x11,
              0x22,
              0x33,
              0xff,
              0x11,
              0x22,
              0x33,
              0xff,
            ]),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('getter bounds', () {
      group('sizes', () {
        test('rectangle', () {
          final layer = Layer.filled(
            width: 3,
            height: 2,
            color: PixelColor.transparent,
          );
          final actual = layer.bounds;
          const expected = PixelRectangle(left: 0, top: 0, width: 3, height: 2);
          expect(actual, equals(expected));
        });
      });
    });

    group('method contains', () {
      group('inside', () {
        test('first pixel', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final actual = layer.contains(const PixelPoint(x: 0, y: 0));
          const expected = true;
          expect(actual, equals(expected));
        });
        test('last pixel', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final actual = layer.contains(const PixelPoint(x: 1, y: 1));
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('outside', () {
        test('left of', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final actual = layer.contains(const PixelPoint(x: -1, y: 0));
          const expected = false;
          expect(actual, equals(expected));
        });
        test('right of', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final actual = layer.contains(const PixelPoint(x: 2, y: 0));
          const expected = false;
          expect(actual, equals(expected));
        });
        test('above', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final actual = layer.contains(const PixelPoint(x: 0, y: -1));
          const expected = false;
          expect(actual, equals(expected));
        });
        test('below', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          final actual = layer.contains(const PixelPoint(x: 0, y: 2));
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method getPixel', () {
      group('positions', () {
        test('first pixel', () {
          final layer = Layer(
            width: 2,
            height: 2,
            rgba: Uint8List.fromList([
              1, 2, 3, 4, //
              5, 6, 7, 8,
              9, 10, 11, 12,
              13, 14, 15, 16,
            ]),
          );
          final actual = layer.getPixel(const PixelPoint(x: 0, y: 0));
          const expected = PixelColor(argb: 0x04010203);
          expect(actual, equals(expected));
        });
        test('same row', () {
          final layer = Layer(
            width: 2,
            height: 2,
            rgba: Uint8List.fromList([
              1, 2, 3, 4, //
              5, 6, 7, 8,
              9, 10, 11, 12,
              13, 14, 15, 16,
            ]),
          );
          final actual = layer.getPixel(const PixelPoint(x: 1, y: 0));
          const expected = PixelColor(argb: 0x08050607);
          expect(actual, equals(expected));
        });
        test('next row', () {
          final layer = Layer(
            width: 2,
            height: 2,
            rgba: Uint8List.fromList([
              1, 2, 3, 4, //
              5, 6, 7, 8,
              9, 10, 11, 12,
              13, 14, 15, 16,
            ]),
          );
          final actual = layer.getPixel(const PixelPoint(x: 0, y: 1));
          const expected = PixelColor(argb: 0x0c090a0b);
          expect(actual, equals(expected));
        });
      });
      group('after setPixel', () {
        test('set pixel', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: 1, y: 0),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer.getPixel(const PixelPoint(x: 1, y: 0));
          const expected = PixelColor(argb: 0xff445566);
          expect(actual, equals(expected));
        });
      });
    });

    group('method setPixel', () {
      group('inside', () {
        test('same row', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: 1, y: 0),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0x44, 0x55, 0x66, 0xff]),
          );
          expect(actual, equals(expected));
        });
        test('next row', () {
          final layer = Layer.filled(
            width: 1,
            height: 2,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: 0, y: 1),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 1,
            height: 2,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0x44, 0x55, 0x66, 0xff]),
          );
          expect(actual, equals(expected));
        });
      });
      group('outside', () {
        test('left of', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: -1, y: 0),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
        test('right of', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: 2, y: 0),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
        test('above', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: 0, y: -1),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
        test('below', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.setPixel(
            point: const PixelPoint(x: 0, y: 1),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('method fillRectangle', () {
      group('inside', () {
        test('single pixel', () {
          final layer = Layer.filled(
            width: 3,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: 1,
              top: 0,
              width: 1,
              height: 1,
            ),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 3,
            height: 1,
            rgba: Uint8List.fromList([
              0, 0, 0, 0, //
              0x44, 0x55, 0x66, 0xff,
              0, 0, 0, 0,
            ]),
          );
          expect(actual, equals(expected));
        });
        test('multiple rows', () {
          final layer = Layer.filled(
            width: 2,
            height: 3,
            color: PixelColor.transparent,
          );
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: 1,
              top: 1,
              width: 1,
              height: 2,
            ),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 3,
            rgba: Uint8List.fromList([
              0, 0, 0, 0, 0, 0, 0, 0, //
              0, 0, 0, 0, 0x44, 0x55, 0x66, 0xff,
              0, 0, 0, 0, 0x44, 0x55, 0x66, 0xff,
            ]),
          );
          expect(actual, equals(expected));
        });
      });
      group('clipped', () {
        test('partially outside', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: -1,
              top: -1,
              width: 2,
              height: 2,
            ),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0x44, 0x55, 0x66, 0xff, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
        test('covering', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: -5,
              top: -5,
              width: 10,
              height: 10,
            ),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([
              0x44, 0x55, 0x66, 0xff, //
              0x44, 0x55, 0x66, 0xff,
            ]),
          );
          expect(actual, equals(expected));
        });
        test('fully outside', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: 5,
              top: 5,
              width: 1,
              height: 1,
            ),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
      });
      group('empty rectangle', () {
        test('zero width', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: 0,
              top: 0,
              width: 0,
              height: 1,
            ),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
        test('zero height', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: 0,
              top: 0,
              width: 1,
              height: 0,
            ),
            color: const PixelColor(argb: 0xff445566),
          );
          final actual = layer;
          final expected = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final layer = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final actual = layer == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different pixels', () {
          final layer = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([4, 3, 2, 1]),
          );
          final actual = layer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different width', () {
          final layer = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          final other = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          final actual = layer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different height', () {
          final layer = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          final other = Layer(
            width: 2,
            height: 2,
            rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          );
          final actual = layer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          final layer = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final Object other = Uint8List.fromList([1, 2, 3, 4]);
          final actual = layer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final layer = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final actual = layer.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different pixels', () {
          final layer = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([4, 3, 2, 1]),
          );
          final actual = layer.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('sizes', () {
        test('rectangle', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          final actual = layer.toString();
          const expected = 'Layer(2, 1)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
