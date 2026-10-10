import 'package:flutter/material.dart';

import 'paint_style.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PaintStyle.sidePanelWidth,
      padding: const EdgeInsets.all(5),
      color: PaintStyle.barBackground,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(title, style: PaintStyle.titleStyle),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
