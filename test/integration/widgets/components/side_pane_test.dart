import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/paint_style.dart';
import 'package:paint/widgets/components/side_pane.dart';
import 'package:paint/widgets/components/side_panel.dart';

import '../../../support/side_pane_probes.dart';

void main() {
  group('class SidePane', () {
    group('render', () {
      group('panels', () {
        testWidgets('titles', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          final actual = [
            for (final sidePanel in tester.widgetList<SidePanel>(
              find.byType(SidePanel),
            ))
              sidePanel.title,
          ];
          const expected = ['Layers', 'Frames', 'History'];
          expect(actual, equals(expected));
        });
        testWidgets('dividers', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          final actual = [
            for (final sidePanel in tester.widgetList<SidePanel>(
              find.byType(SidePanel),
            ))
              sidePanel.border,
          ];
          const expected = [
            Border(bottom: BorderSide(color: PaintStyle.separatorColor)),
            Border(bottom: BorderSide(color: PaintStyle.separatorColor)),
            null,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('equal heights', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          final actual = panelHeights(tester);
          const expected = [200.0, 200.0, 200.0];
          expect(actual, equals(expected));
        });
      });
      group('width', () {
        testWidgets('initial', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          final actual = sidePaneWidth(tester);
          const expected = PaintStyle.sidePanelWidth + SidePane.handleWidth;
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('collapse', () {
        testWidgets('one panel', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          await tester.tap(find.text('Frames'));
          await tester.pump();
          final heights = panelHeights(tester);
          final actual = [
            find.text('frames').evaluate().length,
            heights[0] == heights[2],
            heights[0] + heights[1] + heights[2],
            heights[1] < 40,
          ];
          const expected = [0, true, 600.0, true];
          expect(actual, equals(expected));
        });
        testWidgets('expand again', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          await tester.tap(find.text('Frames'));
          await tester.pump();
          await tester.tap(find.text('Frames'));
          await tester.pump();
          final actual = [
            find.text('frames').evaluate().length,
            panelHeights(tester),
          ];
          const expected = [
            1,
            [200.0, 200.0, 200.0],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('all panels', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          await tester.tap(find.text('Layers'));
          await tester.tap(find.text('Frames'));
          await tester.tap(find.text('History'));
          await tester.pump();
          final actual = [
            find.text('layers').evaluate().length,
            find.text('frames').evaluate().length,
            find.text('history').evaluate().length,
            tester.getSize(find.byType(SidePane)).height,
          ];
          const expected = [0, 0, 0, 600.0];
          expect(actual, equals(expected));
        });
      });
      group('resize', () {
        testWidgets('wider', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          await dragHandle(tester, dx: -50);
          final actual = sidePaneWidth(tester);
          const expected = 270.0 + SidePane.handleWidth;
          expect(actual, equals(expected));
        });
        testWidgets('narrower', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          await dragHandle(tester, dx: 40);
          final actual = sidePaneWidth(tester);
          const expected = 180.0 + SidePane.handleWidth;
          expect(actual, equals(expected));
        });
        testWidgets('minimum', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          await dragHandle(tester, dx: 400);
          final actual = sidePaneWidth(tester);
          const expected = SidePane.minimumWidth + SidePane.handleWidth;
          expect(actual, equals(expected));
        });
        testWidgets('maximum', (tester) async {
          await tester.pumpWidget(sidePaneApp());
          await dragHandle(tester, dx: -500);
          final actual = sidePaneWidth(tester);
          const expected = SidePane.maximumWidth + SidePane.handleWidth;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
