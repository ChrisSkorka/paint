import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document_layer.dart';
import '../../editor/canvas/layer.dart';
import 'history_list.dart';
import 'numeric_value_range.dart';
import 'paint_icon_button.dart';
import 'paint_split_button.dart';

class LayerListItem {
  const LayerListItem({
    required this.name,
    required this.thumbnail,
    required this.visible,
    required this.opacity,
  });

  final String name;
  final Layer thumbnail;
  final bool visible;
  final int opacity;
}

class LayerList extends StatelessWidget {
  const LayerList({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onSelect,
    required this.onVisibilityChanged,
    required this.onOpacityChanged,
    required this.onOpacityChangeEnd,
  });

  final List<LayerListItem> items;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final void Function({required int index, required bool visible})
  onVisibilityChanged;
  final void Function({required int index, required int opacity})
  onOpacityChanged;
  final void Function({required int index, required int opacity})
  onOpacityChangeEnd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var index = items.length - 1; index >= 0; index--)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: HighlightBox(
                highlighted: index == activeIndex,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: _buildItem(index: index, item: items[index]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItem({required int index, required LayerListItem item}) {
    return Row(
      children: [
        PaintSplitButton(
          icon: item.visible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
          tooltip: item.visible ? 'Hide layer' : 'Show layer',
          dropdownTooltip: 'Layer opacity',
          onPressed: () =>
              onVisibilityChanged(index: index, visible: !item.visible),
          dropdown: NumericValueRange(
            label: 'Opacity:',
            value: item.opacity,
            minimum: DocumentLayer.minimumOpacity,
            maximum: DocumentLayer.maximumOpacity,
            onChanged: (opacity) =>
                onOpacityChanged(index: index, opacity: opacity),
            onChangeEnd: (opacity) =>
                onOpacityChangeEnd(index: index, opacity: opacity),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(child: Text(item.name, overflow: TextOverflow.ellipsis)),
        Opacity(
          opacity: item.visible ? 1 : 0.4,
          child: HistoryThumbnail(thumbnail: item.thumbnail, outline: null),
        ),
      ],
    );
  }
}
