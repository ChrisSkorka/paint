import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/swatch_grid.dart';

void main() {
  group('class SwatchGrid', () {
    group('render', () {
      group('corners', () {
        testWidgets('empty', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SwatchGrid(colors: const [], onSelect: stubOnSelect),
              ),
            ),
          );
          final actual = find.byType(Swatch);
          expect(actual, findsNothing);
        });
        testWidgets('1x1', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SwatchGrid(
                  colors: const [
                    [Color(0xFF111111)],
                  ],
                  onSelect: stubOnSelect,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Swatch>(find.byType(Swatch))
              .map((swatch) => swatch.borderRadius)
              .toList();
          const expected = [BorderRadius.all(Radius.circular(5))];
          expect(actual, equals(expected));
        });
        testWidgets('1xn', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SwatchGrid(
                  colors: const [
                    [Color(0xFF111111), Color(0xFF222222), Color(0xFF333333)],
                  ],
                  onSelect: stubOnSelect,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Swatch>(find.byType(Swatch))
              .map((swatch) => swatch.borderRadius)
              .toList();
          const expected = [
            BorderRadius.horizontal(left: Radius.circular(5)),
            BorderRadius.zero,
            BorderRadius.horizontal(right: Radius.circular(5)),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('nx1', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SwatchGrid(
                  colors: const [
                    [Color(0xFF111111)],
                    [Color(0xFF222222)],
                    [Color(0xFF333333)],
                  ],
                  onSelect: stubOnSelect,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Swatch>(find.byType(Swatch))
              .map((swatch) => swatch.borderRadius)
              .toList();
          const expected = [
            BorderRadius.vertical(top: Radius.circular(5)),
            BorderRadius.zero,
            BorderRadius.vertical(bottom: Radius.circular(5)),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('nxm', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SwatchGrid(
                  colors: const [
                    [Color(0xFF111111), Color(0xFF222222)],
                    [Color(0xFF333333), Color(0xFF444444)],
                  ],
                  onSelect: stubOnSelect,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Swatch>(find.byType(Swatch))
              .map((swatch) => swatch.borderRadius)
              .toList();
          const expected = [
            BorderRadius.only(topLeft: Radius.circular(5)),
            BorderRadius.only(topRight: Radius.circular(5)),
            BorderRadius.only(bottomLeft: Radius.circular(5)),
            BorderRadius.only(bottomRight: Radius.circular(5)),
          ];
          expect(actual, equals(expected));
        });
      });
      group('empty slots', () {
        testWidgets('mixed', (tester) async {
          void stubOnSelect(Color color) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SwatchGrid(
                  colors: const [
                    [Color(0xFF111111)],
                    [null],
                  ],
                  onSelect: stubOnSelect,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Swatch>(find.byType(Swatch))
              .map((swatch) => swatch.color)
              .toList();
          const expected = [Color(0xFF111111), null];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('select color', (tester) async {
          final selected = <Color>[];
          void stubOnSelect(Color color) => selected.add(color);
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SwatchGrid(
                  colors: const [
                    [Color(0xFF111111), Color(0xFF222222)],
                  ],
                  onSelect: stubOnSelect,
                ),
              ),
            ),
          );
          await tester.tap(find.byType(Swatch).at(1));
          final actual = selected;
          const expected = [Color(0xFF222222)];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
