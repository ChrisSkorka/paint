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
    });
  });
}
