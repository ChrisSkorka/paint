import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_icon_button.dart';
import 'paint_style.dart';

class PaintWideButton extends StatefulWidget {
  const PaintWideButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = PaintStyle.iconColor,
  });

  final String label;
  final FaIconData icon;
  final VoidCallback? onPressed;
  final Color color;

  @override
  State<PaintWideButton> createState() => _PaintWideButtonState();
}

class _PaintWideButtonState extends State<PaintWideButton> {
  var hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: HighlightBox(
          highlighted: enabled && hovered,
          child: Opacity(
            opacity: enabled ? 1 : 0.4,
            child: Row(
              children: [
                Expanded(child: Text(widget.label)),
                FaIcon(widget.icon, color: widget.color, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
