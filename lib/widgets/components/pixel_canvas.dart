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
import '../../editor/pointer_preview.dart';
import 'chess_grid.dart';
import 'layer_image_cache.dart';
import 'paint_style.dart';

class PixelCanvas extends StatefulWidget {
  const PixelCanvas({
    super.key,
    required this.width,
    required this.height,
    required this.zoom,
    required this.layers,
    required this.pointerPreview,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.onPointerExit,
    this.selection,
    this.cursor = SystemMouseCursors.precise,
    this.layersChanged,
  });

  final int width;
  final int height;
  final int zoom;
  final List<CanvasLayer> layers;
  final PointerPreview pointerPreview;
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
  final Listenable? layersChanged;

  @override
  State<PixelCanvas> createState() => _PixelCanvasState();
}

class _PixelCanvasState extends State<PixelCanvas> {
  final imageCache = LayerImageCache();

  @override
  void dispose() {
    imageCache.dispose();
    super.dispose();
  }

  PixelPoint _toPixel(Offset position) => PixelPoint(
    x: (position.dx / widget.zoom).floor(),
    y: (position.dy / widget.zoom).floor(),
  );

  PointerButton _toButton(int buttons) => buttons & kSecondaryMouseButton != 0
      ? PointerButton.secondary
      : PointerButton.primary;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onExit: (_) => widget.onPointerExit(),
      child: Listener(
        onPointerDown: (event) => widget.onPointerDown(
          point: _toPixel(event.localPosition),
          button: _toButton(event.buttons),
        ),
        onPointerHover: (event) =>
            widget.onPointerMove(point: _toPixel(event.localPosition)),
        onPointerMove: (event) =>
            widget.onPointerMove(point: _toPixel(event.localPosition)),
        onPointerUp: (event) =>
            widget.onPointerUp(point: _toPixel(event.localPosition)),
        onPointerCancel: (event) =>
            widget.onPointerUp(point: _toPixel(event.localPosition)),
        child: ClipRect(
          child: CustomPaint(
            foregroundPainter: SelectionOutlinePainter(
              area: widget.selection,
              zoom: widget.zoom,
            ),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: const ChessGridPainter(),
                    size: Size(
                      widget.width * widget.zoom.toDouble(),
                      widget.height * widget.zoom.toDouble(),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      foregroundPainter: PixelLayersPainter(
                        layers: widget.layers,
                        zoom: widget.zoom,
                        imageCache: imageCache,
                        repaint: widget.layersChanged,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      foregroundPainter: PointerPreviewPainter(
                        preview: widget.pointerPreview,
                        zoom: widget.zoom,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PixelLayersPainter extends CustomPainter {
  const PixelLayersPainter({
    required this.layers,
    required this.zoom,
    required this.imageCache,
    super.repaint,
  });

  final List<CanvasLayer> layers;
  final int zoom;
  final LayerImageCache imageCache;

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
    paintArea(canvas: canvas, pixels: pixels, area: pixels.bounds, zoom: zoom);
  }

  static void paintArea({
    required Canvas canvas,
    required Layer pixels,
    required PixelRectangle area,
    required int zoom,
  }) {
    final clipped = area.intersection(pixels.bounds);
    for (var y = clipped.top; y < clipped.bottom; y++) {
      _paintRow(
        canvas: canvas,
        pixels: pixels,
        y: y,
        left: clipped.left,
        right: clipped.right,
        zoom: zoom,
      );
    }
  }

  static void _paintRow({
    required Canvas canvas,
    required Layer pixels,
    required int y,
    required int left,
    required int right,
    required int zoom,
  }) {
    var runStart = left;
    for (var x = left + 1; x <= right; x++) {
      final runColor = pixels.getPixel(PixelPoint(x: runStart, y: y));
      if (x < right && pixels.getPixel(PixelPoint(x: x, y: y)) == runColor) {
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
    imageCache.retainOnly([for (final layer in layers) layer.image]);
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
      _paintTiles(canvas: canvas, tiles: imageCache.tilesOf(layer.image));
      if (composited) canvas.restore();
    }
  }

  void _paintTiles({required Canvas canvas, required List<LayerTile> tiles}) {
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    for (final tile in tiles) {
      final area = tile.area;
      canvas.drawImageRect(
        tile.image,
        Rect.fromLTWH(0, 0, area.width.toDouble(), area.height.toDouble()),
        Rect.fromLTWH(
          area.left * zoom.toDouble(),
          area.top * zoom.toDouble(),
          area.width * zoom.toDouble(),
          area.height * zoom.toDouble(),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PixelLayersPainter oldDelegate) =>
      oldDelegate.zoom != zoom ||
      oldDelegate.imageCache != imageCache ||
      !_sameLayers(oldDelegate.layers);

  bool _sameLayers(List<CanvasLayer> others) {
    if (others.length != layers.length) return false;
    for (var index = 0; index < layers.length; index++) {
      final layer = layers[index];
      final other = others[index];
      if (!identical(other.image, layer.image) ||
          other.opacity != layer.opacity ||
          other.tint != layer.tint) {
        return false;
      }
    }
    return true;
  }
}

class PointerPreviewPainter extends CustomPainter {
  PointerPreviewPainter({required this.preview, required this.zoom})
    : super(repaint: preview);

  final PointerPreview preview;
  final int zoom;

  @override
  void paint(Canvas canvas, Size size) {
    PixelLayersPainter.paintArea(
      canvas: canvas,
      pixels: preview.layer,
      area: preview.area,
      zoom: zoom,
    );
  }

  @override
  bool shouldRepaint(PointerPreviewPainter oldDelegate) =>
      oldDelegate.preview != preview || oldDelegate.zoom != zoom;
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
