import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_style.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.title,
    required this.child,
    this.border,
    this.collapsed = false,
    this.onToggle,
  });

  final String title;
  final Widget child;
  final BoxBorder? border;
  final bool collapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: PaintStyle.barBackground,
        border: border,
      ),
      child: Column(
        mainAxisSize: collapsed ? MainAxisSize.min : MainAxisSize.max,
        children: [
          MouseRegion(
            cursor: onToggle == null
                ? MouseCursor.defer
                : SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.only(bottom: collapsed ? 0 : 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    FaIcon(
                      collapsed
                          ? FontAwesomeIcons.angleRight
                          : FontAwesomeIcons.angleDown,
                      size: 10,
                      color: PaintStyle.titleColor,
                    ),
                    Text(title, style: PaintStyle.titleStyle),
                  ],
                ),
              ),
            ),
          ),
          if (!collapsed) Expanded(child: child),
        ],
      ),
    );
  }
}
