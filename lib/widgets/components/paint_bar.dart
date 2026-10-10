import 'package:flutter/material.dart';

import 'paint_style.dart';

class PaintBar extends StatelessWidget {
  const PaintBar({
    super.key,
    required this.child,
    this.shadow = true,
    this.border,
  });

  final Widget child;
  final bool shadow;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: PaintStyle.barBackground,
        boxShadow: shadow ? PaintStyle.barShadow : null,
        border: border,
      ),
      child: child,
    );
  }
}

class PaintBarSection extends StatelessWidget {
  const PaintBarSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: PaintStyle.separatorColor)),
      ),
      child: child,
    );
  }
}
