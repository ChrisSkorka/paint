import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import 'brush_tip.dart';
import 'pen.dart';
import 'tool.dart';

class Eraser implements Tool {
  const Eraser({required this.size});

  static const pointerColor = PixelColor(argb: 0x88888888);

  final int size;

  Pen get _pen => Pen(size: size, tip: BrushTip.square);

  @override
  PixelRectangle start({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _pen.start(
      layer: layer,
      point: point,
      color: PixelColor.transparent,
    );
  }

  @override
  PixelRectangle stroke({
    required Layer layer,
    required PixelPoint previous,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _pen.stroke(
      layer: layer,
      previous: previous,
      point: point,
      color: PixelColor.transparent,
    );
  }

  @override
  PixelRectangle end({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _pen.end(layer: layer, point: point, color: PixelColor.transparent);
  }

  @override
  PixelRectangle drawPointer({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  }) {
    return _pen.drawPointer(layer: layer, point: point, color: pointerColor);
  }
}
