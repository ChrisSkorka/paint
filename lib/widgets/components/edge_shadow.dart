import 'package:flutter/material.dart';

import 'paint_style.dart';

class EdgeShadowPainter extends CustomPainter {
  const EdgeShadowPainter();

  static const extent = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTRB(-extent, -extent, size.width + extent, 0))
        ..addRect(
          Rect.fromLTRB(
            size.width,
            -extent,
            size.width + extent,
            size.height + extent,
          ),
        ),
      PaintStyle.barShadow.first.toPaint(),
    );
  }

  @override
  bool shouldRepaint(EdgeShadowPainter oldDelegate) => false;
}
