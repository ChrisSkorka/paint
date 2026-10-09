import '../canvas/pixel_point.dart';

Iterable<PixelPoint> interpolateLine({
  required PixelPoint start,
  required PixelPoint end,
}) sync* {
  final distanceX = (end.x - start.x).abs();
  final distanceY = -(end.y - start.y).abs();
  final stepX = start.x < end.x ? 1 : -1;
  final stepY = start.y < end.y ? 1 : -1;
  var error = distanceX + distanceY;
  var x = start.x;
  var y = start.y;
  while (true) {
    yield PixelPoint(x: x, y: y);
    if (x == end.x && y == end.y) return;
    final doubledError = 2 * error;
    if (doubledError >= distanceY) {
      error += distanceY;
      x += stepX;
    }
    if (doubledError <= distanceX) {
      error += distanceX;
      y += stepY;
    }
  }
}
