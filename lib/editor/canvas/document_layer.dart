import 'package:collection/collection.dart';

import 'layer.dart';
import 'layer_timeframe.dart';

class DocumentLayer {
  const DocumentLayer({
    required this.name,
    required this.images,
    this.timeframe = LayerTimeframe.constant,
    this.visible = true,
    this.opacity = maximumOpacity,
  });

  static const minimumOpacity = 0;
  static const maximumOpacity = 100;

  final String name;
  final List<Layer> images;
  final LayerTimeframe timeframe;
  final bool visible;
  final int opacity;

  Layer imageAt(int frame) => switch (timeframe) {
    LayerTimeframe.constant => images.first,
    LayerTimeframe.perFrame => images[frame],
  };

  DocumentLayer copyWith({
    List<Layer>? images,
    LayerTimeframe? timeframe,
    bool? visible,
    int? opacity,
  }) {
    return DocumentLayer(
      name: name,
      images: images ?? this.images,
      timeframe: timeframe ?? this.timeframe,
      visible: visible ?? this.visible,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DocumentLayer &&
      other.name == name &&
      const ListEquality<Layer>().equals(other.images, images) &&
      other.timeframe == timeframe &&
      other.visible == visible &&
      other.opacity == opacity;

  @override
  int get hashCode => Object.hash(
    name,
    const ListEquality<Layer>().hash(images),
    timeframe,
    visible,
    opacity,
  );

  @override
  String toString() =>
      'DocumentLayer($name, ${timeframe.name}, visible: $visible, opacity: $opacity)';
}
