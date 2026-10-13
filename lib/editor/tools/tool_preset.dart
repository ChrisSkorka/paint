import '../canvas/pixel_color.dart';
import 'brush_tip.dart';
import 'tool_kind.dart';

class ToolPreset {
  const ToolPreset({required this.kind, this.color, this.size, this.tip});

  factory ToolPreset.configured({
    required ToolKind kind,
    required PixelColor color,
    required int size,
    required BrushTip tip,
  }) {
    return ToolPreset(
      kind: kind,
      color: kind.usesColor ? color : null,
      size: kind.hasSize ? size.clamp(minimumSize, maximumSize) : null,
      tip: kind.hasTip ? tip : null,
    );
  }

  static const minimumSize = 1;
  static const maximumSize = 1000;

  final ToolKind kind;
  final PixelColor? color;
  final int? size;
  final BrushTip? tip;

  @override
  bool operator ==(Object other) =>
      other is ToolPreset &&
      other.kind == kind &&
      other.color == color &&
      other.size == size &&
      other.tip == tip;

  @override
  int get hashCode => Object.hash(kind, color, size, tip);

  @override
  String toString() => 'ToolPreset(${kind.name}, $color, $size, ${tip?.name})';
}
