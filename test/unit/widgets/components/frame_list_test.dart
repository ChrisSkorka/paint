import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/widgets/components/frame_list.dart';
import 'package:paint/widgets/components/number_stepper.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';

void main() {
  final stubThumbnail = Layer.filled(
    width: 1,
    height: 1,
    color: PixelColor.transparent,
  );

  void ignoreSelect(int index) {}
  void ignoreHolds({required int index, required int holds}) {}

  List<String?> texts(WidgetTester tester) => [
    for (final text in tester.widgetList<Text>(
      find.descendant(of: find.byType(FrameList), matching: find.byType(Text)),
    ))
      text.data,
  ];

  group('class FrameList', () {
    group('render', () {
      group('items', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: const [],
                    activeIndex: 0,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ignoreHolds,
                  ),
                ),
              ),
            ),
          );
          final actual = texts(tester);
          const expected = <String>[];
          expect(actual, equals(expected));
        });
        testWidgets('one', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [FrameListItem(thumbnail: stubThumbnail, holds: 1)],
                    activeIndex: 0,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ignoreHolds,
                  ),
                ),
              ),
            ),
          );
          final actual = texts(tester);
          const expected = ['1', '1'];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                      FrameListItem(thumbnail: stubThumbnail, holds: 2),
                      FrameListItem(thumbnail: stubThumbnail, holds: 0),
                    ],
                    activeIndex: 0,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ignoreHolds,
                  ),
                ),
              ),
            ),
          );
          final actual = texts(tester);
          const expected = ['1', '1', '2', '2', '3', '0'];
          expect(actual, equals(expected));
        });
      });
      group('holds', () {
        testWidgets('values', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                      FrameListItem(thumbnail: stubThumbnail, holds: 2),
                      FrameListItem(thumbnail: stubThumbnail, holds: 0),
                    ],
                    activeIndex: 0,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ignoreHolds,
                  ),
                ),
              ),
            ),
          );
          final actual = [
            for (final stepper in tester.widgetList<NumberStepper>(
              find.byType(NumberStepper),
            ))
              [stepper.value, stepper.minimum, stepper.maximum],
          ];
          const expected = [
            [1, 1, 100],
            [2, 0, 100],
            [0, 0, 100],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('hidden frame thumbnail', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                      FrameListItem(thumbnail: stubThumbnail, holds: 0),
                    ],
                    activeIndex: 0,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ignoreHolds,
                  ),
                ),
              ),
            ),
          );
          final actual = [
            for (final opacity in tester.widgetList<Opacity>(
              find.ancestor(
                of: find.byType(CustomPaint),
                matching: find.byType(Opacity),
              ),
            ))
              opacity.opacity,
          ];
          const expected = [1.0, 0.4];
          expect(actual, equals(expected));
        });
      });
      group('active', () {
        testWidgets('second', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [
                      FrameListItem(thumbnail: stubThumbnail, holds: 5),
                      FrameListItem(thumbnail: stubThumbnail, holds: 5),
                    ],
                    activeIndex: 1,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ignoreHolds,
                  ),
                ),
              ),
            ),
          );
          final actual = [
            for (final number in ['1', '2'])
              tester
                  .widget<HighlightBox>(
                    find.ancestor(
                      of: find.text(number),
                      matching: find.byType(HighlightBox),
                    ),
                  )
                  .highlighted,
          ];
          const expected = [false, true];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('select', () {
        testWidgets('second frame', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                    ],
                    activeIndex: 0,
                    onSelect: selected.add,
                    onHoldsChanged: ignoreHolds,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('2'));
          final actual = selected;
          const expected = [1];
          expect(actual, equals(expected));
        });
      });
      group('holds', () {
        testWidgets('increase second', (tester) async {
          final changes = <(int, int)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                    ],
                    activeIndex: 0,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ({required index, required holds}) =>
                        changes.add((index, holds)),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More holds').last);
          final actual = changes;
          const expected = [(1, 2)];
          expect(actual, equals(expected));
        });
        testWidgets('decrease to hidden', (tester) async {
          final changes = <(int, int)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  child: FrameList(
                    items: [
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                      FrameListItem(thumbnail: stubThumbnail, holds: 1),
                    ],
                    activeIndex: 0,
                    onSelect: ignoreSelect,
                    onHoldsChanged: ({required index, required holds}) =>
                        changes.add((index, holds)),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fewer holds').last);
          final actual = changes;
          const expected = [(1, 0)];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
