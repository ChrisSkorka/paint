import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_split_button.dart';
import 'package:paint/widgets/components/timeline.dart';

void main() {
  void ignorePlayPause() {}
  void ignoreSelectFrame(int frame) {}
  void ignoreAddFrame() {}
  void ignoreDuration(int duration) {}

  group('class Timeline', () {
    group('render', () {
      group('frames', () {
        testWidgets('single', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 1,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          final slider = tester.widget<Slider>(find.byType(Slider));
          final removeButton = tester.widget<PaintIconButton>(
            find.ancestor(
              of: find.byTooltip('Remove frame'),
              matching: find.byType(PaintIconButton),
            ),
          );
          final actual = [
            tester.widget<Text>(find.byType(Text)).data,
            slider.value,
            slider.max,
            slider.onChanged == null,
            removeButton.onPressed == null,
          ];
          final expected = ['1 / 1', 0.0, 1.0, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 1,
                  frameCount: 3,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: ignoreAddFrame,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          final slider = tester.widget<Slider>(find.byType(Slider));
          final removeButton = tester.widget<PaintIconButton>(
            find.ancestor(
              of: find.byTooltip('Remove frame'),
              matching: find.byType(PaintIconButton),
            ),
          );
          final actual = [
            tester.widget<Text>(find.byType(Text)).data,
            slider.value,
            slider.max,
            slider.divisions,
            slider.onChanged == null,
            removeButton.onPressed == null,
          ];
          final expected = ['2 / 3', 1.0, 2.0, 2, false, false];
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
                  frameCount: 1,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          final playButton = tester.widget<PaintSplitButton>(
            find.byType(PaintSplitButton),
          );
          final actual = [playButton.icon, playButton.tooltip];
          final expected = [FontAwesomeIcons.play, 'Play'];
          expect(actual, equals(expected));
        });
        testWidgets('playing', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 1,
                  frameDuration: 100,
                  playing: true,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          final playButton = tester.widget<PaintSplitButton>(
            find.byType(PaintSplitButton),
          );
          final actual = [playButton.icon, playButton.tooltip];
          final expected = [FontAwesomeIcons.pause, 'Pause'];
          expect(actual, equals(expected));
        });
      });
      group('duration', () {
        testWidgets('dropdown', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 1,
                  frameDuration: 250,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Frame duration'));
          await tester.pumpAndSettle();
          final durationRange = tester.widget<NumericValueRange>(
            find.byType(NumericValueRange),
          );
          final actual = [
            durationRange.label,
            durationRange.value,
            durationRange.minimum,
            durationRange.maximum,
          ];
          final expected = ['Duration (ms):', 250, 10, 10000];
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
                  frameCount: 1,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: () => presses++,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
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
        testWidgets('slider end', (tester) async {
          final frames = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 3,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: frames.add,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: ignoreAddFrame,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          await tester.drag(find.byType(Slider), const Offset(2000, 0));
          final actual = frames.last;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('add', (tester) async {
          var presses = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 1,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: () => presses++,
                  onRemoveFrame: null,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add frame'));
          final actual = presses;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('remove', (tester) async {
          var presses = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 2,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: () => presses++,
                  onDurationChanged: ignoreDuration,
                  onDurationChangeEnd: ignoreDuration,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Remove frame'));
          final actual = presses;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
      group('duration', () {
        testWidgets('increase', (tester) async {
          final changes = <int>[];
          final ends = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 1,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: changes.add,
                  onDurationChangeEnd: ends.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Frame duration'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Increase'));
          final actual = [changes, ends];
          const expected = [
            [110],
            [110],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('decrease', (tester) async {
          final changes = <int>[];
          final ends = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 1,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: changes.add,
                  onDurationChangeEnd: ends.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Frame duration'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Decrease'));
          final actual = [changes, ends];
          const expected = [
            [90],
            [90],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('slider tap', (tester) async {
          final changes = <int>[];
          final ends = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Timeline(
                  frame: 0,
                  frameCount: 1,
                  frameDuration: 100,
                  playing: false,
                  onPlayPause: ignorePlayPause,
                  onSelectFrame: ignoreSelectFrame,
                  onAddFrame: ignoreAddFrame,
                  onRemoveFrame: null,
                  onDurationChanged: changes.add,
                  onDurationChangeEnd: ends.add,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Frame duration'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byType(NumericValueRange),
              matching: find.byType(Slider),
            ),
          );
          await tester.pump();
          final actual = [changes, ends];
          const expected = [
            [316],
            [316],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
