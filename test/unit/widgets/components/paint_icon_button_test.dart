import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_style.dart';

void main() {
  group('class HighlightBox', () {
    group('render', () {
      group('highlight', () {
        testWidgets('highlighted', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: HighlightBox(highlighted: true, child: Text('child')),
            ),
          );
          final actual = tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .decoration;
          final expected = BoxDecoration(
            color: PaintStyle.hoverBackground,
            borderRadius: PaintStyle.radius,
            border: Border.all(color: PaintStyle.hoverBorder),
          );
          expect(actual, equals(expected));
        });
        testWidgets('not highlighted', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: HighlightBox(highlighted: false, child: Text('child')),
            ),
          );
          final actual = tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .decoration;
          final expected = BoxDecoration(
            color: Colors.transparent,
            borderRadius: PaintStyle.radius,
            border: Border.all(color: Colors.transparent),
          );
          expect(actual, equals(expected));
        });
      });
      group('shape', () {
        testWidgets('default padding', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: HighlightBox(highlighted: false, child: Text('child')),
            ),
          );
          final actual = tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .padding;
          const expected = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
          expect(actual, equals(expected));
        });
        testWidgets('custom radius and padding', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: HighlightBox(
                highlighted: false,
                borderRadius: BorderRadius.zero,
                padding: EdgeInsets.all(1),
                child: Text('child'),
              ),
            ),
          );
          final animatedContainer = tester.widget<AnimatedContainer>(
            find.byType(AnimatedContainer),
          );
          final actual = [
            animatedContainer.padding,
            (animatedContainer.decoration! as BoxDecoration).borderRadius,
          ];
          const expected = [EdgeInsets.all(1), BorderRadius.zero];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
