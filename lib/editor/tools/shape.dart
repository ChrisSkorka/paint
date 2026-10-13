import 'dart:math';

import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import 'brush_tip.dart';
import 'pen.dart';

enum Shape {
  line,
  rectangle,
  ellipse,
  arrow;

  PixelRectangle draw({
    required Layer layer,
    required PixelPoint from,
    required PixelPoint to,
    required int width,
    required BrushTip tip,
    required PixelColor color,
  }) {
    final box = BrushTip.square
        .area(center: from, size: width)
        .union(BrushTip.square.area(center: to, size: width));
    switch (this) {
      case Shape.line:
        return _drawLine(
          layer: layer,
          from: from,
          to: to,
          width: width,
          tip: tip,
          color: color,
        );
      case Shape.arrow:
        return _drawArrow(
          layer: layer,
          from: from,
          to: to,
          width: width,
          tip: tip,
          color: color,
        );
      case Shape.rectangle when tip == BrushTip.circle:
        return _drawRoundedRectangle(
          layer: layer,
          box: box,
          width: width,
          color: color,
        );
      case Shape.rectangle:
        _drawRectangle(layer: layer, box: box, width: width, color: color);
      case Shape.ellipse:
        _drawEllipse(layer: layer, box: box, width: width, color: color);
    }
    return box.intersection(layer.bounds);
  }

  PixelPoint constrain({required PixelPoint from, required PixelPoint to}) {
    final deltaX = to.x - from.x;
    final deltaY = to.y - from.y;
    final (directionX, directionY) = switch (this) {
      Shape.line ||
      Shape.arrow => _nearestDirection(deltaX: deltaX, deltaY: deltaY),
      Shape.rectangle ||
      Shape.ellipse => (deltaX < 0 ? -1 : 1, deltaY < 0 ? -1 : 1),
    };
    final length = max(
      deltaX.abs() * directionX.abs(),
      deltaY.abs() * directionY.abs(),
    );
    return PixelPoint(
      x: from.x + directionX * length,
      y: from.y + directionY * length,
    );
  }

  (int, int) _nearestDirection({required int deltaX, required int deltaY}) {
    final angle = (atan2(deltaY, deltaX) / (pi / 4)).round() * (pi / 4);
    return (cos(angle).round(), sin(angle).round());
  }

  PixelRectangle _drawLine({
    required Layer layer,
    required PixelPoint from,
    required PixelPoint to,
    required int width,
    required BrushTip tip,
    required PixelColor color,
  }) {
    return Pen(
      size: width,
      tip: tip,
    ).stroke(layer: layer, previous: from, point: to, color: color);
  }

  PixelRectangle _drawArrow({
    required Layer layer,
    required PixelPoint from,
    required PixelPoint to,
    required int width,
    required BrushTip tip,
    required PixelColor color,
  }) {
    final shaft = _drawLine(
      layer: layer,
      from: from,
      to: to,
      width: width,
      tip: tip,
      color: color,
    );
    final backX = (from.x - to.x).toDouble();
    final backY = (from.y - to.y).toDouble();
    final length = sqrt(backX * backX + backY * backY);
    if (length == 0) return shaft;
    final headScale = 3 * width / length;
    return [pi / 4, -pi / 4]
        .map(
          (angle) => PixelPoint(
            x:
                to.x +
                ((backX * cos(angle) - backY * sin(angle)) * headScale).round(),
            y:
                to.y +
                ((backX * sin(angle) + backY * cos(angle)) * headScale).round(),
          ),
        )
        .map(
          (headEnd) => _drawLine(
            layer: layer,
            from: to,
            to: headEnd,
            width: width,
            tip: tip,
            color: color,
          ),
        )
        .fold(shaft, (area, head) => area.union(head));
  }

  void _drawRectangle({
    required Layer layer,
    required PixelRectangle box,
    required int width,
    required PixelColor color,
  }) {
    final bands = [
      PixelRectangle.fromEdges(
        left: box.left,
        top: box.top,
        right: box.right,
        bottom: min(box.top + width, box.bottom),
      ),
      PixelRectangle.fromEdges(
        left: box.left,
        top: max(box.bottom - width, box.top),
        right: box.right,
        bottom: box.bottom,
      ),
      PixelRectangle.fromEdges(
        left: box.left,
        top: box.top,
        right: min(box.left + width, box.right),
        bottom: box.bottom,
      ),
      PixelRectangle.fromEdges(
        left: max(box.right - width, box.left),
        top: box.top,
        right: box.right,
        bottom: box.bottom,
      ),
    ];
    for (final band in bands) {
      layer.fillRectangle(rectangle: band, color: color);
    }
  }

  PixelRectangle _drawRoundedRectangle({
    required Layer layer,
    required PixelRectangle box,
    required int width,
    required PixelColor color,
  }) {
    final left = box.left + width ~/ 2;
    final top = box.top + width ~/ 2;
    final right = box.right - width + width ~/ 2;
    final bottom = box.bottom - width + width ~/ 2;
    final corners = [
      PixelPoint(x: left, y: top),
      PixelPoint(x: right, y: top),
      PixelPoint(x: right, y: bottom),
      PixelPoint(x: left, y: bottom),
    ];
    final pen = Pen(size: width, tip: BrushTip.circle);
    return [
      for (var index = 0; index < corners.length; index++)
        pen.stroke(
          layer: layer,
          previous: corners[index],
          point: corners[(index + 1) % corners.length],
          color: color,
        ),
    ].reduce((area, side) => area.union(side));
  }

  void _drawEllipse({
    required Layer layer,
    required PixelRectangle box,
    required int width,
    required PixelColor color,
  }) {
    final outer = _EllipseBounds.inBox(box: box, inset: 0);
    final inner = _EllipseBounds.inBox(box: box, inset: width);
    final drawn = box.intersection(layer.bounds);
    for (var y = drawn.top; y < drawn.bottom; y++) {
      for (var x = drawn.left; x < drawn.right; x++) {
        final onOutline =
            outer.contains(x: x, y: y) &&
            (!inner.contains(x: x, y: y) ||
                !outer.contains(x: x - 1, y: y) ||
                !outer.contains(x: x + 1, y: y) ||
                !outer.contains(x: x, y: y - 1) ||
                !outer.contains(x: x, y: y + 1));
        if (onOutline) {
          layer.setPixel(
            point: PixelPoint(x: x, y: y),
            color: color,
          );
        }
      }
    }
  }
}

class _EllipseBounds {
  const _EllipseBounds({
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
  });

  factory _EllipseBounds.inBox({
    required PixelRectangle box,
    required int inset,
  }) {
    return _EllipseBounds(
      centerX: box.left + box.width / 2,
      centerY: box.top + box.height / 2,
      radiusX: box.width / 2 - inset,
      radiusY: box.height / 2 - inset,
    );
  }

  final double centerX;
  final double centerY;
  final double radiusX;
  final double radiusY;

  bool contains({required int x, required int y}) {
    if (radiusX <= 0 || radiusY <= 0) return false;
    final offsetX = (x + 0.5 - centerX) / radiusX;
    final offsetY = (y + 0.5 - centerY) / radiusY;
    return offsetX * offsetX + offsetY * offsetY <= 1;
  }
}
