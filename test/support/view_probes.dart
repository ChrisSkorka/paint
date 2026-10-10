import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/widgets/components/chess_grid.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';

Size? canvasSize(WidgetTester tester) => tester
    .widget<CustomPaint>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.painter is ChessGridPainter &&
            widget.foregroundPainter is PixelLayersPainter,
      ),
    )
    .size;

int tabIndex(WidgetTester tester) =>
    tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

List<DocumentLayer> canvasLayers(WidgetTester tester) =>
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
