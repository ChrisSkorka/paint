import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../editor/canvas/canvas_layer.dart';
import '../../editor/canvas/document_layer.dart';
import '../../editor/canvas/layer.dart';
import '../../editor/canvas/pixel_color.dart';
import '../../editor/canvas/pixel_point.dart';
import '../../editor/canvas/pixel_rectangle.dart';
import '../../editor/pointer_button.dart';
import 'chess_grid.dart';
import 'paint_style.dart';

class PixelCanvas extends StatelessWidget {
  const PixelCanvas({
    super.key,
    required this.width,
    required this.height,
    required this.zoom,
    required this.layers,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.onPointerExit,
    this.selection,
    this.cursor = SystemMouseCursors.precise,
  });

  final int width;
  final int height;
  final int zoom;
  final List<CanvasLayer> layers;
  final void Function({
    required PixelPoint point,
    required PointerButton button,
  })
  onPointerDown;
  final void Function({required PixelPoint point}) onPointerMove;
  final void Function({required PixelPoint point}) onPointerUp;
  final VoidCallback onPointerExit;
  final PixelRectangle? selection;
  final MouseCursor cursor;

  PixelPoint _toPixel(Offset position) => PixelPoint(
    x: (position.dx / zoom).floor(),
    y: (position.dy / zoom).floor(),
  );

  PointerButton _toButton(int buttons) => buttons & kSecondaryMouseButton != 0
      ? PointerButton.secondary
      : PointerButton.primary;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor,
      onExit: (_) => onPointerExit(),
      child: Listener(
        onPointerDown: (event) => onPointerDown(
          point: _toPixel(event.localPosition),
          button: _toButton(event.buttons),
        ),
        onPointerHover: (event) =>
            onPointerMove(point: _toPixel(event.localPosition)),
        onPointerMove: (event) =>
            onPointerMove(point: _toPixel(event.localPosition)),
        onPointerUp: (event) =>
            onPointerUp(point: _toPixel(event.localPosition)),
        onPointerCancel: (event) =>
            onPointerUp(point: _toPixel(event.localPosition)),
        child: ClipRect(
          child: CustomPaint(
            foregroundPainter: SelectionOutlinePainter(
              area: selection,
              zoom: zoom,
            ),
            child: CustomPaint(
              painter: const ChessGridPainter(),
              foregroundPainter: PixelLayersPainter(layers: layers, zoom: zoom),
              size: Size(width * zoom.toDouble(), height * zoom.toDouble()),
            ),
          ),
        ),
      ),
    );
  }
}

class PixelLayersPainter extends CustomPainter {
  const PixelLayersPainter({required this.layers, required this.zoom});

  final List<CanvasLayer> layers;
  final int zoom;

  static ColorFilter tintFilter(PixelColor tint) => ColorFilter.matrix([
    0.5, 0, 0, 0, tint.red * 0.5, //
    0, 0.5, 0, 0, tint.green * 0.5, //
    0, 0, 0.5, 0, tint.blue * 0.5, //
    0, 0, 0, 1, 0, //
  ]);

  static void paintPixels({
    required Canvas canvas,
    required Layer pixels,
    required int zoom,
  }) {
    for (var y = 0; y < pixels.height; y++) {
      _paintRow(canvas: canvas, pixels: pixels, y: y, zoom: zoom);
    }
  }

  static void _paintRow({
    required Canvas canvas,
    required Layer pixels,
    required int y,
    required int zoom,
  }) {
    var runStart = 0;
    for (var x = 1; x <= pixels.width; x++) {
      final runColor = pixels.getPixel(PixelPoint(x: runStart, y: y));
      if (x < pixels.width &&
          pixels.getPixel(PixelPoint(x: x, y: y)) == runColor) {
        continue;
      }
      if (runColor.alpha > 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            runStart * zoom.toDouble(),
            y * zoom.toDouble(),
            (x - runStart) * zoom.toDouble(),
            zoom.toDouble(),
          ),
          Paint()
            ..color = Color(runColor.argb)
            ..isAntiAlias = false,
        );
      }
      runStart = x;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      final tint = layer.tint;
      final composited =
          layer.opacity < DocumentLayer.maximumOpacity || tint != null;
      if (composited) {
        canvas.saveLayer(
          Offset.zero & size,
          Paint()
            ..color = Color.fromRGBO(
              0,
              0,
              0,
              layer.opacity / DocumentLayer.maximumOpacity,
            )
            ..colorFilter = tint == null ? null : tintFilter(tint),
        );
      }
      paintPixels(canvas: canvas, pixels: layer.image, zoom: zoom);
      if (composited) canvas.restore();
    }
  }

  @override
  bool shouldRepaint(PixelLayersPainter oldDelegate) => true;
}

class SelectionOutlinePainter extends CustomPainter {
  const SelectionOutlinePainter({required this.area, required this.zoom});

  final PixelRectangle? area;
  final int zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final area = this.area;
    if (area == null) return;
    final outline = Rect.fromLTWH(
      area.left * zoom.toDouble(),
      area.top * zoom.toDouble(),
      area.width * zoom.toDouble(),
      area.height * zoom.toDouble(),
    ).deflate(0.5);
    canvas.drawRect(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = PaintStyle.selectionLight,
    );
    final corners = [
      outline.topLeft,
      outline.topRight,
      outline.bottomRight,
      outline.bottomLeft,
      outline.topLeft,
    ];
    final dashes = Path();
    for (var index = 0; index < 4; index++) {
      _addDashes(path: dashes, start: corners[index], end: corners[index + 1]);
    }
    canvas.drawPath(
      dashes,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = PaintStyle.selectionDark,
    );
  }

  void _addDashes({
    required Path path,
    required Offset start,
    required Offset end,
  }) {
    final length = (end - start).distance;
    final direction = (end - start) / length;
    for (
      var distance = 0.0;
      distance < length;
      distance += PaintStyle.selectionDashLength * 2
    ) {
      final dashEnd = min(distance + PaintStyle.selectionDashLength, length);
      path
        ..moveTo(
          start.dx + direction.dx * distance,
          start.dy + direction.dy * distance,
        )
        ..lineTo(
          start.dx + direction.dx * dashEnd,
          start.dy + direction.dy * dashEnd,
        );
    }
  }

  @override
  bool shouldRepaint(SelectionOutlinePainter oldDelegate) =>
      oldDelegate.area != area || oldDelegate.zoom != zoom;
}
