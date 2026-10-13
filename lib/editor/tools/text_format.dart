import 'package:flutter/painting.dart';

import '../canvas/pixel_color.dart';

class TextFormat {
  const TextFormat({
    this.size = defaultSize,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.filled = true,
    this.outlined = false,
    this.outlineWidth = defaultOutlineWidth,
  });

  static const fontFamily = 'Arial';
  static const lineHeight = 1.2;
  static const defaultSize = 12;
  static const minimumSize = 1;
  static const maximumSize = 500;
  static const defaultOutlineWidth = 1;
  static const minimumOutlineWidth = 1;
  static const maximumOutlineWidth = 50;

  final int size;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool filled;
  final bool outlined;
  final int outlineWidth;

  int get padding => outlined ? outlineWidth : 0;

  TextStyle style({required double scale, required PixelColor color}) =>
      _style(scale: scale, color: Color(color.argb));

  TextStyle outlineStyle({required double scale, required PixelColor color}) =>
      _style(
        scale: scale,
        decorationColor: Color(color.argb),
        foreground: Paint()
          ..color = Color(color.argb)
          ..style = PaintingStyle.stroke
          ..strokeWidth = outlineWidth * 2 * scale
          ..strokeJoin = StrokeJoin.round,
      );

  TextStyle _style({
    required double scale,
    Color? color,
    Color? decorationColor,
    Paint? foreground,
  }) => TextStyle(
    color: color,
    foreground: foreground,
    fontFamily: fontFamily,
    fontSize: size * scale,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    decoration: TextDecoration.combine([
      if (underline) TextDecoration.underline,
      if (strikethrough) TextDecoration.lineThrough,
    ]),
    decorationColor: decorationColor ?? color,
    height: lineHeight,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  TextFormat copyWith({
    int? size,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? filled,
    bool? outlined,
    int? outlineWidth,
  }) {
    return TextFormat(
      size: size ?? this.size,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      filled: filled ?? this.filled,
      outlined: outlined ?? this.outlined,
      outlineWidth: outlineWidth ?? this.outlineWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TextFormat &&
      other.size == size &&
      other.bold == bold &&
      other.italic == italic &&
      other.underline == underline &&
      other.strikethrough == strikethrough &&
      other.filled == filled &&
      other.outlined == outlined &&
      other.outlineWidth == outlineWidth;

  @override
  int get hashCode => Object.hash(
    size,
    bold,
    italic,
    underline,
    strikethrough,
    filled,
    outlined,
    outlineWidth,
  );

  @override
  String toString() =>
      'TextFormat(size: $size, bold: $bold, italic: $italic, underline: $underline, strikethrough: $strikethrough, filled: $filled, outlined: $outlined, outline width: $outlineWidth)';
}
