import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/widgets/components/history_list.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';

void main() {
  final stubThumbnail = Layer.filled(
    width: 1,
    height: 1,
    color: PixelColor.transparent,
  );

  group('class HistoryList', () {
    group('render', () {
      group('items', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(items: const [], position: 0, onSelect: (_) {}),
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
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 0,
                onSelect: (_) {},
              ),
            ),
          );
          final actual = tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .toList();
          const expected = ['Start'];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Pen',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Eraser',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 2,
                onSelect: (_) {},
              ),
            ),
          );
          final actual = tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .toList();
          const expected = ['Start', 'Pen', 'Eraser'];
          expect(actual, equals(expected));
        });
      });
      group('position', () {
        testWidgets('start', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Pen',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Eraser',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 0,
                onSelect: (_) {},
              ),
            ),
          );
          final actual = [
            tester
                .widgetList<HighlightBox>(find.byType(HighlightBox))
                .map((highlightBox) => highlightBox.highlighted)
                .toList(),
            tester
                .widgetList<Opacity>(find.byType(Opacity))
                .map((opacity) => opacity.opacity)
                .toList(),
          ];
          const expected = [
            [true, false, false],
            [1.0, 0.4, 0.4],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('middle', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Pen',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Eraser',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 1,
                onSelect: (_) {},
              ),
            ),
          );
          final actual = [
            tester
                .widgetList<HighlightBox>(find.byType(HighlightBox))
                .map((highlightBox) => highlightBox.highlighted)
                .toList(),
            tester
                .widgetList<Opacity>(find.byType(Opacity))
                .map((opacity) => opacity.opacity)
                .toList(),
          ];
          const expected = [
            [false, true, false],
            [1.0, 1.0, 0.4],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('end', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Pen',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Eraser',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 2,
                onSelect: (_) {},
              ),
            ),
          );
          final actual = [
            tester
                .widgetList<HighlightBox>(find.byType(HighlightBox))
                .map((highlightBox) => highlightBox.highlighted)
                .toList(),
            tester
                .widgetList<Opacity>(find.byType(Opacity))
                .map((opacity) => opacity.opacity)
                .toList(),
          ];
          const expected = [
            [false, false, true],
            [1.0, 1.0, 1.0],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('earlier item', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Pen',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Eraser',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 2,
                onSelect: selected.add,
              ),
            ),
          );
          await tester.tap(find.text('Start'));
          final actual = selected;
          const expected = [0];
          expect(actual, equals(expected));
        });
        testWidgets('later item', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Pen',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                  HistoryListItem(
                    name: 'Eraser',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 0,
                onSelect: selected.add,
              ),
            ),
          );
          await tester.tap(find.text('Eraser'));
          final actual = selected;
          const expected = [2];
          expect(actual, equals(expected));
        });
      });
      group('hover', () {
        testWidgets('click cursor', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(
                items: [
                  HistoryListItem(
                    name: 'Start',
                    thumbnail: stubThumbnail,
                    outline: null,
                  ),
                ],
                position: 0,
                onSelect: (_) {},
              ),
            ),
          );
          final actual = tester
              .widget<MouseRegion>(
                find.ancestor(
                  of: find.text('Start'),
                  matching: find.byType(MouseRegion),
                ),
              )
              .cursor;
          const expected = SystemMouseCursors.click;
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class HistoryThumbnail', () {
    group('render', () {
      group('size', () {
        testWidgets('square', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: HistoryThumbnail(
                  thumbnail: Layer.filled(
                    width: 2,
                    height: 2,
                    color: PixelColor.transparent,
                  ),
                  outline: null,
                ),
              ),
            ),
          );
          final actual = [
            tester.getSize(find.byType(HistoryThumbnail)),
            tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(HistoryThumbnail),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .size,
          ];
          const expected = [Size(24, 24), Size(24, 24)];
          expect(actual, equals(expected));
        });
        testWidgets('wide', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: HistoryThumbnail(
                  thumbnail: Layer.filled(
                    width: 4,
                    height: 2,
                    color: PixelColor.transparent,
                  ),
                  outline: null,
                ),
              ),
            ),
          );
          final actual = [
            tester.getSize(find.byType(HistoryThumbnail)),
            tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(HistoryThumbnail),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .size,
          ];
          const expected = [Size(24, 24), Size(24, 12)];
          expect(actual, equals(expected));
        });
        testWidgets('tall', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: HistoryThumbnail(
                  thumbnail: Layer.filled(
                    width: 1,
                    height: 3,
                    color: PixelColor.transparent,
                  ),
                  outline: null,
                ),
              ),
            ),
          );
          final actual = [
            tester.getSize(find.byType(HistoryThumbnail)),
            tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(HistoryThumbnail),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .size,
          ];
          const expected = [Size(24, 24), Size(8, 24)];
          expect(actual, equals(expected));
        });
        testWidgets('custom size', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: HistoryThumbnail(
                  thumbnail: Layer.filled(
                    width: 4,
                    height: 2,
                    color: PixelColor.transparent,
                  ),
                  outline: null,
                  size: 40,
                ),
              ),
            ),
          );
          final actual = [
            tester.getSize(find.byType(HistoryThumbnail)),
            tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(HistoryThumbnail),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .size,
          ];
          const expected = [Size(40, 40), Size(40, 20)];
          expect(actual, equals(expected));
        });
      });
      group('painter', () {
        testWidgets('no outline', (tester) async {
          final thumbnail = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: HistoryThumbnail(thumbnail: thumbnail, outline: null),
              ),
            ),
          );
          final thumbnailPainter =
              tester
                      .widget<CustomPaint>(
                        find.descendant(
                          of: find.byType(HistoryThumbnail),
                          matching: find.byType(CustomPaint),
                        ),
                      )
                      .foregroundPainter
                  as ThumbnailPainter;
          final actual = [
            identical(thumbnailPainter.thumbnail, thumbnail),
            thumbnailPainter.outline,
            thumbnailPainter.scale,
          ];
          const expected = [true, null, 12.0];
          expect(actual, equals(expected));
        });
        testWidgets('outline', (tester) async {
          final thumbnail = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: HistoryThumbnail(
                  thumbnail: thumbnail,
                  outline: Rect.fromLTWH(1, 0, 1, 1),
                ),
              ),
            ),
          );
          final thumbnailPainter =
              tester
                      .widget<CustomPaint>(
                        find.descendant(
                          of: find.byType(HistoryThumbnail),
                          matching: find.byType(CustomPaint),
                        ),
                      )
                      .foregroundPainter
                  as ThumbnailPainter;
          final actual = [
            identical(thumbnailPainter.thumbnail, thumbnail),
            thumbnailPainter.outline,
            thumbnailPainter.scale,
          ];
          const expected = [true, Rect.fromLTWH(1, 0, 1, 1), 12.0];
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class ThumbnailPainter', () {
    group('method shouldRepaint', () {
      group('changes', () {
        test('same', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final thumbnailPainter = ThumbnailPainter(
            thumbnail: thumbnail,
            outline: const Rect.fromLTWH(0, 0, 1, 1),
            scale: 2,
          );
          final other = ThumbnailPainter(
            thumbnail: thumbnail,
            outline: const Rect.fromLTWH(0, 0, 1, 1),
            scale: 2,
          );
          final actual = thumbnailPainter.shouldRepaint(other);
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different thumbnail', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final thumbnailPainter = ThumbnailPainter(
            thumbnail: thumbnail,
            outline: const Rect.fromLTWH(0, 0, 1, 1),
            scale: 2,
          );
          final other = ThumbnailPainter(
            thumbnail: Layer.copyOf(thumbnail),
            outline: const Rect.fromLTWH(0, 0, 1, 1),
            scale: 2,
          );
          final actual = thumbnailPainter.shouldRepaint(other);
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different outline', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final thumbnailPainter = ThumbnailPainter(
            thumbnail: thumbnail,
            outline: const Rect.fromLTWH(0, 0, 1, 1),
            scale: 2,
          );
          final other = ThumbnailPainter(
            thumbnail: thumbnail,
            outline: null,
            scale: 2,
          );
          final actual = thumbnailPainter.shouldRepaint(other);
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different scale', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final thumbnailPainter = ThumbnailPainter(
            thumbnail: thumbnail,
            outline: const Rect.fromLTWH(0, 0, 1, 1),
            scale: 2,
          );
          final other = ThumbnailPainter(
            thumbnail: thumbnail,
            outline: const Rect.fromLTWH(0, 0, 1, 1),
            scale: 3,
          );
          final actual = thumbnailPainter.shouldRepaint(other);
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
