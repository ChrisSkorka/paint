import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/color_dialog.dart';
import 'package:paint/widgets/components/swatch_grid.dart';

Finder colorArea() => find.descendant(
  of: find.byType(ColorDialog),
  matching: find.byType(ColorPickerArea),
);

Finder colorSlider(String tooltip) => find.descendant(
  of: find.byTooltip(tooltip),
  matching: find.byType(ColorPickerSlider),
);

HSVColor pickerColor(WidgetTester tester) =>
    tester.widget<ColorPickerArea>(colorArea()).hsvColor;

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
