import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'paint_style.dart';

class ChessGridPainter extends CustomPainter {
  const ChessGridPainter();

  static final _shader = ImageShader(
    _pattern(),
    TileMode.repeated,
    TileMode.repeated,
    Matrix4.identity().storage,
    filterQuality: FilterQuality.none,
  );

  static ui.Image _pattern() {
    const cell = PaintStyle.chessCellSize;
    final dark = Paint()..color = PaintStyle.chessDark;
    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..drawRect(
        const Rect.fromLTWH(0, 0, cell * 2, cell * 2),
        Paint()..color = PaintStyle.chessLight,
      )
      ..drawRect(const Rect.fromLTWH(0, 0, cell, cell), dark)
      ..drawRect(const Rect.fromLTWH(cell, cell, cell, cell), dark);
    final picture = recorder.endRecording();
    final pattern = picture.toImageSync(cell.toInt() * 2, cell.toInt() * 2);
    picture.dispose();
    return pattern;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = _shader);
  }

  @override
  bool shouldRepaint(ChessGridPainter oldDelegate) => false;
}
