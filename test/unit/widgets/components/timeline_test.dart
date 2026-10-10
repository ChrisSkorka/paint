import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/editor/canvas/onion_skin.dart';
import 'package:paint/widgets/components/number_stepper.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_split_button.dart';
import 'package:paint/widgets/components/timeline.dart';

void main() {
  void ignorePlayPause() {}
  void ignoreStep({required bool forward}) {}
  void ignoreSelectFrame(int frame) {}
  void ignoreValue(int value) {}
  void ignoreOnionSkin(OnionSkin onionSkin) {}

  List<Object?> frameState(WidgetTester tester) {
    final slider = tester.widget<Slider>(find.byType(Slider));
    return [
      tester.widget<Text>(find.textContaining(' / ')).data,
      slider.value,
      slider.max,
      slider.onChanged != null,
      tester
              .widget<PaintIconButton>(
                find.ancestor(
                  of: find.byTooltip('Previous frame'),
                  matching: find.byType(PaintIconButton),
                ),
              )
              .onPressed !=
          null,
      tester
              .widget<PaintIconButton>(
                find.ancestor(
                  of: find.byTooltip('Next frame'),
                  matching: find.byType(PaintIconButton),
                ),
              )
              .onPressed !=
          null,
    ];
  }

  group('class Timeline', () {
    group('render', () {
      group('frames', () {
        testWidgets('single', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final actual = frameState(tester);
          const expected = ['1 / 1', 0.0, 1.0, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 1,
                  shownFrames: const [0, 1, 2],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final actual = frameState(tester);
          const expected = ['2 / 3', 1.0, 2.0, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('hidden frame', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 1,
                  shownFrames: const [0, 2],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final actual = frameState(tester);
          const expected = ['– / 2', 0.0, 1.0, true, true, true];
          expect(actual, equals(expected));
        });
      });
      group('playback', () {
        testWidgets('paused', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final playButton = tester.widget<PaintIconButton>(
            find.ancestor(
              of: find.byTooltip('Play'),
              matching: find.byType(PaintIconButton),
            ),
          );
          final actual = playButton.icon;
          final expected = FontAwesomeIcons.play;
          expect(actual, equals(expected));
        });
        testWidgets('playing', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: true,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final pauseButton = tester.widget<PaintIconButton>(
            find.ancestor(
              of: find.byTooltip('Pause'),
              matching: find.byType(PaintIconButton),
            ),
          );
          final actual = pauseButton.icon;
          final expected = FontAwesomeIcons.pause;
          expect(actual, equals(expected));
        });
      });
      group('fps', () {
        testWidgets('value', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 24,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final actual = tester
              .widget<NumberStepper>(find.byType(NumberStepper))
              .value;
          const expected = 24;
          expect(actual, equals(expected));
        });
      });
      group('onion skin', () {
        testWidgets('disabled', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final actual = tester
              .widget<PaintSplitButton>(find.byType(PaintSplitButton))
              .selected;
          const expected = false;
          expect(actual, equals(expected));
        });
        testWidgets('enabled', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(enabled: true),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          final actual = tester
              .widget<PaintSplitButton>(find.byType(PaintSplitButton))
              .selected;
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('options', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(
                    previous: false,
                    frameCount: 3,
                    activeLayerOnly: true,
                  ),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Onion skinning options'));
          await tester.pumpAndSettle();
          final actual = [
            tester
                .widget<PaintIconButton>(
                  find.ancestor(
                    of: find.byTooltip('Previous frames'),
                    matching: find.byType(PaintIconButton),
                  ),
                )
                .selected,
            tester
                .widget<PaintIconButton>(
                  find.ancestor(
                    of: find.byTooltip('Next frames'),
                    matching: find.byType(PaintIconButton),
                  ),
                )
                .selected,
            tester
                .widget<PaintIconButton>(
                  find.ancestor(
                    of: find.byTooltip('Active layer only'),
                    matching: find.byType(PaintIconButton),
                  ),
                )
                .selected,
            tester
                .widgetList<NumberStepper>(find.byType(NumberStepper))
                .last
                .value,
          ];
          const expected = [false, true, true, 3];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('playback', () {
        testWidgets('play', (tester) async {
          var presses = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: () => presses++,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Play'));
          final actual = presses;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
      group('frames', () {
        testWidgets('previous', (tester) async {
          final steps = <bool>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0, 1],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ({required forward}) => steps.add(forward),
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Previous frame'));
          final actual = steps;
          const expected = [false];
          expect(actual, equals(expected));
        });
        testWidgets('next', (tester) async {
          final steps = <bool>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0, 1],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ({required forward}) => steps.add(forward),
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Next frame'));
          final actual = steps;
          const expected = [true];
          expect(actual, equals(expected));
        });
        testWidgets('slider end', (tester) async {
          final frames = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0, 2],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: frames.add,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          await tester.drag(find.byType(Slider), const Offset(2000, 0));
          final actual = frames.last;
          const expected = 2;
          expect(actual, equals(expected));
        });
      });
      group('fps', () {
        testWidgets('increase', (tester) async {
          final changes = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: changes.add,
                  onOnionSkinChanged: ignoreOnionSkin,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase frame rate'));
          final actual = changes;
          const expected = [11];
          expect(actual, equals(expected));
        });
      });
      group('onion skin', () {
        testWidgets('toggle', (tester) async {
          final changes = <OnionSkin>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Onion skinning'));
          final actual = changes;
          const expected = [OnionSkin(enabled: true)];
          expect(actual, equals(expected));
        });
        testWidgets('previous frames', (tester) async {
          final changes = <OnionSkin>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Onion skinning options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Previous frames'));
          final actual = changes;
          const expected = [OnionSkin(previous: false)];
          expect(actual, equals(expected));
        });
        testWidgets('next frames', (tester) async {
          final changes = <OnionSkin>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Onion skinning options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Next frames'));
          final actual = changes;
          const expected = [OnionSkin(next: false)];
          expect(actual, equals(expected));
        });
        testWidgets('frame count', (tester) async {
          final changes = <OnionSkin>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Onion skinning options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('More onion frames'));
          final actual = changes;
          const expected = [OnionSkin(frameCount: 2)];
          expect(actual, equals(expected));
        });
        testWidgets('active layer only', (tester) async {
          final changes = <OnionSkin>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  shownFrames: const [0],
                  fps: 10,
                  playing: false,
                  onionSkin: const OnionSkin(),
                  onPlayPause: ignorePlayPause,
                  onStep: ignoreStep,
                  onSelectFrame: ignoreSelectFrame,
                  onFpsChanged: ignoreValue,
                  onOnionSkinChanged: changes.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Onion skinning options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Active layer only'));
          final actual = changes;
          const expected = [OnionSkin(activeLayerOnly: true)];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
