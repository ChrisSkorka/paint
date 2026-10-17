import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/text_input_dialog.dart';

Finder textInputField() => find.byKey(const Key('Name'));

TextField textInputFieldWidget(WidgetTester tester) =>
    tester.widget<TextField>(textInputField());

bool textInputOkEnabled(WidgetTester tester) =>
    tester
        .widget<PaintIconButton>(
          find.ancestor(
            of: find.byTooltip('OK'),
            matching: find.byType(PaintIconButton),
          ),
        )
        .onPressed !=
    null;

Future<List<String?>> openTextInputDialog(WidgetTester tester) async {
  final results = <String?>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => results.add(
            await showTextInputDialog(
              context: context,
              title: 'Rename document',
              label: 'Name',
              initialText: 'Cat',
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}
