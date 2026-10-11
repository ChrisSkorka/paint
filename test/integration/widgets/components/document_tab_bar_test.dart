import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/document_tab_bar.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_style.dart';

import '../../../support/document_tab_probes.dart';
import '../../../support/hover.dart';
import '../../../support/view_probes.dart';

void main() {
  group('class DocumentTabBar', () {
    group('render', () {
      group('tabs', () {
        testWidgets('one', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [(title: 'Cat', unsaved: false)],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final actual = texts(tester);
          const expected = ['Cat'];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final actual = [
            texts(tester),
            find.byTooltip('Close tab').evaluate().length,
            find.byTooltip('New tab (Ctrl+N)').evaluate().length,
          ];
          const expected = [
            ['Cat', 'Dog'],
            2,
            1,
          ];
          expect(actual, equals(expected));
        });
      });
      group('selection', () {
        testWidgets('first', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final actual = [
            documentTabWeights(tester),
            documentTabDecoration(tester, title: 'Cat'),
            documentTabDecoration(tester, title: 'Dog'),
          ];
          const expected = [
            [FontWeight.bold, FontWeight.normal],
            BoxDecoration(
              color: PaintStyle.barBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
            BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('second', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 1,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final actual = documentTabWeights(tester);
          const expected = [FontWeight.normal, FontWeight.bold];
          expect(actual, equals(expected));
        });
      });
      group('unsaved', () {
        testWidgets('saved', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [(title: 'Cat', unsaved: false)],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final actual = find.byTooltip('Unsaved changes').evaluate().length;
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('unsaved', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: true),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final actual = find
              .descendant(
                of: find.byTooltip('Cat'),
                matching: find.byTooltip('Unsaved changes'),
              )
              .evaluate()
              .length;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
      group('hover', () {
        testWidgets('unselected tab', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          await hoverOver(tester, find.text('Dog'));
          final actual = documentTabDecoration(tester, title: 'Dog');
          const expected = BoxDecoration(
            color: PaintStyle.tabHoverBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
          );
          expect(actual, equals(expected));
        });
        testWidgets('unhovered tab', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.text('Dog'));
          await gesture.moveTo(
            tester.getCenter(find.byTooltip('New tab (Ctrl+N)')),
          );
          await tester.pump();
          final actual = documentTabDecoration(tester, title: 'Dog');
          const expected = BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
          );
          expect(actual, equals(expected));
        });
        testWidgets('close button', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [(title: 'Cat', unsaved: false)],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.byTooltip('Close tab'));
          final hovered = tester
              .widget<HighlightBox>(
                find.descendant(
                  of: find.byTooltip('Close tab'),
                  matching: find.byType(HighlightBox),
                ),
              )
              .highlighted;
          await gesture.moveTo(tester.getCenter(find.text('Cat')));
          await tester.pump();
          final unhovered = tester
              .widget<HighlightBox>(
                find.descendant(
                  of: find.byTooltip('Close tab'),
                  matching: find.byType(HighlightBox),
                ),
              )
              .highlighted;
          final actual = [hovered, unhovered];
          const expected = [true, false];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('select', () {
        testWidgets('tap tab', (tester) async {
          final selected = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: selected.add,
                  onClose: (_) {},
                  onAdd: () {},
                ),
              ),
            ),
          );
          await tester.tap(find.text('Dog'));
          final actual = selected;
          const expected = [1];
          expect(actual, equals(expected));
        });
      });
      group('close', () {
        testWidgets('tap close', (tester) async {
          final selected = <int>[];
          final closed = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: selected.add,
                  onClose: closed.add,
                  onAdd: () {},
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Close tab').at(1));
          final actual = [selected, closed];
          const expected = [
            <int>[],
            [1],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('middle click', (tester) async {
          final selected = <int>[];
          final closed = <int>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [
                    (title: 'Cat', unsaved: false),
                    (title: 'Dog', unsaved: false),
                  ],
                  selectedIndex: 0,
                  onSelect: selected.add,
                  onClose: closed.add,
                  onAdd: () {},
                ),
              ),
            ),
          );
          await tester.tap(find.text('Dog'), buttons: kMiddleMouseButton);
          final actual = [selected, closed];
          const expected = [
            <int>[],
            [1],
          ];
          expect(actual, equals(expected));
        });
      });
      group('add', () {
        testWidgets('tap plus', (tester) async {
          var added = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DocumentTabBar(
                  tabs: const [(title: 'Cat', unsaved: false)],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  onClose: (_) {},
                  onAdd: () => added++,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          final actual = added;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
