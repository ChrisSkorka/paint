import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';

enum BrushTip {
  square,
  circle;

  PixelRectangle area({required PixelPoint center, required int size}) {
    return PixelRectangle(
      left: center.x - size ~/ 2,
      top: center.y - size ~/ 2,
      width: size,
      height: size,
    );
  }

  PixelRectangle stamp({
    required Layer layer,
    required PixelPoint center,
    required int size,
    required PixelColor color,
  }) {
    final stampArea = area(center: center, size: size);
    switch (this) {
      case BrushTip.square:
        layer.fillRectangle(rectangle: stampArea, color: color);
      case BrushTip.circle:
        _stampCircle(layer: layer, stampArea: stampArea, color: color);
    }
    return stampArea.intersection(layer.bounds);
  }

  void _stampCircle({
    required Layer layer,
    required PixelRectangle stampArea,
    required PixelColor color,
  }) {
    final radius = stampArea.width / 2;
    final centerX = stampArea.left + radius;
    final centerY = stampArea.top + radius;
    for (var y = stampArea.top; y < stampArea.bottom; y++) {
      for (var x = stampArea.left; x < stampArea.right; x++) {
        final offsetX = x + 0.5 - centerX;
        final offsetY = y + 0.5 - centerY;
        if (offsetX * offsetX + offsetY * offsetY <= radius * radius) {
          layer.setPixel(
            point: PixelPoint(x: x, y: y),
            color: color,
          );
        }
      }
    }
  }
}
