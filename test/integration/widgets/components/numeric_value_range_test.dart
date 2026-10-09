import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';

void main() {
  group('class NumericValueRange', () {
    group('render', () {
      group('label', () {
        testWidgets('text', (tester) async {
          void stubOnChanged(int value) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          final actual = find.text('Size:');
          expect(actual, findsOneWidget);
        });
      });
      group('buttons', () {
        testWidgets('at minimum', (tester) async {
          void stubOnChanged(int value) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 1,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<PaintIconButton>(find.byType(PaintIconButton))
              .map((paintIconButton) => paintIconButton.onPressed == null)
              .toList();
          const expected = [true, false];
          expect(actual, equals(expected));
        });
        testWidgets('in range', (tester) async {
          void stubOnChanged(int value) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<PaintIconButton>(find.byType(PaintIconButton))
              .map((paintIconButton) => paintIconButton.onPressed == null)
              .toList();
          const expected = [false, false];
          expect(actual, equals(expected));
        });
        testWidgets('at maximum', (tester) async {
          void stubOnChanged(int value) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 10,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<PaintIconButton>(find.byType(PaintIconButton))
              .map((paintIconButton) => paintIconButton.onPressed == null)
              .toList();
          const expected = [false, true];
          expect(actual, equals(expected));
        });
      });
      group('slider', () {
        testWidgets('value beyond range', (tester) async {
          void stubOnChanged(int value) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Zoom:',
                    value: 100,
                    minimum: 1,
                    maximum: 100,
                    rangeMinimum: 0,
                    rangeMaximum: 4,
                    valueToRange: (value) => log(value) / ln2,
                    rangeToValue: (range) => pow(2, range).round(),
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          final actual = tester.widget<Slider>(find.byType(Slider)).value;
          const expected = 4.0;
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('typing', () {
        testWidgets('valid', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '7');
          final actual = changes;
          const expected = [7];
          expect(actual, equals(expected));
        });
        testWidgets('unchanged', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '5');
          final actual = changes;
          const expected = <int>[];
          expect(actual, equals(expected));
        });
        testWidgets('below minimum', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '0');
          final actual = changes;
          const expected = <int>[];
          expect(actual, equals(expected));
        });
        testWidgets('above maximum', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '11');
          final actual = changes;
          const expected = <int>[];
          expect(actual, equals(expected));
        });
        testWidgets('empty', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '');
          final actual = changes;
          const expected = <int>[];
          expect(actual, equals(expected));
        });
      });
      group('submitting', () {
        testWidgets('in range', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '7');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [
            changes,
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
          ];
          const expected = [
            [7, 7],
            '7',
          ];
          expect(actual, equals(expected));
        });
        testWidgets('out of range', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '11');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [
            changes,
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
          ];
          const expected = [
            [10],
            '10',
          ];
          expect(actual, equals(expected));
        });
        testWidgets('empty', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [
            changes,
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
          ];
          const expected = [<int>[], '5'];
          expect(actual, equals(expected));
        });
      });
      group('buttons', () {
        testWidgets('minus', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Decrease'));
          final actual = changes;
          const expected = [4];
          expect(actual, equals(expected));
        });
        testWidgets('plus', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase'));
          final actual = changes;
          const expected = [6];
          expect(actual, equals(expected));
        });
        testWidgets('custom decrement', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Zoom:',
                    value: 8,
                    minimum: 1,
                    maximum: 100,
                    decrement: (value) => value ~/ 2,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Decrease'));
          final actual = changes;
          const expected = [4];
          expect(actual, equals(expected));
        });
        testWidgets('custom increment', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Zoom:',
                    value: 8,
                    minimum: 1,
                    maximum: 100,
                    increment: (value) => value * 2,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase'));
          final actual = changes;
          const expected = [16];
          expect(actual, equals(expected));
        });
      });
      group('slider', () {
        testWidgets('default mapping', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 1,
                    minimum: 0,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byType(Slider));
          final actual = changes;
          const expected = [5];
          expect(actual, equals(expected));
        });
        testWidgets('custom mapping', (tester) async {
          final changes = <int>[];
          void stubOnChanged(int value) => changes.add(value);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Zoom:',
                    value: 1,
                    minimum: 1,
                    maximum: 100,
                    rangeMinimum: 0,
                    rangeMaximum: 4,
                    valueToRange: (value) => log(value) / ln2,
                    rangeToValue: (range) => pow(2, range).round(),
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byType(Slider));
          final actual = changes;
          const expected = [4];
          expect(actual, equals(expected));
        });
      });
    });

    group('lifecycle', () {
      group('value updated by parent', () {
        testWidgets('different value', (tester) async {
          void stubOnChanged(int value) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 6,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          final actual = tester
              .widget<TextField>(find.byType(TextField))
              .controller!
              .text;
          const expected = '6';
          expect(actual, equals(expected));
        });
        testWidgets('same value', (tester) async {
          void stubOnChanged(int value) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '05');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: NumericValueRange(
                    label: 'Size:',
                    value: 5,
                    minimum: 1,
                    maximum: 10,
                    onChanged: stubOnChanged,
                  ),
                ),
              ),
            ),
          );
          final actual = tester
              .widget<TextField>(find.byType(TextField))
              .controller!
              .text;
          const expected = '05';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
