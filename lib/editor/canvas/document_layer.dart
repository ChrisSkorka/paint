import 'dart:math';

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

  factory DocumentLayer.merged({
    required DocumentLayer bottom,
    required DocumentLayer top,
  }) {
    final frames = max(bottom.images.length, top.images.length);
    return bottom.copyWith(
      images: [
        for (var frame = 0; frame < frames; frame++)
          Layer.copyOf(bottom.imageAt(frame))..blend(
            source: top.imageAt(frame),
            opacity: top.opacity / maximumOpacity,
          ),
      ],
      timeframe:
          bottom.timeframe == LayerTimeframe.perFrame ||
              top.timeframe == LayerTimeframe.perFrame
          ? LayerTimeframe.perFrame
          : LayerTimeframe.constant,
    );
  }

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
    String? name,
    List<Layer>? images,
    LayerTimeframe? timeframe,
    bool? visible,
    int? opacity,
  }) {
    return DocumentLayer(
      name: name ?? this.name,
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
