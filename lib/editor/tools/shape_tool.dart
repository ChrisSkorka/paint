import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import 'brush_tip.dart';
import 'pen.dart';
import 'shape.dart';
import 'tool.dart';

class ShapeTool implements Tool {
  const ShapeTool({
    required this.shape,
    required this.width,
    required this.tip,
    required this.origin,
    required this.constrained,
    required this.centered,
    required this.outlined,
    required this.fillColor,
  });

  final Shape shape;
  final int width;
  final BrushTip tip;
  final PixelPoint? origin;
  final bool constrained;
  final bool centered;
  final bool outlined;
  final PixelColor? fillColor;

  @override
  PixelRectangle start({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _emptyAt(point);
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
    return _draw(layer: layer, point: point, color: color);
  }

  @override
  PixelRectangle drawPointer({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    if (origin == null) {
      return Pen(
        size: width,
        tip: tip,
      ).drawPointer(layer: layer, point: point, color: color);
    }
    return _draw(layer: layer, point: point, color: color);
  }

  PixelRectangle _draw({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    final start = origin ?? point;
    final to = constrained ? shape.constrain(from: start, to: point) : point;
    final from = centered
        ? PixelPoint(x: 2 * start.x - to.x, y: 2 * start.y - to.y)
        : start;
    return shape.draw(
      layer: layer,
      from: from,
      to: to,
      width: width,
      tip: tip,
      color: color,
      outlined: outlined,
      fillColor: fillColor,
    );
  }

  PixelRectangle _emptyAt(PixelPoint point) =>
      PixelRectangle(left: point.x, top: point.y, width: 0, height: 0);
}
