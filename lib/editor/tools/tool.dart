import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';

abstract interface class Tool {
  PixelRectangle start({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  });

  PixelRectangle stroke({
    required Layer layer,
    required PixelPoint previous,
    required PixelPoint point,
    required PixelColor color,
  });

  PixelRectangle end({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  });

  PixelRectangle drawPointer({
    required Layer layer,
    required PixelPoint point,
    required PixelColor color,
  });
}
