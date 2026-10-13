import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/tools/text_format.dart';

void main() {
  const red = 0xffff0000;

  group('class TextFormat', () {
    group('method style', () {
      group('flags', () {
        test('plain', () {
          const textFormat = TextFormat(size: 10);
          final actual = textFormat.style(
            scale: 1,
            color: const PixelColor(argb: red),
          );
          final expected = TextStyle(
            color: const Color(red),
            fontFamily: TextFormat.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            decoration: TextDecoration.combine([]),
            decorationColor: const Color(red),
            height: TextFormat.lineHeight,
            letterSpacing: 0,
            leadingDistribution: TextLeadingDistribution.even,
          );
          expect(actual, equals(expected));
        });
        test('bold', () {
          const textFormat = TextFormat(size: 10, bold: true);
          final actual = textFormat
              .style(scale: 1, color: const PixelColor(argb: red))
              .fontWeight;
          const expected = FontWeight.bold;
          expect(actual, equals(expected));
        });
        test('italic', () {
          const textFormat = TextFormat(size: 10, italic: true);
          final actual = textFormat
              .style(scale: 1, color: const PixelColor(argb: red))
              .fontStyle;
          const expected = FontStyle.italic;
          expect(actual, equals(expected));
        });
        test('underline', () {
          const textFormat = TextFormat(size: 10, underline: true);
          final actual = textFormat
              .style(scale: 1, color: const PixelColor(argb: red))
              .decoration;
          final expected = TextDecoration.combine([TextDecoration.underline]);
          expect(actual, equals(expected));
        });
        test('strikethrough', () {
          const textFormat = TextFormat(size: 10, strikethrough: true);
          final actual = textFormat
              .style(scale: 1, color: const PixelColor(argb: red))
              .decoration;
          final expected = TextDecoration.combine([TextDecoration.lineThrough]);
          expect(actual, equals(expected));
        });
        test('underline and strikethrough', () {
          const textFormat = TextFormat(
            size: 10,
            underline: true,
            strikethrough: true,
          );
          final actual = textFormat
              .style(scale: 1, color: const PixelColor(argb: red))
              .decoration;
          final expected = TextDecoration.combine([
            TextDecoration.underline,
            TextDecoration.lineThrough,
          ]);
          expect(actual, equals(expected));
        });
      });
      group('scale', () {
        test('zoomed', () {
          const textFormat = TextFormat(size: 10);
          final actual = textFormat
              .style(scale: 4, color: const PixelColor(argb: red))
              .fontSize;
          const expected = 40.0;
          expect(actual, equals(expected));
        });
      });
    });

    group('method outlineStyle', () {
      group('paint', () {
        test('stroke', () {
          const textFormat = TextFormat(
            size: 10,
            outlined: true,
            outlineWidth: 3,
          );
          final style = textFormat.outlineStyle(
            scale: 2,
            color: const PixelColor(argb: red),
          );
          final foreground = style.foreground!;
          final actual = [
            style.color,
            style.decorationColor,
            style.fontSize,
            foreground.color,
            foreground.style,
            foreground.strokeWidth,
            foreground.strokeJoin,
          ];
          const expected = [
            null,
            Color(red),
            20.0,
            Color(red),
            PaintingStyle.stroke,
            12.0,
            StrokeJoin.round,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter padding', () {
      group('outline', () {
        test('outlined', () {
          const textFormat = TextFormat(outlined: true, outlineWidth: 3);
          final actual = textFormat.padding;
          const expected = 3;
          expect(actual, equals(expected));
        });
        test('not outlined', () {
          const textFormat = TextFormat(outlineWidth: 3);
          final actual = textFormat.padding;
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
    });

    group('method copyWith', () {
      group('fields', () {
        test('none', () {
          const textFormat = TextFormat(size: 10, bold: true);
          final actual = textFormat.copyWith();
          const expected = TextFormat(size: 10, bold: true);
          expect(actual, equals(expected));
        });
        test('all', () {
          const textFormat = TextFormat();
          final actual = textFormat.copyWith(
            size: 20,
            bold: true,
            italic: true,
            underline: true,
            strikethrough: true,
            filled: false,
            outlined: true,
            outlineWidth: 4,
          );
          const expected = TextFormat(
            size: 20,
            bold: true,
            italic: true,
            underline: true,
            strikethrough: true,
            filled: false,
            outlined: true,
            outlineWidth: 4,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          const textFormat = TextFormat(size: 10, italic: true);
          const other = TextFormat(size: 10, italic: true);
          final actual = textFormat == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different size', () {
          const textFormat = TextFormat(size: 10);
          const other = TextFormat(size: 11);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different bold', () {
          const textFormat = TextFormat();
          const other = TextFormat(bold: true);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different italic', () {
          const textFormat = TextFormat();
          const other = TextFormat(italic: true);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different underline', () {
          const textFormat = TextFormat();
          const other = TextFormat(underline: true);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different strikethrough', () {
          const textFormat = TextFormat();
          const other = TextFormat(strikethrough: true);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different filled', () {
          const textFormat = TextFormat();
          const other = TextFormat(filled: false);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different outlined', () {
          const textFormat = TextFormat();
          const other = TextFormat(outlined: true);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different outline width', () {
          const textFormat = TextFormat();
          const other = TextFormat(outlineWidth: 2);
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          const textFormat = TextFormat();
          const Object other = 'TextFormat';
          final actual = textFormat == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          const textFormat = TextFormat(size: 10, underline: true);
          const other = TextFormat(size: 10, underline: true);
          final actual = textFormat.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different fields', () {
          const textFormat = TextFormat(size: 10);
          const other = TextFormat(size: 10, strikethrough: true);
          final actual = textFormat.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('all', () {
          const textFormat = TextFormat(size: 10, bold: true);
          final actual = textFormat.toString();
          const expected =
              'TextFormat(size: 10, bold: true, italic: false, underline: false, strikethrough: false, filled: true, outlined: false, outline width: 1)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
