import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/editor_shortcut.dart';
import 'horizontal_scroll_view.dart';
import 'paint_icon_button.dart';
import 'paint_style.dart';

typedef DocumentTabLabel = ({String title, bool unsaved});

class DocumentTabBar extends StatelessWidget {
  const DocumentTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
    required this.onClose,
    required this.onAdd,
  });

  static const tabWidth = 180.0;
  static const tabHeight = 32.0;

  final List<DocumentTabLabel> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onClose;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PaintStyle.tabStripBackground,
        border: Border(bottom: BorderSide(color: PaintStyle.separatorColor)),
      ),
      alignment: Alignment.centerLeft,
      child: HorizontalScrollView(
        padding: const EdgeInsets.only(left: 4, top: 4),
        child: Row(
          spacing: 2,
          children: [
            for (final (index, tab) in tabs.indexed)
              _DocumentTab(
                label: tab,
                selected: index == selectedIndex,
                onSelect: () => onSelect(index),
                onClose: () => onClose(index),
              ),
            PaintIconButton(
              icon: FontAwesomeIcons.plus,
              tooltip: EditorShortcut.newTab.label,
              shortcut: EditorShortcut.newTab.keys,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTab extends StatefulWidget {
  const _DocumentTab({
    required this.label,
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });

  final DocumentTabLabel label;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  @override
  State<_DocumentTab> createState() => _DocumentTabState();
}

class _DocumentTabState extends State<_DocumentTab> {
  var hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label.title,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onSelect,
          onTertiaryTapUp: (_) => widget.onClose(),
          child: AnimatedContainer(
            duration: PaintStyle.hoverDuration,
            width: DocumentTabBar.tabWidth,
            height: DocumentTabBar.tabHeight,
            padding: const EdgeInsets.only(left: 12, right: 4),
            decoration: BoxDecoration(
              color: widget.selected
                  ? PaintStyle.barBackground
                  : hovered
                  ? PaintStyle.tabHoverBackground
                  : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
            ),
            child: Row(
              spacing: 6,
              children: [
                Expanded(
                  child: Text(
                    widget.label.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.selected
                          ? PaintStyle.iconColor
                          : PaintStyle.titleColor,
                      fontWeight: widget.selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (widget.label.unsaved)
                  const Tooltip(
                    message: 'Unsaved changes',
                    child: FaIcon(
                      FontAwesomeIcons.solidCircle,
                      size: 8,
                      color: PaintStyle.iconColor,
                    ),
                  ),
                _TabCloseButton(onPressed: widget.onClose),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabCloseButton extends StatefulWidget {
  const _TabCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_TabCloseButton> createState() => _TabCloseButtonState();
}

class _TabCloseButtonState extends State<_TabCloseButton> {
  var hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Close tab',
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: HighlightBox(
            highlighted: hovered,
            padding: const EdgeInsets.all(4),
            child: const FaIcon(
              FontAwesomeIcons.xmark,
              size: 12,
              color: PaintStyle.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
