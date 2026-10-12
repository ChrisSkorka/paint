import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/canvas_layer.dart';
import 'package:paint/widgets/components/chess_grid.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';

Size? canvasSize(WidgetTester tester) => tester
    .widget<CustomPaint>(
      find.descendant(
        of: find.byType(PixelCanvas),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is ChessGridPainter,
        ),
      ),
    )
    .size;

int tabIndex(WidgetTester tester) =>
    tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

List<CanvasLayer> canvasLayers(WidgetTester tester) =>
    (tester
                .widget<CustomPaint>(
                  find.byWidgetPredicate(
                    (widget) =>
                        widget is CustomPaint &&
                        widget.foregroundPainter is PixelLayersPainter,
                  ),
                )
                .foregroundPainter
            as PixelLayersPainter)
        .layers;

List<String> texts(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(find.byType(Text))) text.data!,
];
