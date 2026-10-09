import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import 'brush_tip.dart';
import 'line_interpolation.dart';
import 'tool.dart';

class Pen implements Tool {
  const Pen({required this.size, required this.tip});

  final int size;
  final BrushTip tip;

  @override
  PixelRectangle start({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return tip.stamp(layer: layer, center: point, size: size, color: color);
  }

  @override
  PixelRectangle stroke({
    required Layer layer,
    required PixelPoint previous,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return interpolateLine(start: previous, end: point)
        .map(
          (linePoint) => tip.stamp(
            layer: layer,
            center: linePoint,
            size: size,
            color: color,
          ),
        )
        .reduce((altered, stamped) => altered.union(stamped));
  }

  @override
  PixelRectangle end({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return PixelRectangle(left: point.x, top: point.y, width: 0, height: 0);
  }

  @override
  PixelRectangle drawPointer({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return tip.stamp(layer: layer, center: point, size: size, color: color);
  }
}
