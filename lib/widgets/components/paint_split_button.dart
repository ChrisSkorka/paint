import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_icon_button.dart';
import 'paint_style.dart';

class PaintSplitButton extends StatefulWidget {
  const PaintSplitButton({
    super.key,
    required this.icon,
    this.trailing,
    required this.tooltip,
    this.shortcut,
    required this.onPressed,
    this.dropdown,
    this.onSecondaryPressed,
    this.secondaryIcon = FontAwesomeIcons.angleDown,
    this.secondaryTooltip,
    this.secondaryOnHover = false,
    this.color = PaintStyle.iconColor,
    this.iconShadows,
    this.selected = false,
  });

  final FaIconData icon;
  final Widget? trailing;
  final String tooltip;
  final String? shortcut;
  final VoidCallback onPressed;
  final Widget? dropdown;
  final VoidCallback? onSecondaryPressed;
  final FaIconData secondaryIcon;
  final String? secondaryTooltip;
  final bool secondaryOnHover;
  final Color color;
  final List<Shadow>? iconShadows;
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
              message: shortcutTooltip(
                tooltip: widget.tooltip,
                shortcut: widget.shortcut,
              ),
              waitDuration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: widget.onPressed,
                child: HighlightBox(
                  highlighted: highlighted,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(5),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      FaIcon(
                        widget.icon,
                        color: widget.color,
                        size: 16,
                        shadows: widget.iconShadows,
                      ),
                      ?widget.trailing,
                    ],
                  ),
                ),
              ),
            ),
            _buildSecondary(highlighted: highlighted),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondary({required bool highlighted}) {
    final dropdown = widget.dropdown;
    final button = Tooltip(
      message: widget.secondaryTooltip ?? '${widget.tooltip} options',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: dropdown == null
            ? widget.onSecondaryPressed
            : () => menuController.isOpen
                  ? menuController.close()
                  : menuController.open(),
        child: HighlightBox(
          highlighted: highlighted,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(5),
          ),
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Opacity(
            opacity: hovered || !widget.secondaryOnHover ? 1 : 0,
            child: FaIcon(widget.secondaryIcon, size: 12),
          ),
        ),
      ),
    );
    if (dropdown == null) return button;
    return MenuAnchor(
      controller: menuController,
      alignmentOffset: const Offset(0, 4),
      menuChildren: [dropdown],
      child: button,
    );
  }
}
