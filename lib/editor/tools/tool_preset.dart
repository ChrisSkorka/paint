import '../canvas/pixel_color.dart';
import 'brush_tip.dart';
import 'text_format.dart';
import 'tool_kind.dart';

class ToolPreset {
  const ToolPreset({
    required this.kind,
    this.color,
    this.secondaryColor,
    this.size,
    this.tip,
    this.textFormat,
  });

  factory ToolPreset.configured({
    required ToolKind kind,
    required PixelColor color,
    required PixelColor secondaryColor,
    required bool shapeOutlined,
    required bool shapeFilled,
    required int size,
    required BrushTip tip,
    required TextFormat textFormat,
  }) {
    final (usesPrimary, usesSecondary) = switch (kind) {
      _ when !kind.usesColor => (false, false),
      ToolKind.text => (
        textFormat.filled || !textFormat.outlined,
        textFormat.outlined,
      ),
      _ when kind.hasFill => (shapeOutlined || !shapeFilled, shapeFilled),
      _ => (true, false),
    };
    return ToolPreset(
      kind: kind,
      color: usesPrimary ? color : null,
      secondaryColor: usesSecondary ? secondaryColor : null,
      size: kind.hasSize ? size.clamp(minimumSize, maximumSize) : null,
      tip: kind.hasTip ? tip : null,
      textFormat: kind == ToolKind.text
          ? textFormat.copyWith(
              size: textFormat.size.clamp(
                TextFormat.minimumSize,
                TextFormat.maximumSize,
              ),
              filled: usesPrimary,
              outlineWidth: usesSecondary
                  ? textFormat.outlineWidth.clamp(
                      TextFormat.minimumOutlineWidth,
                      TextFormat.maximumOutlineWidth,
                    )
                  : TextFormat.defaultOutlineWidth,
            )
          : null,
    );
  }

  static const minimumSize = 1;
  static const maximumSize = 1000;

  final ToolKind kind;
  final PixelColor? color;
  final PixelColor? secondaryColor;
  final int? size;
  final BrushTip? tip;
  final TextFormat? textFormat;

  @override
  bool operator ==(Object other) =>
      other is ToolPreset &&
      other.kind == kind &&
      other.color == color &&
      other.secondaryColor == secondaryColor &&
      other.size == size &&
      other.tip == tip &&
      other.textFormat == textFormat;

  @override
  int get hashCode =>
      Object.hash(kind, color, secondaryColor, size, tip, textFormat);

  @override
  String toString() =>
      'ToolPreset(${kind.name}, $color, $secondaryColor, $size, ${tip?.name}, $textFormat)';
}
