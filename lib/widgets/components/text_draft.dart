import 'package:flutter/material.dart';

import '../../editor/tools/text_orientation.dart';
import 'paint_style.dart';

class TextDraft extends StatefulWidget {
  const TextDraft({
    super.key,
    required this.style,
    required this.outlineStyle,
    required this.cursorColor,
    required this.padding,
    required this.orientation,
    required this.extentOf,
    required this.onChanged,
    required this.onMoved,
  });

  static const handleWidth = 6.0;

  final TextStyle style;
  final TextStyle? outlineStyle;
  final Color cursorColor;
  final double padding;
  final TextOrientation orientation;
  final Size Function(String text) extentOf;
  final ValueChanged<String> onChanged;
  final ValueChanged<Offset> onMoved;

  @override
  State<TextDraft> createState() => _TextDraftState();
}

class _TextDraftState extends State<TextDraft> {
  final focusNode = FocusNode(debugLabel: 'Text draft');
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MouseRegion(
            cursor: SystemMouseCursors.move,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerMove: (event) => widget.onMoved(event.delta),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: PaintStyle.inputBorder),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(TextDraft.handleWidth),
          child: RotatedBox(
            quarterTurns: widget.orientation.quarterTurns,
            child: Transform.flip(
              flipX: widget.orientation.mirrored,
              child: SizedBox.fromSize(
                size: widget.extentOf(textController.text),
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: Stack(
                      children: [
                        if (widget.outlineStyle case final outlineStyle?)
                          Text(textController.text, style: outlineStyle),
                        IntrinsicWidth(
                          child: TextField(
                            controller: textController,
                            focusNode: focusNode,
                            maxLines: null,
                            scrollPadding: EdgeInsets.zero,
                            style: widget.style,
                            cursorColor: widget.cursorColor,
                            decoration: null,
                            onChanged: (text) {
                              setState(() {});
                              widget.onChanged(text);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
