import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_style.dart';
import 'package:paint/widgets/components/side_panel.dart';

void main() {
  group('class SidePanel', () {
    group('render', () {
      group('content', () {
        testWidgets('title and child', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          final actual = [
            find.text('title').evaluate().length,
            find.text('child').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
      });
      group('appearance', () {
        testWidgets('background', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          final actual = tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(SidePanel),
                  matching: find.byType(Container),
                ),
              )
              .color;
          const expected = PaintStyle.barBackground;
          expect(actual, equals(expected));
        });
        testWidgets('width', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Row(
                children: [SidePanel(title: 'title', child: Text('child'))],
              ),
            ),
          );
          final actual = tester.getSize(find.byType(SidePanel)).width;
          const expected = 200.0;
          expect(actual, equals(expected));
        });
        testWidgets('title style', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          final actual = tester.widget<Text>(find.text('title')).style;
          const expected = PaintStyle.titleStyle;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
