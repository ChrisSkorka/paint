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
    this.onRightClick,
    this.dropdown,
    this.onSecondaryPressed,
    this.secondaryIcon = FontAwesomeIcons.angleDown,
    this.secondaryTooltip,
    this.secondaryOnHover = false,
    this.secondaryPlaceholder,
    this.color = PaintStyle.iconColor,
    this.iconShadows,
    this.selected = false,
  });

  final FaIconData icon;
  final Widget? trailing;
  final String tooltip;
  final String? shortcut;
  final VoidCallback? onPressed;
  final VoidCallback? onRightClick;
  final Widget? dropdown;
  final VoidCallback? onSecondaryPressed;
  final FaIconData secondaryIcon;
  final String? secondaryTooltip;
  final bool secondaryOnHover;
  final Widget? secondaryPlaceholder;
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
    final enabled = widget.onPressed != null;
    final highlighted = widget.selected || (enabled && hovered);
    final button = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
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
                onSecondaryTap: enabled ? widget.onRightClick : null,
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
            _buildSecondary(highlighted: highlighted, enabled: enabled),
          ],
        ),
      ),
    );
    return enabled ? button : Opacity(opacity: 0.4, child: button);
  }

  Widget _buildSecondary({required bool highlighted, required bool enabled}) {
    final dropdown = widget.dropdown;
    final button = Tooltip(
      message: widget.secondaryTooltip ?? '${widget.tooltip} options',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: switch ((enabled, dropdown)) {
          (false, _) => null,
          (true, null) => widget.onSecondaryPressed,
          (true, _) =>
            () => menuController.isOpen
                ? menuController.close()
                : menuController.open(),
        },
        child: HighlightBox(
          highlighted: highlighted,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(5),
          ),
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: _buildSecondaryContent(),
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

  Widget _buildSecondaryContent() {
    final iconShown = hovered || !widget.secondaryOnHover;
    final icon = Opacity(
      opacity: iconShown ? 1 : 0,
      child: FaIcon(widget.secondaryIcon, size: 12),
    );
    final placeholder = widget.secondaryPlaceholder;
    if (placeholder == null) return icon;
    return Stack(
      alignment: Alignment.center,
      children: [
        icon,
        Opacity(opacity: iconShown ? 0 : 1, child: placeholder),
      ],
    );
  }
}
