import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/color_dialog.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';
import 'package:paint/widgets/components/swatch_grid.dart';

Finder channelField(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label),
    matching: find.byType(NumericValueRange),
  ),
  matching: find.byType(TextField),
);

List<int> channelValues(WidgetTester tester) => tester
    .widgetList<NumericValueRange>(
      find.descendant(
        of: find.byType(ColorDialog),
        matching: find.byType(NumericValueRange),
      ),
    )
    .map((numericValueRange) => numericValueRange.value)
    .toList();

List<Color> previewColors(WidgetTester tester) => tester
    .widgetList<ColorPreview>(
      find.descendant(
        of: find.byType(ColorDialog),
        matching: find.byType(ColorPreview),
      ),
    )
    .map((colorPreview) => colorPreview.color)
    .toList();

Finder hexField() => find.descendant(
  of: find.ancestor(of: find.text('Hex:'), matching: find.byType(Row)).first,
  matching: find.byType(TextField),
);

String hexText(WidgetTester tester) =>
    tester.widget<TextField>(hexField()).controller!.text;
