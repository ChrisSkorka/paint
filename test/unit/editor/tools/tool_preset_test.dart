import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/text_format.dart';
import 'package:paint/editor/tools/tool_kind.dart';
import 'package:paint/editor/tools/tool_preset.dart';

void main() {
  const red = PixelColor(argb: 0xFFFF0000);

  group('class ToolPreset', () {
    group('factory configured', () {
      group('kinds', () {
        test('pen', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.pen,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          expect(actual, equals(expected));
        });
        test('eraser', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.eraser,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.eraser,
            size: 3,
            tip: BrushTip.circle,
          );
          expect(actual, equals(expected));
        });
        test('fill', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.bucketFill,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(kind: ToolKind.bucketFill, color: red);
          expect(actual, equals(expected));
        });
        test('shape', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.rectangle,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.rectangle,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          expect(actual, equals(expected));
        });
        test('circle shape', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.circle,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.circle,
            color: red,
            size: 3,
          );
          expect(actual, equals(expected));
        });
      });
      group('shape style', () {
        test('filled', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.rectangle,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: true,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.rectangle,
            color: red,
            secondaryColor: PixelColor.white,
            size: 3,
            tip: BrushTip.circle,
          );
          expect(actual, equals(expected));
        });
        test('fill only', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.circle,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: false,
            shapeFilled: true,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.circle,
            secondaryColor: PixelColor.white,
            size: 3,
          );
          expect(actual, equals(expected));
        });
        test('neither', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.rectangle,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: false,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.rectangle,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          expect(actual, equals(expected));
        });
        test('fill on line', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.line,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: false,
            shapeFilled: true,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.line,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          expect(actual, equals(expected));
        });
      });
      group('text', () {
        test('filled', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.text,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(bold: true, outlineWidth: 4),
          );
          const expected = ToolPreset(
            kind: ToolKind.text,
            color: red,
            textFormat: TextFormat(bold: true),
          );
          expect(actual, equals(expected));
        });
        test('outlined', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.text,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(outlined: true, outlineWidth: 4),
          );
          const expected = ToolPreset(
            kind: ToolKind.text,
            color: red,
            secondaryColor: PixelColor.white,
            textFormat: TextFormat(outlined: true, outlineWidth: 4),
          );
          expect(actual, equals(expected));
        });
        test('outline only', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.text,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(filled: false, outlined: true),
          );
          const expected = ToolPreset(
            kind: ToolKind.text,
            secondaryColor: PixelColor.white,
            textFormat: TextFormat(filled: false, outlined: true),
          );
          expect(actual, equals(expected));
        });
        test('neither', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.text,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(filled: false),
          );
          const expected = ToolPreset(
            kind: ToolKind.text,
            color: red,
            textFormat: TextFormat(),
          );
          expect(actual, equals(expected));
        });
        test('clamped', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.text,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 3,
            tip: BrushTip.circle,
            textFormat: const TextFormat(
              size: 900,
              outlined: true,
              outlineWidth: 99,
            ),
          );
          const expected = ToolPreset(
            kind: ToolKind.text,
            color: red,
            secondaryColor: PixelColor.white,
            textFormat: TextFormat(
              size: TextFormat.maximumSize,
              outlined: true,
              outlineWidth: TextFormat.maximumOutlineWidth,
            ),
          );
          expect(actual, equals(expected));
        });
      });
      group('size', () {
        test('below minimum', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.eraser,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 0,
            tip: BrushTip.square,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.eraser,
            size: 1,
            tip: BrushTip.square,
          );
          expect(actual, equals(expected));
        });
        test('above maximum', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.eraser,
            color: red,
            secondaryColor: PixelColor.white,
            shapeOutlined: true,
            shapeFilled: false,
            size: 1001,
            tip: BrushTip.square,
            textFormat: const TextFormat(),
          );
          const expected = ToolPreset(
            kind: ToolKind.eraser,
            size: 1000,
            tip: BrushTip.square,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same values', () {
          const toolPreset = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          const other = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          final actual = toolPreset == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        const toolPreset = ToolPreset(
          kind: ToolKind.pen,
          color: red,
          size: 3,
          tip: BrushTip.circle,
        );
        test('kind', () {
          const other = ToolPreset(
            kind: ToolKind.line,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          final actual = toolPreset == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('color', () {
          const other = ToolPreset(
            kind: ToolKind.pen,
            color: PixelColor.black,
            size: 3,
            tip: BrushTip.circle,
          );
          final actual = toolPreset == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('fill color', () {
          const other = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            secondaryColor: PixelColor.white,
            size: 3,
            tip: BrushTip.circle,
          );
          final actual = toolPreset == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('text format', () {
          const other = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            size: 3,
            tip: BrushTip.circle,
            textFormat: TextFormat(),
          );
          final actual = toolPreset == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('size', () {
          const other = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            size: 4,
            tip: BrushTip.circle,
          );
          final actual = toolPreset == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('tip', () {
          const other = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            size: 3,
            tip: BrushTip.square,
          );
          final actual = toolPreset == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          final actual = toolPreset == Object();
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('hashCode', () {
      group('equals', () {
        test('same values', () {
          const toolPreset = ToolPreset(kind: ToolKind.eraser, size: 2);
          const other = ToolPreset(kind: ToolKind.eraser, size: 2);
          final actual = toolPreset.hashCode;
          final expected = other.hashCode;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different size', () {
          const toolPreset = ToolPreset(kind: ToolKind.eraser, size: 2);
          const other = ToolPreset(kind: ToolKind.eraser, size: 3);
          final actual = toolPreset.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('toString', () {
      group('values', () {
        test('all properties', () {
          const toolPreset = ToolPreset(
            kind: ToolKind.pen,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          final actual = toolPreset.toString();
          const expected =
              'ToolPreset(pen, PixelColor(0xffff0000), null, 3, circle, null)';
          expect(actual, equals(expected));
        });
        test('no properties', () {
          const toolPreset = ToolPreset(kind: ToolKind.eraser);
          final actual = toolPreset.toString();
          const expected = 'ToolPreset(eraser, null, null, null, null, null)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
