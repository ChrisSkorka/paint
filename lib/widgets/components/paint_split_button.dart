import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_icon_button.dart';
import 'paint_style.dart';

class PaintSplitButton extends StatefulWidget {
  const PaintSplitButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.dropdown,
    this.color = PaintStyle.iconColor,
    this.selected = false,
  });

  final FaIconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Widget dropdown;
  final Color color;
  final bool selected;

  @override
  State<PaintSplitButton> createState() => _PaintSplitButtonState();
}

class _PaintSplitButtonState extends State<PaintSplitButton> {
  final menuController = MenuController();
  var hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.selected || hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tooltip(
              message: widget.tooltip,
              waitDuration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: widget.onPressed,
                child: HighlightBox(
                  highlighted: highlighted,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(5),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  child: FaIcon(widget.icon, color: widget.color, size: 16),
                ),
              ),
            ),
            MenuAnchor(
              controller: menuController,
              alignmentOffset: const Offset(0, 4),
              menuChildren: [widget.dropdown],
              child: Tooltip(
                message: '${widget.tooltip} options',
                waitDuration: const Duration(milliseconds: 500),
                child: GestureDetector(
                  onTap: () => menuController.isOpen
                      ? menuController.close()
                      : menuController.open(),
                  child: HighlightBox(
                    highlighted: highlighted,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(5),
                    ),
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child: const FaIcon(FontAwesomeIcons.angleDown, size: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
