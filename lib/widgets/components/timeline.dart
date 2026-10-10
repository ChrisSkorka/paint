import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/canvas/onion_skin.dart';
import 'number_stepper.dart';
import 'paint_icon_button.dart';
import 'paint_split_button.dart';
import 'paint_style.dart';
import 'ribbon_section.dart';

class Timeline extends StatelessWidget {
  const Timeline({
    super.key,
    required this.frame,
    required this.shownFrames,
    required this.fps,
    required this.playing,
    required this.onionSkin,
    required this.onPlayPause,
    required this.onStep,
    required this.onSelectFrame,
    required this.onFpsChanged,
    required this.onOnionSkinChanged,
  });

  final int frame;
  final List<int> shownFrames;
  final int fps;
  final bool playing;
  final OnionSkin onionSkin;
  final VoidCallback onPlayPause;
  final void Function({required bool forward}) onStep;
  final ValueChanged<int> onSelectFrame;
  final ValueChanged<int> onFpsChanged;
  final ValueChanged<OnionSkin> onOnionSkinChanged;

  static const sliderWidth = 260.0;
  static const counterWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final position = shownFrames.indexOf(frame);
    final sliderPosition = shownFrames.lastIndexWhere(
      (shown) => shown <= frame,
    );
    final lastPosition = max(1, shownFrames.length - 1);
    final canStep = shownFrames.length > 1;
    return RibbonColumn(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PaintIconButton(
              icon: FontAwesomeIcons.backwardStep,
              tooltip: 'Previous frame',
              onPressed: canStep ? () => onStep(forward: false) : null,
            ),
            PaintIconButton(
              icon: playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
              tooltip: playing ? 'Pause' : 'Play',
              onPressed: onPlayPause,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.forwardStep,
              tooltip: 'Next frame',
              onPressed: canStep ? () => onStep(forward: true) : null,
            ),
            const SizedBox(width: 8),
            const Text('FPS'),
            NumberStepper(
              value: fps,
              minimum: Document.minimumFps,
              maximum: Document.maximumFps,
              decreaseTooltip: 'Decrease frame rate',
              increaseTooltip: 'Increase frame rate',
              onChanged: onFpsChanged,
            ),
            PaintSplitButton(
              icon: FontAwesomeIcons.layerGroup,
              tooltip: 'Onion skinning',
              dropdownTooltip: 'Onion skinning options',
              selected: onionSkin.enabled,
              onPressed: () => onOnionSkinChanged(
                onionSkin.copyWith(enabled: !onionSkin.enabled),
              ),
              dropdown: _buildOnionSkinOptions(),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: sliderWidth,
              child: SliderTheme(
                data: PaintStyle.sliderTheme,
                child: Slider(
                  value: sliderPosition.toDouble(),
                  max: lastPosition.toDouble(),
                  divisions: lastPosition,
                  onChanged: canStep
                      ? (value) => onSelectFrame(shownFrames[value.round()])
                      : null,
                ),
              ),
            ),
            SizedBox(
              width: counterWidth,
              child: Text(
                '${position == -1 ? '–' : position + 1} / ${shownFrames.length}',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOnionSkinOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          PaintIconButton(
            icon: FontAwesomeIcons.backward,
            tooltip: 'Previous frames',
            color: Color(OnionSkin.previousTint.argb),
            selected: onionSkin.previous,
            onPressed: () => onOnionSkinChanged(
              onionSkin.copyWith(previous: !onionSkin.previous),
            ),
          ),
          PaintIconButton(
            icon: FontAwesomeIcons.forward,
            tooltip: 'Next frames',
            color: Color(OnionSkin.nextTint.argb),
            selected: onionSkin.next,
            onPressed: () =>
                onOnionSkinChanged(onionSkin.copyWith(next: !onionSkin.next)),
          ),
          PaintIconButton(
            icon: FontAwesomeIcons.filter,
            tooltip: 'Active layer only',
            selected: onionSkin.activeLayerOnly,
            onPressed: () => onOnionSkinChanged(
              onionSkin.copyWith(activeLayerOnly: !onionSkin.activeLayerOnly),
            ),
          ),
          const Text('Frames:'),
          NumberStepper(
            value: onionSkin.frameCount,
            minimum: OnionSkin.minimumFrameCount,
            maximum: OnionSkin.maximumFrameCount,
            decreaseTooltip: 'Fewer onion frames',
            increaseTooltip: 'More onion frames',
            onChanged: (frameCount) =>
                onOnionSkinChanged(onionSkin.copyWith(frameCount: frameCount)),
          ),
        ],
      ),
    );
  }
}
