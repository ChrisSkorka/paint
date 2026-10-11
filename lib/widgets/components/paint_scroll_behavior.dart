import 'package:flutter/material.dart';

class PaintScrollBehavior extends MaterialScrollBehavior {
  const PaintScrollBehavior();

  static const scrollbarThickness = 12.0;
  static const scrollbarMargin = 2.0;
  static const scrollbarTrack = scrollbarThickness + 2 * scrollbarMargin;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return switch (axisDirectionToAxis(details.direction)) {
      Axis.horizontal => child,
      Axis.vertical => Scrollbar(
        controller: details.controller,
        interactive: true,
        thickness: scrollbarThickness,
        child: child,
      ),
    };
  }
}
