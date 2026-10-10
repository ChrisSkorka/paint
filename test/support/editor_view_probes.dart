import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/history_list.dart';
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
          of: find.byTooltip('Fill'),
          matching: find.byType(PaintIconButton),
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

List<List<Color?>> recentSwatches(WidgetTester tester) =>
    tester.widgetList<SwatchGrid>(find.byType(SwatchGrid)).last.colors;

List<Object> historyState(WidgetTester tester) {
  final historyList = tester.widget<HistoryList>(find.byType(HistoryList));
  return [
    [for (final item in historyList.items) item.name],
    historyList.position,
  ];
}

List<List<Object?>> historyThumbnails(WidgetTester tester) => [
  for (final item in tester.widget<HistoryList>(find.byType(HistoryList)).items)
    [item.thumbnail, item.outline],
];

List<bool> undoRedoEnabled(WidgetTester tester) => [
  for (final tooltip in const ['Undo', 'Redo'])
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

List<bool> selectedShapes(WidgetTester tester) => [
  for (final tooltip in ['Line', 'Rectangle', 'Circle', 'Arrow'])
    tester
        .widget<PaintSplitButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(PaintSplitButton),
          ),
        )
        .selected,
];

Finder widthRange() => find.ancestor(
  of: find.text('Width:'),
  matching: find.byType(NumericValueRange),
);
