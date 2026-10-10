import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/history_list.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';

void main() {
  group('class HistoryList', () {
    group('render', () {
      group('items', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: HistoryList(names: const [], position: 0, onSelect: (_) {}),
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
                names: const ['Start'],
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
                names: const ['Start', 'Pen', 'Eraser'],
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
                names: const ['Start', 'Pen', 'Eraser'],
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
                names: const ['Start', 'Pen', 'Eraser'],
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
                names: const ['Start', 'Pen', 'Eraser'],
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
                names: const ['Start', 'Pen', 'Eraser'],
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
                names: const ['Start', 'Pen', 'Eraser'],
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
                names: const ['Start'],
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
}
