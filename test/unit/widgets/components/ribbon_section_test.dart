import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/ribbon_section.dart';

void main() {
  group('class RibbonColumn', () {
    group('render', () {
      group('cell heights', () {
        testWidgets('no children', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(child: RibbonColumn(children: [])),
            ),
          );
          final actual = find.descendant(
            of: find.byType(RibbonColumn),
            matching: find.byType(SizedBox),
          );
          expect(actual, findsNothing);
        });
        testWidgets('one child', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonColumn(children: [Text('a', key: Key('a'))]),
              ),
            ),
          );
          final actual = [
            tester
                .getSize(
                  find
                      .ancestor(
                        of: find.byKey(const Key('a')),
                        matching: find.byType(SizedBox),
                      )
                      .first,
                )
                .height,
          ];
          const expected = [80.0];
          expect(actual, equals(expected));
        });
        testWidgets('multiple children', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(
                child: RibbonColumn(
                  children: [
                    Text('a', key: Key('a')),
                    Text('b', key: Key('b')),
                  ],
                ),
              ),
            ),
          );
          final actual = [
            for (final key in const [Key('a'), Key('b')])
              tester
                  .getSize(
                    find
                        .ancestor(
                          of: find.byKey(key),
                          matching: find.byType(SizedBox),
                        )
                        .first,
                  )
                  .height,
          ];
          const expected = [40.0, 40.0];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
