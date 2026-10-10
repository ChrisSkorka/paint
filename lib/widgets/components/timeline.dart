import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import 'numeric_value_range.dart';
import 'paint_icon_button.dart';
import 'paint_split_button.dart';
import 'paint_style.dart';

class Timeline extends StatelessWidget {
  const Timeline({
    super.key,
    required this.frame,
    required this.frameCount,
    required this.frameDuration,
    required this.playing,
    required this.onPlayPause,
    required this.onSelectFrame,
    required this.onAddFrame,
    required this.onRemoveFrame,
    required this.onDurationChanged,
    required this.onDurationChangeEnd,
  });

  final int frame;
  final int frameCount;
  final int frameDuration;
  final bool playing;
  final VoidCallback onPlayPause;
  final ValueChanged<int> onSelectFrame;
  final VoidCallback onAddFrame;
  final VoidCallback? onRemoveFrame;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<int> onDurationChangeEnd;

  @override
  Widget build(BuildContext context) {
    final lastFrame = max(1, frameCount - 1);
    return Row(
      children: [
        PaintSplitButton(
          icon: playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
          tooltip: playing ? 'Pause' : 'Play',
          dropdownTooltip: 'Frame duration',
          onPressed: onPlayPause,
          dropdown: NumericValueRange(
            label: 'Duration (ms):',
            value: frameDuration,
            minimum: Document.minimumFrameDuration,
            maximum: Document.maximumFrameDuration,
            valueToRange: (value) => log(value) / ln10,
            rangeToValue: (range) => pow(10, range).round(),
            decrement: (value) => value - Document.minimumFrameDuration,
            increment: (value) => value + Document.minimumFrameDuration,
            onChanged: onDurationChanged,
            onChangeEnd: onDurationChangeEnd,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: PaintStyle.sliderTheme,
            child: Slider(
              value: frame.toDouble(),
              max: lastFrame.toDouble(),
              divisions: lastFrame,
              onChanged: frameCount > 1
                  ? (value) => onSelectFrame(value.round())
                  : null,
            ),
          ),
        ),
        Text('${frame + 1} / $frameCount'),
        const SizedBox(width: 4),
        PaintIconButton(
          icon: FontAwesomeIcons.plus,
          tooltip: 'Add frame',
          onPressed: onAddFrame,
        ),
        PaintIconButton(
          icon: FontAwesomeIcons.trashCan,
          tooltip: 'Remove frame',
          onPressed: onRemoveFrame,
        ),
      ],
    );
  }
}
