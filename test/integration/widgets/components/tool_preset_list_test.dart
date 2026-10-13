import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/text_format.dart';
import 'package:paint/editor/tools/tool_kind.dart';
import 'package:paint/editor/tools/tool_preset.dart';
import 'package:paint/widgets/components/paint_split_button.dart';
import 'package:paint/widgets/components/paint_style.dart';
import 'package:paint/widgets/components/tool_preset_list.dart';

void main() {
  const pen = ToolPreset(
    kind: ToolKind.pen,
    color: PixelColor(argb: 0xFFFF0000),
    size: 3,
    tip: BrushTip.circle,
  );
  const eraser = ToolPreset(kind: ToolKind.eraser, size: 2);
  const fill = ToolPreset(
    kind: ToolKind.bucketFill,
    color: PixelColor(argb: 0x400000FF),
  );

  Widget toolPresetList({
    List<ToolPreset> presets = const [pen, eraser, fill],
    int lockedCount = 1,
    ToolPreset? selected,
    ValueChanged<int>? onApply,
    void Function({required int index, required bool locked})? onLockChanged,
  }) => MaterialApp(
    home: Center(
      child: ToolPresetList(
        presets: presets,
        lockedCount: lockedCount,
        selected: selected,
        onApply: onApply ?? (index) {},
        onLockChanged:
            onLockChanged ?? ({required int index, required bool locked}) {},
      ),
    ),
  );

  List<PaintSplitButton> buttons(WidgetTester tester) => tester
      .widgetList<PaintSplitButton>(find.byType(PaintSplitButton))
      .toList();

  group('class ToolPresetList', () {
    group('render', () {
      group('items', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(toolPresetList(presets: const []));
          final actual = buttons(tester).length;
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('texts', (tester) async {
          await tester.pumpWidget(toolPresetList());
          final actual = [
            for (final text in tester.widgetList<Text>(find.byType(Text)))
              text.data,
          ];
          const expected = ['3 px', '2 px'];
          expect(actual, equals(expected));
        });
        testWidgets('icons', (tester) async {
          await tester.pumpWidget(toolPresetList());
          final actual = [
            for (final button in buttons(tester)) button.icon.codePoint,
          ];
          final expected = [
            FontAwesomeIcons.pencil.codePoint,
            FontAwesomeIcons.eraser.codePoint,
            FontAwesomeIcons.fill.codePoint,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('colors', (tester) async {
          await tester.pumpWidget(toolPresetList());
          final actual = [for (final button in buttons(tester)) button.color];
          const expected = [
            Color(0xFFFF0000),
            PaintStyle.eraserColor,
            Color(0xFF0000FF),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('dark colors', (tester) async {
          await tester.pumpWidget(toolPresetList());
          final actual = [
            for (final button in buttons(tester)) button.iconShadows,
          ];
          const expected = [null, null, null];
          expect(actual, equals(expected));
        });
        testWidgets('light colors', (tester) async {
          await tester.pumpWidget(
            toolPresetList(
              presets: const [
                ToolPreset(kind: ToolKind.bucketFill, color: PixelColor.white),
                ToolPreset(
                  kind: ToolKind.bucketFill,
                  color: PixelColor(argb: 0xFFFFFF00),
                ),
                ToolPreset(
                  kind: ToolKind.bucketFill,
                  color: PixelColor(argb: 0xFF808080),
                ),
              ],
            ),
          );
          final actual = [
            for (final button in buttons(tester)) button.iconShadows,
          ];
          const expected = [PaintStyle.iconShadow, PaintStyle.iconShadow, null];
          expect(actual, equals(expected));
        });
        testWidgets('tip', (tester) async {
          await tester.pumpWidget(toolPresetList());
          final actual = tester
              .widgetList<FaIcon>(
                find.byWidgetPredicate(
                  (widget) => widget is FaIcon && widget.size == 10,
                ),
              )
              .map((icon) => icon.icon?.codePoint)
              .toList();
          final expected = [FontAwesomeIcons.circle.codePoint];
          expect(actual, equals(expected));
        });
        testWidgets('filled tip', (tester) async {
          await tester.pumpWidget(
            toolPresetList(
              presets: const [
                ToolPreset(
                  kind: ToolKind.rectangle,
                  color: PixelColor(argb: 0xFFFF0000),
                  secondaryColor: PixelColor(argb: 0x400000FF),
                  size: 3,
                  tip: BrushTip.square,
                ),
              ],
            ),
          );
          final actual = tester
              .widgetList<FaIcon>(
                find.byWidgetPredicate(
                  (widget) => widget is FaIcon && widget.size == 10,
                ),
              )
              .map((icon) => icon.icon?.codePoint)
              .toList();
          final expected = [FontAwesomeIcons.square.codePoint];
          expect(actual, equals(expected));
        });
        testWidgets('fill only color', (tester) async {
          await tester.pumpWidget(
            toolPresetList(
              presets: const [
                ToolPreset(
                  kind: ToolKind.circle,
                  secondaryColor: PixelColor(argb: 0xFF00FF00),
                  size: 3,
                ),
              ],
            ),
          );
          final actual = buttons(tester).single.color;
          const expected = Color(0xFF00FF00);
          expect(actual, equals(expected));
        });
        testWidgets('text size', (tester) async {
          await tester.pumpWidget(
            toolPresetList(
              presets: const [
                ToolPreset(
                  kind: ToolKind.text,
                  color: PixelColor(argb: 0xFFFF0000),
                  textFormat: TextFormat(size: 20),
                ),
              ],
            ),
          );
          final actual = [
            tester.widget<Text>(find.byType(Text)).data,
            buttons(tester).single.icon.codePoint,
            buttons(tester).single.color,
          ];
          final expected = [
            '20 px',
            FontAwesomeIcons.font.codePoint,
            const Color(0xFFFF0000),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('text outline only color', (tester) async {
          await tester.pumpWidget(
            toolPresetList(
              presets: const [
                ToolPreset(
                  kind: ToolKind.text,
                  secondaryColor: PixelColor(argb: 0xFF00FF00),
                  textFormat: TextFormat(filled: false, outlined: true),
                ),
              ],
            ),
          );
          final actual = buttons(tester).single.color;
          const expected = Color(0xFF00FF00);
          expect(actual, equals(expected));
        });
        testWidgets('tooltips', (tester) async {
          await tester.pumpWidget(toolPresetList());
          final actual = [
            for (final button in buttons(tester))
              [button.tooltip, button.shortcut, button.secondaryTooltip],
          ];
          const expected = [
            ['Pen', '1', 'Unlock'],
            ['Eraser', '2', 'Lock'],
            ['Fill', '3', 'Lock'],
          ];
          expect(actual, equals(expected));
        });
      });
      group('lock', () {
        testWidgets('icons', (tester) async {
          await tester.pumpWidget(toolPresetList(lockedCount: 2));
          final actual = [
            for (final button in buttons(tester))
              button.secondaryIcon.codePoint,
          ];
          final expected = [
            FontAwesomeIcons.lock.codePoint,
            FontAwesomeIcons.lock.codePoint,
            FontAwesomeIcons.lockOpen.codePoint,
          ];
          expect(actual, equals(expected));
        });
      });
      group('selection', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(toolPresetList());
          final actual = [
            for (final button in buttons(tester)) button.selected,
          ];
          const expected = [false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('matching', (tester) async {
          await tester.pumpWidget(toolPresetList(selected: eraser));
          final actual = [
            for (final button in buttons(tester)) button.selected,
          ];
          const expected = [false, true, false];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('apply', (tester) async {
          final applied = <int>[];
          await tester.pumpWidget(toolPresetList(onApply: applied.add));
          await tester.tap(find.byTooltip('Eraser (2)'));
          final actual = applied;
          const expected = [1];
          expect(actual, equals(expected));
        });
        testWidgets('lock', (tester) async {
          final changes = <List<Object>>[];
          await tester.pumpWidget(
            toolPresetList(
              onLockChanged: ({required int index, required bool locked}) =>
                  changes.add([index, locked]),
            ),
          );
          await tester.tap(find.byTooltip('Lock').last);
          final actual = changes;
          const expected = [
            [2, true],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('unlock', (tester) async {
          final changes = <List<Object>>[];
          await tester.pumpWidget(
            toolPresetList(
              onLockChanged: ({required int index, required bool locked}) =>
                  changes.add([index, locked]),
            ),
          );
          await tester.tap(find.byTooltip('Unlock'));
          final actual = changes;
          const expected = [
            [0, false],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
