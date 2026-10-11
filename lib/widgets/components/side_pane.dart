import 'package:flutter/material.dart';

import 'paint_style.dart';
import 'side_panel.dart';

typedef SidePaneEntry = ({String title, Widget child});

class SidePane extends StatefulWidget {
  const SidePane({super.key, required this.panels});

  static const minimumWidth = 160.0;
  static const maximumWidth = 480.0;
  static const handleWidth = 6.0;

  final List<SidePaneEntry> panels;

  @override
  State<SidePane> createState() => _SidePaneState();
}

class _SidePaneState extends State<SidePane> {
  var width = PaintStyle.sidePanelWidth;
  final collapsed = <String>{};

  void _resize(DragUpdateDetails details) => setState(
    () => width = (width - details.delta.dx).clamp(
      SidePane.minimumWidth,
      SidePane.maximumWidth,
    ),
  );

  void _toggle(String title) => setState(
    () => collapsed.contains(title)
        ? collapsed.remove(title)
        : collapsed.add(title),
  );

  @override
  Widget build(BuildContext context) {
    final panels = widget.panels;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            key: const Key('side pane handle'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _resize,
            child: Container(
              width: SidePane.handleWidth,
              decoration: const BoxDecoration(
                color: PaintStyle.barBackground,
                border: Border(
                  left: BorderSide(color: PaintStyle.separatorColor),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: width,
          child: ColoredBox(
            color: PaintStyle.barBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, panel) in panels.indexed)
                  _buildPanel(panel: panel, last: index == panels.length - 1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel({required SidePaneEntry panel, required bool last}) {
    final sidePanel = SidePanel(
      title: panel.title,
      border: last
          ? null
          : const Border(bottom: BorderSide(color: PaintStyle.separatorColor)),
      collapsed: collapsed.contains(panel.title),
      onToggle: () => _toggle(panel.title),
      child: panel.child,
    );
    return collapsed.contains(panel.title)
        ? sidePanel
        : Expanded(child: sidePanel);
  }
}
