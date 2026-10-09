import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../editor/canvas/layer.dart';
import '../../editor/canvas/pixel_point.dart';
import '../../editor/pointer_button.dart';
import 'chess_grid.dart';

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
  });

  final int width;
  final int height;
  final int zoom;
  final List<Layer> layers;
  final void Function({
    required PixelPoint point,
    required PointerButton button,
  })
  onPointerDown;
  final void Function({required PixelPoint point}) onPointerMove;
  final void Function({required PixelPoint point}) onPointerUp;
  final VoidCallback onPointerExit;

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
      cursor: SystemMouseCursors.precise,
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
        child: CustomPaint(
          painter: const ChessGridPainter(),
          foregroundPainter: PixelLayersPainter(layers: layers, zoom: zoom),
          size: Size(width * zoom.toDouble(), height * zoom.toDouble()),
        ),
      ),
    );
  }
}

class PixelLayersPainter extends CustomPainter {
  const PixelLayersPainter({required this.layers, required this.zoom});

  final List<Layer> layers;
  final int zoom;

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      for (var y = 0; y < layer.height; y++) {
        _paintRow(canvas: canvas, layer: layer, y: y);
      }
    }
  }

  void _paintRow({
    required Canvas canvas,
    required Layer layer,
    required int y,
  }) {
    var runStart = 0;
    for (var x = 1; x <= layer.width; x++) {
      final runColor = layer.getPixel(PixelPoint(x: runStart, y: y));
      if (x < layer.width &&
          layer.getPixel(PixelPoint(x: x, y: y)) == runColor) {
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
  bool shouldRepaint(PixelLayersPainter oldDelegate) => true;
}
