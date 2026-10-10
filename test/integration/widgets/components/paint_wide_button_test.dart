import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_wide_button.dart';

import '../../../support/hover.dart';

void main() {
  group('class PaintWideButton', () {
    group('render', () {
      group('enabled state', () {
        testWidgets('enabled', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: stubOnPressed,
                  ),
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
            MaterialApp(
              home: Center(
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: null,
                  ),
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

      group('layout', () {
        testWidgets('label left icon right', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: stubOnPressed,
                  ),
                ),
              ),
            ),
          );
          final actual = [
            tester.getSize(find.byType(PaintWideButton)).width,
            tester.getTopLeft(find.text('From file')).dx <
                tester.getTopLeft(find.byType(FaIcon)).dx,
          ];
          const expected = [200.0, true];
          expect(actual, equals(expected));
        });
      });

      group('icon', () {
        testWidgets('default color', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: stubOnPressed,
                  ),
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
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: stubOnPressed,
                    color: const Color(0xFF112233),
                  ),
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
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: stubOnPressed,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byType(PaintWideButton));
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
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: stubOnPressed,
                  ),
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PaintWideButton));
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
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: stubOnPressed,
                  ),
                ),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.byType(PaintWideButton));
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
            MaterialApp(
              home: Center(
                child: SizedBox(
                  width: 200,
                  child: PaintWideButton(
                    label: 'From file',
                    icon: FontAwesomeIcons.folderOpen,
                    onPressed: null,
                  ),
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PaintWideButton));
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
