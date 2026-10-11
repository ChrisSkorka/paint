import 'package:flutter/material.dart';

import '../../editor/editor_shortcut.dart';
import 'paint_style.dart';

class ShortcutList extends StatelessWidget {
  const ShortcutList({super.key, required this.shortcuts});

  static const groupWidth = 260.0;
  static const keysWidth = 110.0;

  final List<EditorShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        for (final group in ShortcutGroup.values)
          if (shortcuts.any((shortcut) => shortcut.group == group))
            SizedBox(
              width: groupWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: [
                  Text(group.label, style: PaintStyle.titleStyle),
                  for (final shortcut in shortcuts)
                    if (shortcut.group == group)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: keysWidth,
                            child: Text(
                              shortcut.keys,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Text(shortcut.label)),
                        ],
                      ),
                ],
              ),
            ),
      ],
    );
  }
}
