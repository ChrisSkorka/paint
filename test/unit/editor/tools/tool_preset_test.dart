import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/tools/brush_tip.dart';
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
            size: 3,
            tip: BrushTip.circle,
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
            size: 3,
            tip: BrushTip.circle,
          );
          const expected = ToolPreset(kind: ToolKind.eraser, size: 3);
          expect(actual, equals(expected));
        });
        test('fill', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.bucketFill,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          const expected = ToolPreset(kind: ToolKind.bucketFill, color: red);
          expect(actual, equals(expected));
        });
        test('shape', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.rectangle,
            color: red,
            size: 3,
            tip: BrushTip.circle,
          );
          const expected = ToolPreset(
            kind: ToolKind.rectangle,
            color: red,
            size: 3,
          );
          expect(actual, equals(expected));
        });
      });
      group('size', () {
        test('below minimum', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.eraser,
            color: red,
            size: 0,
            tip: BrushTip.square,
          );
          const expected = ToolPreset(kind: ToolKind.eraser, size: 1);
          expect(actual, equals(expected));
        });
        test('above maximum', () {
          final actual = ToolPreset.configured(
            kind: ToolKind.eraser,
            color: red,
            size: 65,
            tip: BrushTip.square,
          );
          const expected = ToolPreset(kind: ToolKind.eraser, size: 64);
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
          const expected = 'ToolPreset(pen, PixelColor(0xffff0000), 3, circle)';
          expect(actual, equals(expected));
        });
        test('no properties', () {
          const toolPreset = ToolPreset(kind: ToolKind.eraser);
          final actual = toolPreset.toString();
          const expected = 'ToolPreset(eraser, null, null, null)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
