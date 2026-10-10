import 'package:flutter/material.dart';

import 'paint_icon_button.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.names,
    required this.position,
    required this.onSelect,
  });

  final List<String> names;
  final int position;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var index = 0; index < names.length; index++)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: HighlightBox(
                highlighted: index == position,
                child: Opacity(
                  opacity: index > position ? 0.4 : 1,
                  child: Text(names[index]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
