import 'pixel_color.dart';

class OnionSkin {
  const OnionSkin({
    this.enabled = false,
    this.previous = true,
    this.next = true,
    this.frameCount = 1,
    this.activeLayerOnly = false,
  });

  static const minimumFrameCount = 1;
  static const maximumFrameCount = 5;
  static const previousTint = PixelColor(argb: 0xFFFF0000);
  static const nextTint = PixelColor(argb: 0xFF00FF00);

  final bool enabled;
  final bool previous;
  final bool next;
  final int frameCount;
  final bool activeLayerOnly;

  OnionSkin copyWith({
    bool? enabled,
    bool? previous,
    bool? next,
    int? frameCount,
    bool? activeLayerOnly,
  }) {
    return OnionSkin(
      enabled: enabled ?? this.enabled,
      previous: previous ?? this.previous,
      next: next ?? this.next,
      frameCount: frameCount ?? this.frameCount,
      activeLayerOnly: activeLayerOnly ?? this.activeLayerOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OnionSkin &&
      other.enabled == enabled &&
      other.previous == previous &&
      other.next == next &&
      other.frameCount == frameCount &&
      other.activeLayerOnly == activeLayerOnly;

  @override
  int get hashCode =>
      Object.hash(enabled, previous, next, frameCount, activeLayerOnly);

  @override
  String toString() =>
      'OnionSkin(enabled: $enabled, previous: $previous, next: $next, frames: $frameCount, active layer only: $activeLayerOnly)';
}
