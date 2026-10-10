import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/widgets/components/history_list.dart';
import 'package:paint/widgets/components/layer_list.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_split_button.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';

void main() {
  final stubThumbnail = Layer.filled(
    width: 1,
    height: 1,
    color: PixelColor.transparent,
  );

  void ignoreSelect(int index) {}
  void ignoreVisibility({required int index, required bool visible}) {}
  void ignoreOpacity({required int index, required int opacity}) {}

  group('class LayerList', () {
    group('render', () {
      group('items', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: const [],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .toList();
          const expected = [];
          expect(actual, equals(expected));
        });
        testWidgets('one', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .toList();
          const expected = ['Background'];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 60,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final actual = tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .toList();
          const expected = ['Sketch', 'Background'];
          expect(actual, equals(expected));
        });
      });
      group('layout', () {
        testWidgets('thumbnail after name', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final visibilityButton = tester.getRect(
            find.byType(PaintSplitButton),
          );
          final name = tester.getRect(find.text('Background'));
          final thumbnail = tester.getRect(find.byType(HistoryThumbnail));
          final actual = [
            visibilityButton.right <= name.left,
            name.right <= thumbnail.left,
          ];
          const expected = [true, true];
          expect(actual, equals(expected));
        });
      });
      group('visibility', () {
        testWidgets('visible', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final visibilityButton = tester.widget<PaintSplitButton>(
            find.byType(PaintSplitButton),
          );
          final actual = [
            visibilityButton.icon,
            visibilityButton.tooltip,
            tester.widget<Opacity>(find.byType(Opacity).last).opacity,
          ];
          final expected = [FontAwesomeIcons.eye, 'Hide layer', 1.0];
          expect(actual, equals(expected));
        });
        testWidgets('hidden', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: false,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final visibilityButton = tester.widget<PaintSplitButton>(
            find.byType(PaintSplitButton),
          );
          final actual = [
            visibilityButton.icon,
            visibilityButton.tooltip,
            tester.widget<Opacity>(find.byType(Opacity).last).opacity,
          ];
          final expected = [FontAwesomeIcons.eyeSlash, 'Show layer', 0.4];
          expect(actual, equals(expected));
        });
      });
      group('opacity', () {
        testWidgets('full', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final opacityRange =
              tester
                      .widget<PaintSplitButton>(find.byType(PaintSplitButton))
                      .dropdown
                  as NumericValueRange;
          final actual = [
            opacityRange.label,
            opacityRange.value,
            opacityRange.minimum,
            opacityRange.maximum,
            find.byType(Slider).evaluate().length,
          ];
          const expected = ['Opacity:', 100, 0, 100, 0];
          expect(actual, equals(expected));
        });
        testWidgets('partial', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 40,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final opacityRange =
              tester
                      .widget<PaintSplitButton>(find.byType(PaintSplitButton))
                      .dropdown
                  as NumericValueRange;
          final actual = [
            opacityRange.label,
            opacityRange.value,
            opacityRange.minimum,
            opacityRange.maximum,
            find.byType(Slider).evaluate().length,
          ];
          const expected = ['Opacity:', 40, 0, 100, 0];
          expect(actual, equals(expected));
        });
      });
      group('active', () {
        testWidgets('bottom', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final actual = [
            for (final name in ['Sketch', 'Background'])
              tester
                  .widget<HighlightBox>(
                    find
                        .ancestor(
                          of: find.text(name),
                          matching: find.byType(HighlightBox),
                        )
                        .first,
                  )
                  .highlighted,
          ];
          const expected = [false, true];
          expect(actual, equals(expected));
        });
        testWidgets('top', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 1,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final actual = [
            for (final name in ['Sketch', 'Background'])
              tester
                  .widget<HighlightBox>(
                    find
                        .ancestor(
                          of: find.text(name),
                          matching: find.byType(HighlightBox),
                        )
                        .first,
                  )
                  .highlighted,
          ];
          const expected = [true, false];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('select', () {
        testWidgets('top layer', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: selected.add,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.text('Sketch'));
          final actual = selected;
          const expected = [1];
          expect(actual, equals(expected));
        });
        testWidgets('bottom layer', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 1,
                  onSelect: selected.add,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.text('Background'));
          final actual = selected;
          const expected = [0];
          expect(actual, equals(expected));
        });
        testWidgets('thumbnail', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: selected.add,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.byType(HistoryThumbnail).first);
          final actual = selected;
          const expected = [1];
          expect(actual, equals(expected));
        });
        testWidgets('visibility button', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: selected.add,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Hide layer').first);
          final actual = selected;
          const expected = [];
          expect(actual, equals(expected));
        });
        testWidgets('click cursor', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          final actual = tester
              .widget<MouseRegion>(
                find
                    .ancestor(
                      of: find.text('Sketch'),
                      matching: find.byType(MouseRegion),
                    )
                    .first,
              )
              .cursor;
          const expected = SystemMouseCursors.click;
          expect(actual, equals(expected));
        });
      });
      group('visibility', () {
        testWidgets('hide', (tester) async {
          final changes = <(int, bool)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ({required index, required visible}) =>
                      changes.add((index, visible)),
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Hide layer'));
          final actual = changes;
          const expected = [(0, false)];
          expect(actual, equals(expected));
        });
        testWidgets('show', (tester) async {
          final changes = <(int, bool)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: false,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ({required index, required visible}) =>
                      changes.add((index, visible)),
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Show layer'));
          final actual = changes;
          const expected = [(0, true)];
          expect(actual, equals(expected));
        });
        testWidgets('top of multiple', (tester) async {
          final changes = <(int, bool)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ({required index, required visible}) =>
                      changes.add((index, visible)),
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Hide layer').first);
          final actual = changes;
          const expected = [(1, false)];
          expect(actual, equals(expected));
        });
      });
      group('opacity', () {
        testWidgets('open dropdown', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ignoreOpacity,
                  onOpacityChangeEnd: ignoreOpacity,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity'));
          await tester.pumpAndSettle();
          final actual = [
            find.text('Opacity:').evaluate().length,
            find.byType(Slider).evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('slider tap', (tester) async {
          final changes = <(int, int)>[];
          final ends = <(int, int)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ({required index, required opacity}) =>
                      changes.add((index, opacity)),
                  onOpacityChangeEnd: ({required index, required opacity}) =>
                      ends.add((index, opacity)),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity').first);
          await tester.pumpAndSettle();
          await tester.tap(find.byType(Slider));
          await tester.pump();
          final actual = [changes, ends];
          const expected = [
            [(0, 50)],
            [(0, 50)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('decrease', (tester) async {
          final changes = <(int, int)>[];
          final ends = <(int, int)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ({required index, required opacity}) =>
                      changes.add((index, opacity)),
                  onOpacityChangeEnd: ({required index, required opacity}) =>
                      ends.add((index, opacity)),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity').first);
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Decrease'));
          await tester.pump();
          final actual = [changes, ends];
          const expected = [
            [(0, 99)],
            [(0, 99)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('typing', (tester) async {
          final changes = <(int, int)>[];
          final ends = <(int, int)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ({required index, required opacity}) =>
                      changes.add((index, opacity)),
                  onOpacityChangeEnd: ({required index, required opacity}) =>
                      ends.add((index, opacity)),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity').first);
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), '30');
          await tester.pump();
          final actual = [changes, ends];
          const expected = [
            [(0, 30)],
            <(int, int)>[],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('top of multiple', (tester) async {
          final changes = <(int, int)>[];
          final ends = <(int, int)>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LayerList(
                  items: [
                    LayerListItem(
                      name: 'Background',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                    LayerListItem(
                      name: 'Sketch',
                      thumbnail: stubThumbnail,
                      visible: true,
                      opacity: 100,
                    ),
                  ],
                  activeIndex: 0,
                  onSelect: ignoreSelect,
                  onVisibilityChanged: ignoreVisibility,
                  onOpacityChanged: ({required index, required opacity}) =>
                      changes.add((index, opacity)),
                  onOpacityChangeEnd: ({required index, required opacity}) =>
                      ends.add((index, opacity)),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity').first);
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Decrease'));
          await tester.pump();
          final actual = [changes, ends];
          const expected = [
            [(1, 99)],
            [(1, 99)],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
