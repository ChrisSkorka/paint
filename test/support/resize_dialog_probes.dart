import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/resize_dialog.dart';

const resizeFieldLabels = [
  'Width (px)',
  'Height (px)',
  'Offset X (px)',
  'Offset Y (px)',
];

Finder resizeField(String label) => find.byKey(Key(label));

List<String> resizeFieldTexts(WidgetTester tester) => [
  for (final label in resizeFieldLabels)
    tester.widget<TextField>(resizeField(label)).controller!.text,
];

List<String?> resizeFieldErrors(WidgetTester tester) => [
  for (final label in resizeFieldLabels)
    tester.widget<TextField>(resizeField(label)).decoration!.errorText,
];

bool resizeButtonEnabled(WidgetTester tester, {required String tooltip}) =>
    tester
        .widget<PaintIconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(PaintIconButton),
          ),
        )
        .onPressed !=
    null;

Finder resizePreview() => find.byWidgetPredicate(
  (widget) =>
      widget is CustomPaint && widget.foregroundPainter is ResizePreviewPainter,
);

List<Object?> resizePreviewState(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(resizePreview());
  final painter = customPaint.foregroundPainter! as ResizePreviewPainter;
  return [customPaint.size, painter.thumbnail, painter.origin, painter.scale];
}
