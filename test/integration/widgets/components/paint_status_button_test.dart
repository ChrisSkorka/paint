import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_status_button.dart';

import '../../../support/hover.dart';

void main() {
  group('class PaintStatusButton', () {
    group('render', () {
      group('defaults', () {
        testWidgets('content', (tester) async {
          void stubOnPressed() {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintStatusButton(
                  tooltip: 'Resize image',
                  onPressed: stubOnPressed,
                  child: const Text('2 × 1'),
                ),
              ),
            ),
          );
          final highlightBox = tester.widget<HighlightBox>(
            find.byType(HighlightBox),
          );
          final actual = [
            find.text('2 × 1').evaluate().length,
            find.byTooltip('Resize image').evaluate().length,
            highlightBox.highlighted,
            highlightBox.padding,
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
          ];
          const expected = [
            1,
            1,
            false,
            EdgeInsets.symmetric(horizontal: 4),
            SystemMouseCursors.click,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('pressed', (tester) async {
          var pressed = 0;
          void stubOnPressed() => pressed++;
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: PaintStatusButton(
                  tooltip: 'Resize image',
                  onPressed: stubOnPressed,
                  child: const Text('2 × 1'),
                ),
              ),
            ),
          );
          await tester.tap(find.byType(PaintStatusButton));
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
                child: PaintStatusButton(
                  tooltip: 'Resize image',
                  onPressed: stubOnPressed,
                  child: const Text('2 × 1'),
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PaintStatusButton));
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
                child: PaintStatusButton(
                  tooltip: 'Resize image',
                  onPressed: stubOnPressed,
                  child: const Text('2 × 1'),
                ),
              ),
            ),
          );
          final gesture = await hoverOver(
            tester,
            find.byType(PaintStatusButton),
          );
          await gesture.moveTo(Offset.zero);
          await tester.pump();
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
