import 'package:flutter/material.dart';

import 'paint_icon_button.dart';

class PaintStatusButton extends StatefulWidget {
  const PaintStatusButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  static const sectionPadding = EdgeInsets.symmetric(vertical: 4);
  static const padding = EdgeInsets.symmetric(horizontal: 4);

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<PaintStatusButton> createState() => _PaintStatusButtonState();
}

class _PaintStatusButtonState extends State<PaintStatusButton> {
  var hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: HighlightBox(
            highlighted: hovered,
            padding: PaintStatusButton.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
