import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import 'brush_tip.dart';
import 'pen.dart';
import 'tool.dart';

class BucketFill implements Tool {
  const BucketFill();

  static const _pointerPen = Pen(size: 1, tip: BrushTip.square);

  @override
  PixelRectangle start({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    if (!layer.contains(point)) return _emptyAt(point);
    final target = layer.getPixel(point);
    if (target == color) return _emptyAt(point);
    var filled = _emptyAt(point);
    final pending = [point];
    while (pending.isNotEmpty) {
      final seed = pending.removeLast();
      if (layer.getPixel(seed) != target) continue;
      var left = seed.x;
      while (left > 0 &&
          _matches(layer: layer, x: left - 1, y: seed.y, target: target)) {
        left--;
      }
      var right = seed.x + 1;
      while (right < layer.width &&
          _matches(layer: layer, x: right, y: seed.y, target: target)) {
        right++;
      }
      final span = PixelRectangle.fromEdges(
        left: left,
        top: seed.y,
        right: right,
        bottom: seed.y + 1,
      );
      layer.fillRectangle(rectangle: span, color: color);
      filled = filled.union(span);
      for (final neighbourY in [seed.y - 1, seed.y + 1]) {
        if (neighbourY < 0 || neighbourY >= layer.height) continue;
        pending.addAll(
          _spanStarts(
            layer: layer,
            y: neighbourY,
            left: left,
            right: right,
            target: target,
          ),
        );
      }
    }
    return filled;
  }

  @override
  PixelRectangle stroke({
    required Layer layer,
    required PixelPoint previous,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _emptyAt(point);
  }

  @override
  PixelRectangle end({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _emptyAt(point);
  }

  @override
  PixelRectangle drawPointer({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _pointerPen.drawPointer(layer: layer, point: point, color: color);
  }

  Iterable<PixelPoint> _spanStarts({
    required Layer layer,
    required int y,
    required int left,
    required int right,
    required PixelColor target,
  }) sync* {
    var previousMatched = false;
    for (var x = left; x < right; x++) {
      final matched = _matches(layer: layer, x: x, y: y, target: target);
      if (matched && !previousMatched) yield PixelPoint(x: x, y: y);
      previousMatched = matched;
    }
  }

  bool _matches({
    required Layer layer,
    required int x,
    required int y,
    required PixelColor target,
  }) => layer.getPixel(PixelPoint(x: x, y: y)) == target;

  PixelRectangle _emptyAt(PixelPoint point) =>
      PixelRectangle(left: point.x, top: point.y, width: 0, height: 0);
}
