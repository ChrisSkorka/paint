import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_bar.dart';
import 'package:paint/widgets/components/paint_style.dart';

void main() {
  group('class PaintBar', () {
    group('render', () {
      group('content', () {
        testWidgets('child', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: PaintBar(child: Text('child'))),
          );
          final actual = find.text('child');
          expect(actual, findsOneWidget);
        });
      });
      group('decoration', () {
        testWidgets('background and shadow', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: PaintBar(child: Text('child'))),
          );
          final actual = tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(PaintBar),
                  matching: find.byType(Container),
                ),
              )
              .decoration;
          const expected = BoxDecoration(
            color: PaintStyle.barBackground,
            boxShadow: PaintStyle.barShadow,
          );
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class PaintBarSection', () {
    group('render', () {
      group('content', () {
        testWidgets('child', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: PaintBarSection(child: Text('child'))),
          );
          final actual = find.text('child');
          expect(actual, findsOneWidget);
        });
      });
      group('decoration', () {
        testWidgets('right separator', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: PaintBarSection(child: Text('child'))),
          );
          final actual = tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(PaintBarSection),
                  matching: find.byType(Container),
                ),
              )
              .decoration;
          const expected = BoxDecoration(
            border: Border(right: BorderSide(color: PaintStyle.separatorColor)),
          );
          expect(actual, equals(expected));
        });
      });
    });
  });
}
