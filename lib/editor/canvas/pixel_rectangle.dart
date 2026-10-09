import 'dart:math';

import 'pixel_point.dart';

class PixelRectangle {
  const PixelRectangle({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory PixelRectangle.fromEdges({
    required int left,
    required int top,
    required int right,
    required int bottom,
  }) {
    return PixelRectangle(
      left: left,
      top: top,
      width: right - left,
      height: bottom - top,
    );
  }

  final int left;
  final int top;
  final int width;
  final int height;

  int get right => left + width;
  int get bottom => top + height;
  bool get isEmpty => width <= 0 || height <= 0;

  bool contains(PixelPoint point) {
    return point.x >= left &&
        point.x < right &&
        point.y >= top &&
        point.y < bottom;
  }

  PixelRectangle union(PixelRectangle other) {
    if (isEmpty) return other;
    if (other.isEmpty) return this;
    return PixelRectangle.fromEdges(
      left: min(left, other.left),
      top: min(top, other.top),
      right: max(right, other.right),
      bottom: max(bottom, other.bottom),
    );
  }

  PixelRectangle intersection(PixelRectangle other) {
    return PixelRectangle.fromEdges(
      left: max(left, other.left),
      top: max(top, other.top),
      right: max(max(left, other.left), min(right, other.right)),
      bottom: max(max(top, other.top), min(bottom, other.bottom)),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PixelRectangle &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'PixelRectangle($left, $top, $width, $height)';
}
