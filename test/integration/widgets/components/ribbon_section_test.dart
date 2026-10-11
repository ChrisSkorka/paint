import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/ribbon_section.dart';

void main() {
  group('class RibbonSection', () {
    group('render', () {
      group('columns', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonSection(title: 'Tools', columns: []),
              ),
            ),
          );
          final actual = find.text('Tools');
          expect(actual, findsOneWidget);
        });
        testWidgets('one', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonSection(title: 'Tools', columns: [Text('first')]),
              ),
            ),
          );
          final actual =
              tester.getTopLeft(find.text('Tools')).dy <
              tester.getTopLeft(find.text('first')).dy;
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonSection(
                  title: 'Tools',
                  columns: [Text('first'), Text('second')],
                ),
              ),
            ),
          );
          final actual = [
            tester.getTopLeft(find.text('first')).dx <
                tester.getTopLeft(find.text('second')).dx,
            tester.getTopLeft(find.text('Tools')).dy <
                tester.getTopLeft(find.text('first')).dy,
          ];
          const expected = [true, true];
          expect(actual, equals(expected));
        });
      });
      group('height', () {
        testWidgets('expanded', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonSection(title: 'Tools', columns: [Text('first')]),
              ),
            ),
          );
          final actual = tester.getSize(find.byType(RibbonSection)).height;
          const expected = 108.0;
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('collapse', () {
        testWidgets('tap title', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonSection(title: 'Tools', columns: [Text('first')]),
              ),
            ),
          );
          await tester.tap(find.text('Tools'));
          await tester.pump();
          final actual = [
            find.text('first').evaluate().length,
            tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
            tester.getSize(find.byType(RibbonSection)).height,
            tester.getSize(find.byType(RotatedBox)).height >
                tester.getSize(find.byType(RotatedBox)).width,
          ];
          const expected = [0, 3, 108.0, true];
          expect(actual, equals(expected));
        });
        testWidgets('expand again', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonSection(title: 'Tools', columns: [Text('first')]),
              ),
            ),
          );
          await tester.tap(find.text('Tools'));
          await tester.pump();
          await tester.tap(find.text('Tools'));
          await tester.pump();
          final actual = [
            find.text('first').evaluate().length,
            find.byType(RotatedBox).evaluate().length,
            tester.getSize(find.byType(RibbonSection)).height,
          ];
          const expected = [1, 0, 108.0];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
