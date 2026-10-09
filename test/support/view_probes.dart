import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/widgets/components/chess_grid.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';

Size? canvasSize(WidgetTester tester) => tester
    .widget<CustomPaint>(
      find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is ChessGridPainter,
      ),
    )
    .size;

int tabIndex(WidgetTester tester) =>
    tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

List<Layer> canvasLayers(WidgetTester tester) =>
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
