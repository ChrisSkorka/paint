import 'layer.dart';

class DocumentLayer {
  const DocumentLayer({
    required this.name,
    required this.pixels,
    this.visible = true,
    this.opacity = maximumOpacity,
  });

  static const minimumOpacity = 0;
  static const maximumOpacity = 100;

  final String name;
  final Layer pixels;
  final bool visible;
  final int opacity;

  DocumentLayer copyWith({bool? visible, int? opacity}) {
    return DocumentLayer(
      name: name,
      pixels: pixels,
      visible: visible ?? this.visible,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DocumentLayer &&
      other.name == name &&
      other.pixels == pixels &&
      other.visible == visible &&
      other.opacity == opacity;

  @override
  int get hashCode => Object.hash(name, pixels, visible, opacity);

  @override
  String toString() =>
      'DocumentLayer($name, visible: $visible, opacity: $opacity)';
}
