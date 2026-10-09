import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_style.dart';
import 'package:paint/widgets/components/swatch_grid.dart';

import '../../../support/hover.dart';
import '../../../support/swatch_probes.dart';

void main() {
  group('class Swatch', () {
    group('render', () {
      group('appearance', () {
        testWidgets('color and radius', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: Swatch(
                  color: const Color(0xFF112233),
                  onSelect: stubOnSelect,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
            ),
          );
          final actual = tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(Swatch),
                  matching: find.byType(Container),
                ),
              )
              .decoration;
          const expected = BoxDecoration(
            color: Color(0xFF112233),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('select', (tester) async {
          final selected = <Color>[];
          void stubOnSelect(Color color) => selected.add(color);
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: Swatch(
                  color: const Color(0xFF112233),
                  onSelect: stubOnSelect,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          );
          await tester.tap(find.byType(Swatch));
          final actual = selected;
          const expected = [Color(0xFF112233)];
          expect(actual, equals(expected));
        });
      });
      group('hover', () {
        testWidgets('enter', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: Swatch(
                  color: const Color(0xFF112233),
                  onSelect: stubOnSelect,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(Swatch));
          final actual = find.byWidgetPredicate(isHoverSwatch);
          expect(actual, findsOneWidget);
        });
        testWidgets('exit', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: Swatch(
                  color: const Color(0xFF112233),
                  onSelect: stubOnSelect,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.byType(Swatch));
          await gesture.moveTo(Offset.zero);
          await tester.pump();
          final actual = find.byWidgetPredicate(isHoverSwatch);
          expect(actual, findsNothing);
        });
      });
    });

    group('lifecycle', () {
      group('dispose', () {
        testWidgets('while hovered', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: Swatch(
                  color: const Color(0xFF112233),
                  onSelect: stubOnSelect,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(Swatch));
          await tester.pumpWidget(const MaterialApp(home: SizedBox()));
          await tester.pump();
          final actual = find.byWidgetPredicate(isHoverSwatch);
          expect(actual, findsNothing);
        });
      });
    });
  });

  group('class ColorWell', () {
    group('render', () {
      group('selection', () {
        testWidgets('selected', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: ColorWell(
                  color: Color(0xFF112233),
                  tooltip: 'Primary color',
                  selected: true,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byType(ColorWell),
                  matching: find.byType(Container),
                ),
              )
              .map((container) => container.decoration)
              .toList();
          final expected = [
            BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              border: Border.all(color: PaintStyle.inputFocusBorder),
            ),
            BoxDecoration(
              color: const Color(0xFF112233),
              borderRadius: PaintStyle.radius,
              border: Border.all(color: Colors.black),
            ),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('not selected', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: ColorWell(
                  color: Color(0xFF112233),
                  tooltip: 'Primary color',
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byType(ColorWell),
                  matching: find.byType(Container),
                ),
              )
              .map((container) => container.decoration)
              .toList();
          final expected = [
            BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              border: Border.all(color: Colors.transparent),
            ),
            BoxDecoration(
              color: const Color(0xFF112233),
              borderRadius: PaintStyle.radius,
              border: Border.all(color: Colors.black),
            ),
          ];
          expect(actual, equals(expected));
        });
      });
      group('tooltip', () {
        testWidgets('message', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: ColorWell(
                  color: Color(0xFF112233),
                  tooltip: 'Primary color',
                ),
              ),
            ),
          );
          final actual = find.byTooltip('Primary color');
          expect(actual, findsOneWidget);
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('with callback', (tester) async {
          var pressed = 0;
          void stubOnPressed() => pressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: ColorWell(
                  color: const Color(0xFF112233),
                  tooltip: 'Primary color',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          await tester.tap(find.byType(ColorWell));
          final actual = pressed;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('without callback', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: ColorWell(
                  color: Color(0xFF112233),
                  tooltip: 'Primary color',
                ),
              ),
            ),
          );
          await tester.tap(find.byType(ColorWell));
          final actual = tester.takeException();
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
