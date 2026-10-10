import 'package:flutter/material.dart';

import '../../editor/canvas/document.dart';
import '../../editor/canvas/layer.dart';
import 'history_list.dart';
import 'number_stepper.dart';
import 'paint_icon_button.dart';

class FrameListItem {
  const FrameListItem({required this.thumbnail, required this.holds});

  final Layer thumbnail;
  final int holds;
}

class FrameList extends StatelessWidget {
  const FrameList({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onSelect,
    required this.onHoldsChanged,
  });

  final List<FrameListItem> items;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final void Function({required int index, required int holds}) onHoldsChanged;

  static const numberWidth = 24.0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var index = 0; index < items.length; index++)
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

  Widget _buildItem({required int index, required FrameListItem item}) {
    return Row(
      children: [
        SizedBox(width: numberWidth, child: Text('${index + 1}')),
        NumberStepper(
          value: item.holds,
          minimum: Document.minimumHolds(frame: index),
          maximum: Document.maximumHolds,
          decreaseTooltip: 'Fewer holds',
          increaseTooltip: 'More holds',
          onChanged: (holds) => onHoldsChanged(index: index, holds: holds),
          editable: false,
        ),
        const Spacer(),
        Opacity(
          opacity: item.holds > 0 ? 1 : 0.4,
          child: HistoryThumbnail(thumbnail: item.thumbnail, outline: null),
        ),
      ],
    );
  }
}
