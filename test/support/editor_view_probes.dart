import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_bar.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/onion_skin.dart';
import 'package:paint/editor/canvas/layer_timeframe.dart';
import 'package:paint/widgets/components/edge_shadow.dart';
import 'package:paint/widgets/components/frame_list.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';
import 'package:paint/widgets/components/history_list.dart';
import 'package:paint/widgets/components/layer_list.dart';
import 'package:paint/widgets/components/number_stepper.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_split_button.dart';
import 'package:paint/widgets/components/ribbon_section.dart';
import 'package:paint/widgets/components/swatch_grid.dart';
import 'package:paint/widgets/components/text_draft.dart';
import 'package:paint/widgets/components/timeline.dart';
import 'package:paint/widgets/components/tool_preset_list.dart';

List<bool> selectedTools(WidgetTester tester) => [
  tester
      .widget<PaintIconButton>(
        find.ancestor(
          of: find.byTooltip('Pen (P)'),
          matching: find.byType(PaintIconButton),
        ),
      )
      .selected,
  tester
      .widget<PaintIconButton>(
        find.ancestor(
          of: find.byTooltip('Eraser (E)'),
          matching: find.byType(PaintIconButton),
        ),
      )
      .selected,
  tester
      .widget<PaintIconButton>(
        find.ancestor(
          of: find.byTooltip('Fill (G)'),
          matching: find.byType(PaintIconButton),
        ),
      )
      .selected,
  tester
      .widget<PaintIconButton>(
        find.ancestor(
          of: find.byTooltip('Color picker (I)'),
          matching: find.byType(PaintIconButton),
        ),
      )
      .selected,
];

List<Color> wellColors(WidgetTester tester) => tester
    .widgetList<ColorWell>(find.byType(ColorWell))
    .map((colorWell) => colorWell.color)
    .toList();

Finder sizeStepper() => find.ancestor(
  of: find.byTooltip('Increase size'),
  matching: find.byType(NumberStepper),
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

ToolPresetList toolPresetList(WidgetTester tester) =>
    tester.widget<ToolPresetList>(find.byType(ToolPresetList));

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
  for (final tooltip in const ['Undo (Ctrl+Z)', 'Redo (Ctrl+Y / Ctrl+Shift+Z)'])
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
  for (final tooltip in [
    'Line (L)',
    'Rectangle (R)',
    'Circle (O)',
    'Arrow (A)',
  ])
    tester
        .widget<PaintIconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(PaintIconButton),
          ),
        )
        .selected,
];

Finder sizeSlider() => find.descendant(
  of: find.ancestor(
    of: find.byTooltip('Increase size'),
    matching: find.byType(RibbonSection),
  ),
  matching: find.byType(Slider),
);

