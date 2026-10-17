import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/editor_shortcut.dart';
import '../../editor/tools/tool_preset.dart';
import 'paint_split_button.dart';
import 'paint_style.dart';
import 'tool_icons.dart';

class ToolPresetList extends StatefulWidget {
  const ToolPresetList({
    super.key,
    required this.presets,
    required this.lockedCount,
    required this.selected,
    required this.onApply,
    required this.onLockChanged,
  });

  static const propertyStyle = TextStyle(fontSize: 10);
  static const shadowLuminance = 0.5;
  static const revealDuration = Duration(milliseconds: 200);

  final List<ToolPreset> presets;
  final int lockedCount;
  final ToolPreset? selected;
  final ValueChanged<int> onApply;
  final void Function({required int index, required bool locked}) onLockChanged;

  int get selectedIndex => presets.indexWhere((preset) => preset == selected);

  @override
  State<ToolPresetList> createState() => _ToolPresetListState();
}

class _ToolPresetListState extends State<ToolPresetList> {
  final itemKeys = <GlobalKey>[];

  @override
  void didUpdateWidget(ToolPresetList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.selectedIndex;
    if (index < 0 || index == oldWidget.selectedIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealItem(index));
  }

  void _revealItem(int index) {
    itemKeys[index].currentContext!.findRenderObject()!.showOnScreen(
      duration: ToolPresetList.revealDuration,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    while (itemKeys.length < widget.presets.length) {
      itemKeys.add(GlobalKey());
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        for (var index = 0; index < widget.presets.length; index++)
          KeyedSubtree(
            key: itemKeys[index],
            child: _buildItem(index: index),
          ),
      ],
    );
  }

  Widget _buildItem({required int index}) {
    final preset = widget.presets[index];
    final locked = index < widget.lockedCount;
    final color = preset.color ?? preset.secondaryColor;
    final size = preset.size ?? preset.textFormat?.size;
    final tip = preset.tip;
    final iconColor = color == null
        ? PaintStyle.eraserColor
        : Color(color.argb | 0xff000000);
    return PaintSplitButton(
      icon: toolIcon(kind: preset.kind),
      trailing: size == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                if (tip != null) FaIcon(tipIcon(tip: tip), size: 10),
                Text('$size px', style: ToolPresetList.propertyStyle),
              ],
            ),
      tooltip: preset.kind.label,
      shortcut: EditorShortcut.describe(
        EditorShortcut.toolPreset.platformActivators[index],
      ),
      color: iconColor,
      iconShadows: iconColor.computeLuminance() > ToolPresetList.shadowLuminance
          ? PaintStyle.iconShadow
          : null,
      selected: preset == widget.selected,
      onPressed: () => widget.onApply(index),
      secondaryIcon: locked ? FontAwesomeIcons.lock : FontAwesomeIcons.lockOpen,
      secondaryTooltip: locked ? 'Unlock' : 'Lock',
      secondaryOnHover: true,
      onSecondaryPressed: () =>
          widget.onLockChanged(index: index, locked: !locked),
    );
  }
}
