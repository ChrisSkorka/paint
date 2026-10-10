import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import 'shape.dart';
import 'tool.dart';

class ShapeTool implements Tool {
  const ShapeTool({
    required this.shape,
    required this.width,
    required this.origin,
  });

  final Shape shape;
  final int width;
  final PixelPoint? origin;

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
    return _draw(layer: layer, point: point, color: color);
  }

  PixelRectangle _draw({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return shape.draw(
      layer: layer,
      from: origin ?? point,
      to: point,
      width: width,
      color: color,
    );
  }

  PixelRectangle _emptyAt(PixelPoint point) =>
      PixelRectangle(left: point.x, top: point.y, width: 0, height: 0);
}
