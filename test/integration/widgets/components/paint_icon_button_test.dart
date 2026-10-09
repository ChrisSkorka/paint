import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';

import '../../../support/hover.dart';

void main() {
  group('class PaintIconButton', () {
    group('render', () {
      group('enabled state', () {
        testWidgets('enabled', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          final actual = (
            tester
                .widget<MouseRegion>(
                  find
                      .ancestor(
                        of: find.byType(HighlightBox),
                        matching: find.byType(MouseRegion),
                      )
                      .first,
                )
                .cursor,
            tester.widget<Opacity>(find.byType(Opacity)).opacity,
          );
          const expected = (SystemMouseCursors.click, 1.0);
          expect(actual, equals(expected));
        });
        testWidgets('disabled', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: null,
                ),
              ),
            ),
          );
          final actual = (
            tester
                .widget<MouseRegion>(
                  find
                      .ancestor(
                        of: find.byType(HighlightBox),
                        matching: find.byType(MouseRegion),
                      )
                      .first,
                )
                .cursor,
            tester.widget<Opacity>(find.byType(Opacity)).opacity,
          );
          const expected = (MouseCursor.defer, 0.4);
          expect(actual, equals(expected));
        });
      });
      group('selection', () {
        testWidgets('not selected', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          final actual = tester
              .widget<HighlightBox>(find.byType(HighlightBox))
              .highlighted;
          const expected = false;
          expect(actual, equals(expected));
        });
        testWidgets('selected', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  selected: true,
                ),
              ),
            ),
          );
          final actual = tester
              .widget<HighlightBox>(find.byType(HighlightBox))
              .highlighted;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('icon', () {
        testWidgets('default color', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          final actual = tester.widget<FaIcon>(find.byType(FaIcon)).color;
          const expected = Color(0xFF444444);
          expect(actual, equals(expected));
        });
        testWidgets('custom color', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                  color: const Color(0xFF112233),
                ),
              ),
            ),
          );
          final actual = tester.widget<FaIcon>(find.byType(FaIcon)).color;
          const expected = Color(0xFF112233);
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('enabled', (tester) async {
          var pressed = 0;
          void stubOnPressed() => pressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          await tester.tap(find.byType(PaintIconButton));
          final actual = pressed;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
      group('hover', () {
        testWidgets('enter', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PaintIconButton));
          final actual = tester
              .widget<HighlightBox>(find.byType(HighlightBox))
              .highlighted;
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('exit', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: stubOnPressed,
                ),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.byType(PaintIconButton));
          await gesture.moveTo(Offset.zero);
          await tester.pump();
          final actual = tester
              .widget<HighlightBox>(find.byType(HighlightBox))
              .highlighted;
          const expected = false;
          expect(actual, equals(expected));
        });
        testWidgets('while disabled', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: PaintIconButton(
                  icon: FontAwesomeIcons.pencil,
                  tooltip: 'Pen',
                  onPressed: null,
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PaintIconButton));
          final actual = tester
              .widget<HighlightBox>(find.byType(HighlightBox))
              .highlighted;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
