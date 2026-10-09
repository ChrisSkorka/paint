import 'package:flutter/material.dart';

import 'paint_style.dart';

class ChessGridPainter extends CustomPainter {
  const ChessGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = PaintStyle.chessLight);
    final dark = Paint()..color = PaintStyle.chessDark;
    const cell = PaintStyle.chessCellSize;
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = y % 2; x * cell < size.width; x += 2) {
        canvas.drawRect(
          Rect.fromLTWH(
            x * cell,
            y * cell,
            cell,
            cell,
          ).intersect(Offset.zero & size),
          dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ChessGridPainter oldDelegate) => false;
}
