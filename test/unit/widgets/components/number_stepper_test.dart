import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/number_stepper.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';

void main() {
  void ignoreChange(int value) {}

  List<Object> stepperState(WidgetTester tester) => [
    tester.widget<TextField>(find.byType(TextField)).controller!.text,
    for (final tooltip in ['Fewer', 'More'])
      tester
              .widget<PaintIconButton>(
                find.ancestor(
                  of: find.byTooltip(tooltip),
                  matching: find.byType(PaintIconButton),
                ),
              )
              .onPressed !=
          null,
  ];

  group('class NumberStepper', () {
    group('render', () {
      group('value', () {
        testWidgets('between limits', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          final actual = stepperState(tester);
          const expected = ['5', true, true];
          expect(actual, equals(expected));
        });
        testWidgets('at minimum', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 0,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          final actual = stepperState(tester);
          const expected = ['0', false, true];
          expect(actual, equals(expected));
        });
        testWidgets('at maximum', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 10,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          final actual = stepperState(tester);
          const expected = ['10', true, false];
          expect(actual, equals(expected));
        });
      });

      group('layout', () {
        testWidgets('field padding', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 100,
                  minimum: 0,
                  maximum: 100,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          final actual = [
            tester.getSize(find.byType(TextField)).width,
            tester
                .widget<TextField>(find.byType(TextField))
                .decoration!
                .contentPadding,
          ];
          const expected = [
            44.0,
            EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ];
          expect(actual, equals(expected));
        });
      });

      group('editable', () {
        testWidgets('text only', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                  editable: false,
                ),
              ),
            ),
          );
          final actual = [
            find.byType(TextField).evaluate().length,
            tester.widget<Text>(find.byType(Text)).data,
          ];
          const expected = [0, '5'];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('buttons', () {
        testWidgets('increase', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More'));
          final actual = changes;
          const expected = [6];
          expect(actual, equals(expected));
        });
        testWidgets('text only increase', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                  editable: false,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More'));
          final actual = changes;
          const expected = [6];
          expect(actual, equals(expected));
        });
        testWidgets('decrease', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fewer'));
          final actual = changes;
          const expected = [4];
          expect(actual, equals(expected));
        });
      });
      group('typing', () {
        testWidgets('submit', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '7');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          final actual = changes;
          const expected = [7];
          expect(actual, equals(expected));
        });
        testWidgets('above maximum', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '70');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [changes, stepperState(tester).first];
          const expected = [
            [10],
            '10',
          ];
          expect(actual, equals(expected));
        });
        testWidgets('unchanged', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '5');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          final actual = changes;
          const expected = <int>[];
          expect(actual, equals(expected));
        });
        testWidgets('empty', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [changes, stepperState(tester).first];
          const expected = [<int>[], '5'];
          expect(actual, equals(expected));
        });
        testWidgets('while typing', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '8');
          final actual = changes;
          const expected = <int>[];
          expect(actual, equals(expected));
        });
        testWidgets('tap outside', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const Text('Outside'),
                    NumberStepper(
                      value: 5,
                      minimum: 0,
                      maximum: 10,
                      decreaseTooltip: 'Fewer',
                      increaseTooltip: 'More',
                      onChanged: changes.add,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '8');
          await tester.tapAt(tester.getCenter(find.text('Outside')));
          await tester.pump();
          final actual = [
            changes,
            FocusManager.instance.primaryFocus?.context?.widget is EditableText,
          ];
          const expected = [
            [8],
            false,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('lifecycle', () {
      group('value', () {
        testWidgets('changed by parent', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 9,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          final actual = stepperState(tester).first;
          const expected = '9';
          expect(actual, equals(expected));
        });
        testWidgets('rebuilt while typing', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), '8');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NumberStepper(
                  value: 5,
                  minimum: 0,
                  maximum: 10,
                  decreaseTooltip: 'Fewer',
                  increaseTooltip: 'More',
                  onChanged: ignoreChange,
                ),
              ),
            ),
          );
          final actual = stepperState(tester).first;
          const expected = '8';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
