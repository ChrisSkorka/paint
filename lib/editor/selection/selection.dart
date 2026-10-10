import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import '../history/layer_snapshot.dart';

class Selection {
  const Selection({
    required this.area,
    required this.content,
    required this.background,
  });

  factory Selection.lift({required Layer layer, required PixelRectangle area}) {
    final background = Layer.copyOf(layer);
    background.fillRectangle(rectangle: area, color: PixelColor.transparent);
    return Selection(
      area: area,
      content: Layer.cropped(layer: layer, area: area),
      background: background,
    );
  }

  final PixelRectangle area;
  final Layer content;
  final Layer background;

  Selection moved({
    required Layer layer,
    required int offsetX,
    required int offsetY,
  }) {
    return _placed(
      layer: layer,
      area: PixelRectangle(
        left: area.left + offsetX,
        top: area.top + offsetY,
        width: area.width,
        height: area.height,
      ),
      content: content,
    );
  }

  Selection rotated({required Layer layer, required bool clockwise}) {
    return _placed(
      layer: layer,
      area: PixelRectangle(
        left: area.left + (area.width - area.height) ~/ 2,
        top: area.top + (area.height - area.width) ~/ 2,
        width: area.height,
        height: area.width,
      ),
      content: Layer.rotated(layer: content, clockwise: clockwise),
    );
  }

  Selection mirrored({required Layer layer, required bool horizontally}) {
    return _placed(
      layer: layer,
      area: area,
      content: Layer.mirrored(layer: content, horizontally: horizontally),
    );
  }

  Selection _placed({
    required Layer layer,
    required PixelRectangle area,
    required Layer content,
  }) {
    LayerSnapshot.capture(layer: background, area: this.area).restore(layer);
    layer.paste(
      source: content,
      at: PixelPoint(x: area.left, y: area.top),
    );
    return Selection(area: area, content: content, background: background);
  }
}
