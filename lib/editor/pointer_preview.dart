import 'package:flutter/foundation.dart';

import 'canvas/layer.dart';
import 'canvas/pixel_color.dart';
import 'canvas/pixel_point.dart';
import 'canvas/pixel_rectangle.dart';
import 'tools/tool.dart';

class PointerPreview extends ChangeNotifier {
  PointerPreview({required Layer layer}) : _layer = layer;

  factory PointerPreview.sized({required int width, required int height}) {
    return PointerPreview(
      layer: Layer.filled(
        width: width,
        height: height,
        color: PixelColor.transparent,
      ),
    );
  }

  static const _noArea = PixelRectangle(left: 0, top: 0, width: 0, height: 0);

  Layer _layer;
  var _area = _noArea;
  PixelPoint? _cursor;

  Layer get layer => _layer;
  PixelRectangle get area => _area;
  PixelPoint? get cursor => _cursor;

  void draw({
    required Tool? tool,
    required PixelPoint point,
    required PixelColor color,
  }) {
    _erase();
    _area =
        tool?.drawPointer(layer: layer, point: point, color: color) ?? _noArea;
    _cursor = layer.contains(point) ? point : null;
    notifyListeners();
  }

  void clear() {
    _erase();
    _area = _noArea;
    _cursor = null;
    notifyListeners();
  }

  void resize({required int width, required int height}) {
    if (width == _layer.width && height == _layer.height) return;
    _layer = Layer.filled(
      width: width,
      height: height,
      color: PixelColor.transparent,
    );
    _area = _noArea;
    _cursor = null;
    notifyListeners();
  }

  void _erase() {
    layer.fillRectangle(rectangle: _area, color: PixelColor.transparent);
  }
}
