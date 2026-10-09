import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_style.dart';

class PaintIconButton extends StatefulWidget {
  const PaintIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = PaintStyle.iconColor,
    this.selected = false,
  });

  final FaIconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final bool selected;

  @override
  State<PaintIconButton> createState() => _PaintIconButtonState();
}

class _PaintIconButtonState extends State<PaintIconButton> {
  var hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: HighlightBox(
            highlighted: widget.selected || (enabled && hovered),
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: FaIcon(widget.icon, color: widget.color, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class HighlightBox extends StatelessWidget {
  const HighlightBox({
    super.key,
    required this.highlighted,
    required this.child,
    this.borderRadius = PaintStyle.radius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final bool highlighted;
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PaintStyle.hoverDuration,
      padding: padding,
      decoration: BoxDecoration(
        color: highlighted ? PaintStyle.hoverBackground : Colors.transparent,
        borderRadius: borderRadius,
        border: Border.all(
          color: highlighted ? PaintStyle.hoverBorder : Colors.transparent,
        ),
      ),
      child: child,
    );
  }
}
