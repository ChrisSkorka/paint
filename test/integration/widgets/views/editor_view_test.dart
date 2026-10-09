import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';
import 'package:paint/widgets/components/swatch_grid.dart';
import 'package:paint/widgets/views/editor_view.dart';

import '../../../support/desktop_view.dart';
import '../../../support/editor_view_probes.dart';
import '../../../support/view_probes.dart';

void main() {
  group('class EditorView', () {
    group('render', () {
      group('defaults', () {
        testWidgets('tool', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = selectedTools(tester);
          const expected = [true, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('colors', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = wellColors(tester);
          const expected = [Color(0xFF000000), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
        testWidgets('canvas size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = canvasSize(tester);
          const expected = Size(8, 8);
          expect(actual, equals(expected));
        });
        testWidgets('document size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = find.text('2 × 2');
          expect(actual, findsOneWidget);
        });
      });
    });

    group('interactions', () {
      group('tools', () {
        testWidgets('eraser', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser'));
          await tester.pump();
          final actual = selectedTools(tester);
          const expected = [false, true, false];
          expect(actual, equals(expected));
        });
        testWidgets('color picker', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Color picker'));
          await tester.pump();
          final actual = selectedTools(tester);
          const expected = [false, false, true];
          expect(actual, equals(expected));
        });
        testWidgets('back to pen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser'));
          await tester.pump();
          await tester.tap(find.byTooltip('Pen'));
          await tester.pump();
          final actual = selectedTools(tester);
          const expected = [true, false, false];
          expect(actual, equals(expected));
        });
      });
      group('tool sizes', () {
        testWidgets('pen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Pen options'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: sizeRange(),
              matching: find.byTooltip('Increase'),
            ),
          );
          await tester.pump();
          final actual = tester.widget<NumericValueRange>(sizeRange()).value;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('eraser', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser options'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: sizeRange(),
              matching: find.byTooltip('Increase'),
            ),
          );
          await tester.pump();
          final actual = tester.widget<NumericValueRange>(sizeRange()).value;
          const expected = 2;
          expect(actual, equals(expected));
        });
      });
      group('colors', () {
        testWidgets('primary swatch', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byType(Swatch).at(2));
          await tester.pump();
          final actual = wellColors(tester);
          const expected = [Color(0xFF808080), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
        testWidgets('secondary swatch', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Secondary color'));
          await tester.pump();
          await tester.tap(find.byType(Swatch).at(2));
          await tester.pump();
          final actual = wellColors(tester);
          const expected = [Color(0xFF000000), Color(0xFF808080)];
          expect(actual, equals(expected));
        });
        testWidgets('back to primary', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Secondary color'));
          await tester.pump();
          await tester.tap(find.byTooltip('Primary color'));
          await tester.pump();
          await tester.tap(find.byType(Swatch).at(2));
          await tester.pump();
          final actual = wellColors(tester);
          const expected = [Color(0xFF808080), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
      });
      group('zoom', () {
        testWidgets('increase', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase'));
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(16, 16);
          expect(actual, equals(expected));
        });
        testWidgets('decrease', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Decrease'));
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(4, 4);
          expect(actual, equals(expected));
        });
        testWidgets('slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          tester.widget<Slider>(find.byType(Slider)).onChanged!(3);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(16, 16);
          expect(actual, equals(expected));
        });
      });
    });
  });
}
