import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/text_input_dialog.dart';

import '../../../support/desktop_view.dart';
import '../../../support/text_input_dialog_probes.dart';

void main() {
  group('class TextInputDialog', () {
    group('render', () {
      group('initial values', () {
        testWidgets('field', (tester) async {
          useDesktopView(tester);
          await openTextInputDialog(tester);
          final field = textInputFieldWidget(tester);
          final actual = [
            find.text('Rename document').evaluate().length,
            field.controller!.value,
            field.decoration!.labelText,
            field.decoration!.errorText,
            textInputOkEnabled(tester),
          ];
          const expected = [
            1,
            TextEditingValue(
              text: 'Cat',
              selection: TextSelection(baseOffset: 0, extentOffset: 3),
            ),
            'Name',
            null,
            true,
          ];
          expect(actual, equals(expected));
        });
      });
      group('invalid values', () {
        testWidgets('empty', (tester) async {
          useDesktopView(tester);
          await openTextInputDialog(tester);
          await tester.enterText(textInputField(), '');
          await tester.pump();
          final actual = [
            textInputFieldWidget(tester).decoration!.errorText,
            textInputOkEnabled(tester),
          ];
          const expected = ['Cannot be empty', false];
          expect(actual, equals(expected));
        });
        testWidgets('whitespace', (tester) async {
          useDesktopView(tester);
          await openTextInputDialog(tester);
          await tester.enterText(textInputField(), '   ');
          await tester.pump();
          final actual = textInputOkEnabled(tester);
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('standalone', () {
    group('function showTextInputDialog', () {
      group('results', () {
        testWidgets('ok unchanged', (tester) async {
          useDesktopView(tester);
          final results = await openTextInputDialog(tester);
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = results;
          const expected = ['Cat'];
          expect(actual, equals(expected));
        });
        testWidgets('enter trimmed', (tester) async {
          useDesktopView(tester);
          final results = await openTextInputDialog(tester);
          await tester.enterText(textInputField(), ' Dog ');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          final actual = results;
          const expected = ['Dog'];
          expect(actual, equals(expected));
        });
        testWidgets('enter empty', (tester) async {
          useDesktopView(tester);
          final results = await openTextInputDialog(tester);
          await tester.enterText(textInputField(), '');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          final actual = [
            results,
            tester.widgetList(find.byType(TextInputDialog)).length,
          ];
          const expected = [<String?>[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('cancel', (tester) async {
          useDesktopView(tester);
          final results = await openTextInputDialog(tester);
          await tester.enterText(textInputField(), 'Dog');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = results;
          const expected = [null];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
