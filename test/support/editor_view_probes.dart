import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_split_button.dart';
import 'package:paint/widgets/components/swatch_grid.dart';

List<bool> selectedTools(WidgetTester tester) => [
  tester
      .widget<PaintSplitButton>(
        find.ancestor(
          of: find.byTooltip('Pen'),
          matching: find.byType(PaintSplitButton),
        ),
      )
      .selected,
  tester
      .widget<PaintSplitButton>(
        find.ancestor(
          of: find.byTooltip('Eraser'),
          matching: find.byType(PaintSplitButton),
        ),
      )
      .selected,
  tester
      .widget<PaintIconButton>(
        find.ancestor(
          of: find.byTooltip('Color picker'),
          matching: find.byType(PaintIconButton),
        ),
      )
      .selected,
];

List<Color> wellColors(WidgetTester tester) => tester
    .widgetList<ColorWell>(find.byType(ColorWell))
    .map((colorWell) => colorWell.color)
    .toList();

Finder sizeRange() => find.ancestor(
  of: find.text('Size:'),
  matching: find.byType(NumericValueRange),
);

List<bool> selectedTips(WidgetTester tester) => [
  tester
      .widget<PaintIconButton>(
        find.ancestor(
          of: find.byTooltip('Square tip'),
          matching: find.byType(PaintIconButton),
        ),
      )
      .selected,
  tester
      .widget<PaintIconButton>(
        find.ancestor(
          of: find.byTooltip('Circle tip'),
          matching: find.byType(PaintIconButton),
        ),
      )
      .selected,
];
