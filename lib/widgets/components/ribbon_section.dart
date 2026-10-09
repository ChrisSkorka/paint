import 'package:flutter/material.dart';

import 'paint_bar.dart';
import 'paint_style.dart';

class RibbonSection extends StatelessWidget {
  const RibbonSection({super.key, required this.title, required this.columns});

  final String title;
  final List<Widget> columns;

  @override
  Widget build(BuildContext context) {
    return PaintBarSection(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              title,
              style: const TextStyle(
                color: PaintStyle.titleColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: PaintStyle.ribbonContentHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns,
            ),
          ),
        ],
      ),
    );
  }
}

class RibbonColumn extends StatelessWidget {
  const RibbonColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cellHeight = PaintStyle.ribbonContentHeight / children.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final child in children)
          SizedBox(
            height: cellHeight,
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
      ],
    );
  }
}