List<bool> penSettingsEnabled(WidgetTester tester) => [
  tester.widget<NumberStepper>(sizeStepper()).enabled,
  tester.widget<Slider>(sizeSlider()).onChanged != null,
  for (final tooltip in const ['Square tip', 'Circle tip'])
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

List<bool> shapeStyle(WidgetTester tester) => [
  for (final tooltip in const ['Outline', 'Fill shape'])
    ...switch (tester.widget<PaintIconButton>(
      find.ancestor(
        of: find.byTooltip(tooltip),
        matching: find.byType(PaintIconButton),
      ),
    )) {
      final button => [button.selected, button.onPressed != null],
    },
];

bool selectToolSelected(WidgetTester tester) => tester
    .widget<PaintIconButton>(
      find.ancestor(
        of: find.byTooltip('Select (M)'),
        matching: find.byType(PaintIconButton),
      ),
    )
    .selected;

List<bool> selectionActionsEnabled(WidgetTester tester) => [
  for (final tooltip in [
    'Rotate left',
    'Rotate right',
    'Mirror horizontally',
    'Mirror vertically',
  ])
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

List<Object> layerState(WidgetTester tester) {
  final layerList = tester.widget<LayerList>(find.byType(LayerList));
  return [
    [for (final item in layerList.items) item.name],
    [for (final item in layerList.items) item.visible],
    [for (final item in layerList.items) item.opacity],
    layerList.activeIndex,
  ];
}

Layer layerThumbnail(WidgetTester tester) =>
    tester.widget<LayerList>(find.byType(LayerList)).items.last.thumbnail;

List<bool> layerActionsEnabled(WidgetTester tester) => [
  for (final tooltip in [
    'Add layer (Shift+N)',
    'Remove layer (Shift+Del)',
    'Move layer up (Alt+PgUp)',
    'Move layer down (Alt+PgDn)',
  ])
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

List<bool> clipboardActionsEnabled(WidgetTester tester) => [
  for (final tooltip in ['Paste (Ctrl+V)', 'Cut (Ctrl+X)', 'Copy (Ctrl+C)'])
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

List<Object> timelineState(WidgetTester tester) {
  final timeline = tester.widget<Timeline>(find.byType(Timeline));
  return [
    timeline.frame,
    timeline.shownFrames,
    timeline.fps,
    timeline.playing,
    tester.widget<FrameList>(find.byType(FrameList)).activeIndex,
  ];
}

List<LayerTimeframe> layerTimeframes(WidgetTester tester) => [
  for (final item in tester.widget<LayerList>(find.byType(LayerList)).items)
    item.timeframe,
];

List<int> frameHolds(WidgetTester tester) => [
  for (final item in tester.widget<FrameList>(find.byType(FrameList)).items)
    item.holds,
];

List<bool> frameControlsEnabled(WidgetTester tester) => [
  for (final tooltip in [
    'Add frame (Alt+N)',
    'Copy frame (Alt+D)',
    'Remove frame (Alt+Del)',
    'Move frame up (Alt+,)',
    'Move frame down (Alt+.)',
  ])
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

List<bool> allSelectedTools(WidgetTester tester) => [
  ...selectedTools(tester),
  selectToolSelected(tester),
  ...selectedShapes(tester),
];

OnionSkin timelineOnionSkin(WidgetTester tester) =>
    tester.widget<Timeline>(find.byType(Timeline)).onionSkin;

List<double> statusSectionWidths(WidgetTester tester) => [
  for (final element
      in find
          .descendant(
            of: find.byType(PaintBar).last,
            matching: find.byType(PaintBarSection),
          )
          .evaluate())
    element.size!.width,
];

Finder canvasArea() => find.byWidgetPredicate(
  (widget) =>
      widget is CustomPaint && widget.foregroundPainter is EdgeShadowPainter,
);

Offset canvasOffset(WidgetTester tester) =>
    tester.getTopLeft(find.byType(PixelCanvas)) -
    tester.getTopLeft(canvasArea());

bool textToolSelected(WidgetTester tester) => tester
    .widget<PaintSplitButton>(
      find.ancestor(
        of: find.byTooltip('Text (T)'),
        matching: find.byType(PaintSplitButton),
      ),
    )
    .selected;

List<Object> textOptions(WidgetTester tester) => [
  tester
      .widget<NumberStepper>(
        find.ancestor(
          of: find.byTooltip('Increase text size'),
          matching: find.byType(NumberStepper),
        ),
      )
      .value,
  for (final tooltip in ['Bold', 'Italic', 'Underline', 'Strikethrough'])
    tester
        .widget<PaintIconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(PaintIconButton),
          ),
        )
        .selected,
];

Offset textFieldOffset(WidgetTester tester) =>
    tester.getTopLeft(
      find.descendant(
        of: find.byType(TextDraft),
        matching: find.byType(TextField),
      ),
    ) -
    tester.getTopLeft(find.byType(PixelCanvas));

List<Object> textOutlineOptions(WidgetTester tester) => [
  for (final tooltip in ['Fill text', 'Outline text'])
    tester
        .widget<PaintIconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(PaintIconButton),
          ),
        )
        .selected,
  tester
      .widget<NumberStepper>(
        find.ancestor(
          of: find.byTooltip('Increase outline width'),
          matching: find.byType(NumberStepper),
        ),
      )
      .value,
  tester
      .widget<NumberStepper>(
        find.ancestor(
          of: find.byTooltip('Increase outline width'),
          matching: find.byType(NumberStepper),
        ),
      )
      .enabled,
];
