import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_split_button.dart';

import '../../../support/hover.dart';

void main() {
  group('class PaintSplitButton', () {
    group('render', () {
      group('selection', () {
        testWidgets('not selected', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<HighlightBox>(find.byType(HighlightBox))
              .map((highlightBox) => highlightBox.highlighted)
              .toList();
          const expected = [false, false];
          expect(actual, equals(expected));
        });
        testWidgets('selected', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                  selected: true,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<HighlightBox>(find.byType(HighlightBox))
              .map((highlightBox) => highlightBox.highlighted)
              .toList();
          const expected = [true, true];
          expect(actual, equals(expected));
        });
      });
      group('dropdown', () {
        testWidgets('initially closed', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = find.text('dropdown');
          expect(actual, findsNothing);
        });
      });
      group('secondary tooltip', () {
        testWidgets('default', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = [
            for (final tooltip in tester.widgetList<Tooltip>(
              find.byType(Tooltip),
            ))
              tooltip.message,
          ];
          const expected = ['Pen', 'Pen options'];
          expect(actual, equals(expected));
        });
        testWidgets('custom', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.eye,
                  tooltip: 'Hide layer',
                  secondaryTooltip: 'Layer opacity',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = [
            for (final tooltip in tester.widgetList<Tooltip>(
              find.byType(Tooltip),
            ))
              tooltip.message,
          ];
          const expected = ['Hide layer', 'Layer opacity'];
          expect(actual, equals(expected));
        });
      });
      group('secondary icon', () {
        testWidgets('default', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<FaIcon>(find.byType(FaIcon))
              .map((icon) => icon.icon?.codePoint)
              .toList();
          final expected = [
            FontAwesomeIcons.pencil.codePoint,
            FontAwesomeIcons.angleDown.codePoint,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('custom', (tester) async {
          void stubOnPressed() {}
          void stubOnSecondaryPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  secondaryIcon: FontAwesomeIcons.lock,
                  onSecondaryPressed: stubOnSecondaryPressed,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<FaIcon>(find.byType(FaIcon))
              .map((icon) => icon.icon?.codePoint)
              .toList();
          final expected = [
            FontAwesomeIcons.pencil.codePoint,
            FontAwesomeIcons.lock.codePoint,
          ];
          expect(actual, equals(expected));
        });
      });
      group('trailing', () {
        testWidgets('none', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = find.text('3 px').evaluate().length;
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('in primary area', (tester) async {
          var pressed = 0;
          void stubOnPressed() => pressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  trailing: const Text('3 px'),
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('3 px'));
          final actual = pressed;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
      group('secondary visibility', () {
        testWidgets('always', (tester) async {
          void stubOnPressed() {}
          void stubOnSecondaryPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  secondaryIcon: FontAwesomeIcons.lock,
                  secondaryTooltip: 'Lock',
                  onSecondaryPressed: stubOnSecondaryPressed,
                ),
              ),
            ),
          );
          final actual = tester.widget<Opacity>(find.byType(Opacity)).opacity;
          const expected = 1.0;
          expect(actual, equals(expected));
        });
        testWidgets('hover only', (tester) async {
          void stubOnPressed() {}
          void stubOnSecondaryPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  secondaryIcon: FontAwesomeIcons.lock,
                  secondaryTooltip: 'Lock',
                  onSecondaryPressed: stubOnSecondaryPressed,
                  secondaryOnHover: true,
                ),
              ),
            ),
          );
          final actual = tester.widget<Opacity>(find.byType(Opacity)).opacity;
          const expected = 0.0;
          expect(actual, equals(expected));
        });
        testWidgets('hovered', (tester) async {
          void stubOnPressed() {}
          void stubOnSecondaryPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  secondaryIcon: FontAwesomeIcons.lock,
                  secondaryTooltip: 'Lock',
                  onSecondaryPressed: stubOnSecondaryPressed,
                  secondaryOnHover: true,
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byTooltip('Pen'));
          final actual = tester.widget<Opacity>(find.byType(Opacity)).opacity;
          const expected = 1.0;
          expect(actual, equals(expected));
        });
      });
      group('icon shadows', () {
        testWidgets('none', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<FaIcon>(find.byType(FaIcon))
              .first
              .shadows;
          const expected = null;
          expect(actual, equals(expected));
        });
        testWidgets('custom', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                  iconShadows: const [Shadow(blurRadius: 2)],
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<FaIcon>(find.byType(FaIcon))
              .first
              .shadows;
          const expected = [Shadow(blurRadius: 2)];
          expect(actual, equals(expected));
        });
      });
      group('shortcut', () {
        testWidgets('with shortcut', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  shortcut: 'P',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final actual = [
            for (final tooltip in tester.widgetList<Tooltip>(
              find.byType(Tooltip),
            ))
              tooltip.message,
          ];
          const expected = ['Pen (P)', 'Pen options'];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('main button', (tester) async {
          var pressed = 0;
          void stubOnPressed() => pressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Pen'));
          final actual = pressed;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('options button', (tester) async {
          var pressed = 0;
          void stubOnPressed() => pressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Pen options'));
          await tester.pumpAndSettle();
          final actual = pressed;
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
      group('secondary action', () {
        testWidgets('pressed', (tester) async {
          var pressed = 0;
          var secondaryPressed = 0;
          void stubOnPressed() => pressed++;
          void stubOnSecondaryPressed() => secondaryPressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  secondaryTooltip: 'Lock',
                  onSecondaryPressed: stubOnSecondaryPressed,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Lock'));
          await tester.pumpAndSettle();
          final actual = [pressed, secondaryPressed];
          const expected = [0, 1];
          expect(actual, equals(expected));
        });
        testWidgets('no action', (tester) async {
          var pressed = 0;
          void stubOnPressed() => pressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Pen options'));
          await tester.pumpAndSettle();
          final actual = [pressed, find.byType(MenuAnchor).evaluate().length];
          const expected = [0, 0];
          expect(actual, equals(expected));
        });
      });
      group('dropdown', () {
        testWidgets('open', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Pen options'));
          await tester.pumpAndSettle();
          final actual = find.text('dropdown');
          expect(actual, findsOneWidget);
        });
        testWidgets('open and close', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Pen options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Pen options'));
          await tester.pumpAndSettle();
          final actual = find.text('dropdown');
          expect(actual, findsNothing);
        });
      });
      group('hover', () {
        testWidgets('main button', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byTooltip('Pen'));
          final actual = tester
              .widgetList<HighlightBox>(find.byType(HighlightBox))
              .map((highlightBox) => highlightBox.highlighted)
              .toList();
          const expected = [true, true];
          expect(actual, equals(expected));
        });
        testWidgets('options button', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byTooltip('Pen options'));
          final actual = tester
              .widgetList<HighlightBox>(find.byType(HighlightBox))
              .map((highlightBox) => highlightBox.highlighted)
              .toList();
          const expected = [true, true];
          expect(actual, equals(expected));
        });
        testWidgets('exit', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintSplitButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  dropdown: const Text('dropdown'),
                ),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.byTooltip('Pen'));
          await gesture.moveTo(Offset.zero);
          await tester.pump();
          final actual = tester
              .widgetList<HighlightBox>(find.byType(HighlightBox))
              .map((highlightBox) => highlightBox.highlighted)
              .toList();
          const expected = [false, false];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
