import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';

void main() {
  group('class PixelColor', () {
    group('factory fromChannels', () {
      group('alpha', () {
        test('explicit', () {
          final actual = PixelColor.fromChannels(
            red: 0x12,
            green: 0x34,
            blue: 0x56,
            alpha: 0x78,
          );
          const expected = PixelColor(argb: 0x78123456);
          expect(actual, equals(expected));
        });
        test('default', () {
          final actual = PixelColor.fromChannels(red: 1, green: 2, blue: 3);
          const expected = PixelColor(argb: 0xff010203);
          expect(actual, equals(expected));
        });
        test('zero', () {
          final actual = PixelColor.fromChannels(
            red: 1,
            green: 2,
            blue: 3,
            alpha: 0,
          );
          const expected = PixelColor(argb: 0x00010203);
          expect(actual, equals(expected));
        });
      });
      group('out of range channels', () {
        test('above maximum', () {
          final actual = PixelColor.fromChannels(
            red: 0x1ff,
            green: 0x100,
            blue: 0x1ff,
            alpha: 0x1ff,
          );
          const expected = PixelColor(argb: 0xffff00ff);
          expect(actual, equals(expected));
        });
        test('negative', () {
          final actual = PixelColor.fromChannels(
            red: -1,
            green: -2,
            blue: -1,
            alpha: -1,
          );
          const expected = PixelColor(argb: 0xfffffeff);
          expect(actual, equals(expected));
        });
      });
    });

    group('getter alpha', () {
      group('values', () {
        test('zero', () {
          const pixelColor = PixelColor(argb: 0x00ffffff);
          final actual = pixelColor.alpha;
          const expected = 0;
          expect(actual, equals(expected));
        });
        test('maximum', () {
          const pixelColor = PixelColor(argb: 0xff000000);
          final actual = pixelColor.alpha;
          const expected = 0xff;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter red', () {
      group('values', () {
        test('zero', () {
          const pixelColor = PixelColor(argb: 0xff00ffff);
          final actual = pixelColor.red;
          const expected = 0;
          expect(actual, equals(expected));
        });
        test('maximum', () {
          const pixelColor = PixelColor(argb: 0x00ff0000);
          final actual = pixelColor.red;
          const expected = 0xff;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter green', () {
      group('values', () {
        test('zero', () {
          const pixelColor = PixelColor(argb: 0xffff00ff);
          final actual = pixelColor.green;
          const expected = 0;
          expect(actual, equals(expected));
        });
        test('maximum', () {
          const pixelColor = PixelColor(argb: 0x0000ff00);
          final actual = pixelColor.green;
          const expected = 0xff;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter blue', () {
      group('values', () {
        test('zero', () {
          const pixelColor = PixelColor(argb: 0xffffff00);
          final actual = pixelColor.blue;
          const expected = 0;
          expect(actual, equals(expected));
        });
        test('maximum', () {
          const pixelColor = PixelColor(argb: 0x000000ff);
          final actual = pixelColor.blue;
          const expected = 0xff;
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same argb', () {
          const pixelColor = PixelColor(argb: 0xff123456);
          const other = PixelColor(argb: 0xff123456);
          final actual = pixelColor == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different argb', () {
          const pixelColor = PixelColor(argb: 0xff123456);
          const other = PixelColor(argb: 0xff654321);
          final actual = pixelColor == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          const pixelColor = PixelColor(argb: 0xff123456);
          const Object other = 0xff123456;
          final actual = pixelColor == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same argb', () {
          const pixelColor = PixelColor(argb: 0xff123456);
          const other = PixelColor(argb: 0xff123456);
          final actual = pixelColor.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different argb', () {
          const pixelColor = PixelColor(argb: 0xff123456);
          const other = PixelColor(argb: 0xff654321);
          final actual = pixelColor.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('hex digits', () {
        test('padded', () {
          const pixelColor = PixelColor(argb: 0xff);
          final actual = pixelColor.toString();
          const expected = 'PixelColor(0x000000ff)';
          expect(actual, equals(expected));
        });
        test('full width', () {
          const pixelColor = PixelColor(argb: 0xff123456);
          final actual = pixelColor.toString();
          const expected = 'PixelColor(0xff123456)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
