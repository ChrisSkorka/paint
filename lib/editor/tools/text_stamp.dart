import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import 'text_format.dart';

class TextStamp {
  const TextStamp({
    required this.text,
    required this.format,
    required this.color,
    required this.outlineColor,
  });

  final String text;
  final TextFormat format;
  final PixelColor color;
  final PixelColor outlineColor;

  Size get extent {
    final painter = _layout(format.style(scale: 1, color: PixelColor.black));
    final extent = _extentOf(painter);
    painter.dispose();
    return extent;
  }

  TextPainter _layout(TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  Size _extentOf(TextPainter painter) => Size(
    max(1, painter.width.ceil() + format.padding * 2).toDouble(),
    max(1, painter.height.ceil() + format.padding * 2).toDouble(),
  );

  Future<Layer> rasterize() async {
    final extent = this.extent;
    final width = extent.width.toInt();
    final height = extent.height.toInt();
    final layer = Layer.filled(
      width: width,
      height: height,
      color: PixelColor.transparent,
    );
    if (format.outlined) {
      layer.composite(
        source: await _rasterize(
          style: format.outlineStyle(scale: 1, color: PixelColor.black),
          color: outlineColor,
          width: width,
          height: height,
        ),
        at: const PixelPoint(x: 0, y: 0),
      );
    }
    if (format.filled) {
      layer.composite(
        source: await _rasterize(
          style: format.style(scale: 1, color: PixelColor.black),
          color: color,
          width: width,
          height: height,
        ),
        at: const PixelPoint(x: 0, y: 0),
      );
    }
    return layer;
  }

  Future<Layer> _rasterize({
    required TextStyle style,
    required PixelColor color,
    required int width,
    required int height,
  }) async {
    final painter = _layout(style);
    final recorder = ui.PictureRecorder();
    final padding = format.padding.toDouble();
    painter.paint(Canvas(recorder), Offset(padding, padding));
    painter.dispose();
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    final bytes = await image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    image.dispose();
    final coverage = bytes!.buffer.asUint8List();
    final rgba = Uint8List(width * height * 4);
    for (var offset = 0; offset < rgba.length; offset += 4) {
      rgba
        ..[offset] = color.red
        ..[offset + 1] = color.green
        ..[offset + 2] = color.blue
        ..[offset + 3] = (coverage[offset + 3] * color.alpha / 0xff).round();
    }
    return Layer(width: width, height: height, rgba: rgba);
  }
}
