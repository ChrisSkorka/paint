import 'dart:math';

import 'package:flutter/material.dart';

import '../../editor/canvas/layer.dart';
import 'chess_grid.dart';
import 'paint_icon_button.dart';
import 'paint_style.dart';
import 'pixel_canvas.dart';

class HistoryListItem {
  const HistoryListItem({
    required this.name,
    required this.thumbnail,
    required this.outline,
  });

  final String name;
  final Layer thumbnail;
  final Rect? outline;
}

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.items,
    required this.position,
    required this.onSelect,
  });

  final List<HistoryListItem> items;
  final int position;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var index = 0; index < items.length; index++)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: HighlightBox(
                highlighted: index == position,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Opacity(
                  opacity: index > position ? 0.4 : 1,
                  child: Row(
                    children: [
                      Expanded(child: Text(items[index].name)),
                      HistoryThumbnail(
                        thumbnail: items[index].thumbnail,
                        outline: items[index].outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HistoryThumbnail extends StatelessWidget {
  const HistoryThumbnail({
    super.key,
    required this.thumbnail,
    required this.outline,
  });

  final Layer thumbnail;
  final Rect? outline;

  @override
  Widget build(BuildContext context) {
    final scale =
        PaintStyle.thumbnailSize / max(thumbnail.width, thumbnail.height);
    return SizedBox.square(
      dimension: PaintStyle.thumbnailSize,
      child: Center(
        child: CustomPaint(
          painter: const ChessGridPainter(),
          foregroundPainter: ThumbnailPainter(
            thumbnail: thumbnail,
            outline: outline,
            scale: scale,
          ),
          size: Size(thumbnail.width * scale, thumbnail.height * scale),
        ),
      ),
    );
  }
}

class ThumbnailPainter extends CustomPainter {
  const ThumbnailPainter({
    required this.thumbnail,
    required this.outline,
    required this.scale,
  });

  final Layer thumbnail;
  final Rect? outline;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);
    PixelLayersPainter.paintPixels(canvas: canvas, pixels: thumbnail, zoom: 1);
    canvas.restore();
    final outline = this.outline;
    if (outline == null) return;
    canvas.drawRect(
      Rect.fromLTRB(
        outline.left * scale,
        outline.top * scale,
        outline.right * scale,
        outline.bottom * scale,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = PaintStyle.changeOutlineColor,
    );
  }

  @override
  bool shouldRepaint(ThumbnailPainter oldDelegate) =>
      !identical(oldDelegate.thumbnail, thumbnail) ||
      oldDelegate.outline != outline ||
      oldDelegate.scale != scale;
}
