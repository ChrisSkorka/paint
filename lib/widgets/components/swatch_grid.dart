import 'package:flutter/material.dart';

import 'paint_style.dart';

class SwatchGrid extends StatelessWidget {
  const SwatchGrid({super.key, required this.colors, required this.onSelect});

  final List<List<Color>> colors;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) {
    final lastRow = colors.length - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 1,
      children: [
        for (final (rowIndex, row) in colors.indexed)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 1,
            children: [
              for (final (columnIndex, color) in row.indexed)
                Swatch(
                  color: color,
                  onSelect: onSelect,
                  borderRadius: BorderRadius.only(
                    topLeft: _corner(rowIndex == 0 && columnIndex == 0),
                    topRight: _corner(
                      rowIndex == 0 && columnIndex == row.length - 1,
                    ),
                    bottomLeft: _corner(
                      rowIndex == lastRow && columnIndex == 0,
                    ),
                    bottomRight: _corner(
                      rowIndex == lastRow && columnIndex == row.length - 1,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Radius _corner(bool rounded) =>
      rounded ? const Radius.circular(5) : Radius.zero;
}

class Swatch extends StatefulWidget {
  const Swatch({
    super.key,
    required this.color,
    required this.onSelect,
    required this.borderRadius,
  });

  final Color color;
  final ValueChanged<Color> onSelect;
  final BorderRadius borderRadius;

  @override
  State<Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<Swatch> {
  OverlayEntry? hoverEntry;

  @override
  void dispose() {
    _removeHover();
    super.dispose();
  }

  void _showHover() {
    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context);
    final origin = box.localToGlobal(
      Offset.zero,
      ancestor: overlay.context.findRenderObject(),
    );
    hoverEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: origin.dx,
        top: origin.dy,
        width: PaintStyle.swatchSize,
        height: PaintStyle.swatchSize,
        child: IgnorePointer(
          child: Transform.scale(
            scale: 1.8,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: PaintStyle.focusShadow,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(hoverEntry!);
  }

  void _removeHover() {
    hoverEntry?.remove();
    hoverEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _showHover(),
      onExit: (_) => _removeHover(),
      child: GestureDetector(
        onTap: () => widget.onSelect(widget.color),
        child: Container(
          width: PaintStyle.swatchSize,
          height: PaintStyle.swatchSize,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}

class ColorWell extends StatelessWidget {
  const ColorWell({
    super.key,
    required this.color,
    required this.tooltip,
    this.selected = false,
    this.onPressed,
  });

  final Color color;
  final String tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            border: Border.all(
              color: selected
                  ? PaintStyle.inputFocusBorder
                  : Colors.transparent,
            ),
          ),
          child: Container(
            width: 40,
            height: 26,
            decoration: BoxDecoration(
              color: color,
              borderRadius: PaintStyle.radius,
              border: Border.all(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
