import 'package:flutter/material.dart';

import 'paint_bar.dart';
import 'paint_style.dart';

class RibbonSection extends StatefulWidget {
  const RibbonSection({super.key, required this.title, required this.columns});

  static const titleHeight = 18.0;

  final String title;
  final List<Widget> columns;

  @override
  State<RibbonSection> createState() => _RibbonSectionState();
}

class _RibbonSectionState extends State<RibbonSection> {
  var collapsed = false;

  void _toggle() => setState(() => collapsed = !collapsed);

  Widget _buildTitle({required Widget child}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = Text(widget.title, style: PaintStyle.titleStyle);
    if (collapsed) {
      return PaintBarSection(
        child: _buildTitle(
          child: SizedBox(
            height: RibbonSection.titleHeight + PaintStyle.ribbonContentHeight,
            child: Center(child: RotatedBox(quarterTurns: 3, child: title)),
          ),
        ),
      );
    }
    return PaintBarSection(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(
            child: SizedBox(
              height: RibbonSection.titleHeight,
              child: Align(alignment: Alignment.topCenter, child: title),
            ),
          ),
          SizedBox(
            height: PaintStyle.ribbonContentHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.columns,
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
