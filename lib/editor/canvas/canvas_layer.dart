import 'document_layer.dart';
import 'layer.dart';
import 'pixel_color.dart';

class CanvasLayer {
  const CanvasLayer({
    required this.image,
    this.opacity = DocumentLayer.maximumOpacity,
    this.tint,
  });

  final Layer image;
  final int opacity;
  final PixelColor? tint;

  @override
  bool operator ==(Object other) =>
      other is CanvasLayer &&
      other.image == image &&
      other.opacity == opacity &&
      other.tint == tint;

  @override
  int get hashCode => Object.hash(image, opacity, tint);

  @override
  String toString() => 'CanvasLayer($image, opacity: $opacity, tint: $tint)';
}
