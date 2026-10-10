import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/widgets/components/edge_shadow.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';
import 'package:paint/widgets/components/paint_bar.dart';
import 'package:paint/widgets/components/paint_style.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';
import 'package:paint/widgets/components/side_panel.dart';
import 'package:paint/widgets/components/swatch_grid.dart';
import 'package:paint/widgets/views/editor_view.dart';

import '../../../support/color_dialog_probes.dart';
import '../../../support/desktop_view.dart';
import '../../../support/editor_view_probes.dart';
import '../../../support/hover.dart';
import '../../../support/layer_probes.dart';
import '../../../support/view_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;
  const white = 0xFFFFFFFF;

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
          const expected = [true, false, false, false];
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
        testWidgets('cursor', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = find.text('-');
          expect(actual, findsOneWidget);
        });
        testWidgets('pen tip', (tester) async {
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
          final actual = selectedTips(tester);
          const expected = [true, false];
          expect(actual, equals(expected));
        });
        testWidgets('recent colors', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = recentSwatches(tester);
          const expected = [
            [null],
            [null],
            [null],
            [null],
            [null],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('selection actions', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = [
            selectionActionsEnabled(tester),
            tester.widget<PixelCanvas>(find.byType(PixelCanvas)).selection,
          ];
          const expected = [
            [false, false, false, false],
            null,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('history', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [transparent, transparent],
              [transparent, transparent],
            ],
            [
              ['Start'],
              0,
            ],
            [false, false],
          ];
          expect(actual, equals(expected));
        });
      });
      group('layout', () {
        testWidgets('side panel beside top bar', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final layersPanel = tester.getRect(find.byType(SidePanel).first);
          final historyPanel = tester.getRect(find.byType(SidePanel).last);
          final topBar = tester.getRect(find.byType(PaintBar).first);
          final bottomBar = tester.getRect(find.byType(PaintBar).last);
          final actual = [
            layersPanel.top,
            layersPanel.right,
            historyPanel.bottom == bottomBar.top,
            topBar.top,
            topBar.right == layersPanel.left,
            bottomBar.width,
          ];
          const expected = [0.0, 1280.0, true, 0.0, true, 1280.0];
          expect(actual, equals(expected));
        });
        testWidgets('top bar divider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final topBar = tester.widget<PaintBar>(find.byType(PaintBar).first);
          final actual = [topBar.shadow, topBar.border];
          const expected = [
            false,
            Border(right: BorderSide(color: PaintStyle.separatorColor)),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('canvas edge shadow', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final edgeShadow = tester.getRect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is CustomPaint &&
                  widget.foregroundPainter is EdgeShadowPainter,
            ),
          );
          final topBar = tester.getRect(find.byType(PaintBar).first);
          final sidePanel = tester.getRect(find.byType(SidePanel).first);
          final bottomBar = tester.getRect(find.byType(PaintBar).last);
          final actual = [
            edgeShadow.left,
            edgeShadow.top == topBar.bottom,
            edgeShadow.right == sidePanel.left,
            edgeShadow.bottom == bottomBar.top,
          ];
          const expected = [0.0, true, true, true];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('layers pane', () {
        testWidgets('panel titles', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = [
            for (final sidePanel in tester.widgetList<SidePanel>(
              find.byType(SidePanel),
            ))
              sidePanel.title,
          ];
          const expected = ['Layers', 'History'];
          expect(actual, equals(expected));
        });
        testWidgets('panel divider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = [
            for (final sidePanel in tester.widgetList<SidePanel>(
              find.byType(SidePanel),
            ))
              sidePanel.border,
          ];
          const expected = [
            Border(bottom: BorderSide(color: PaintStyle.separatorColor)),
            null,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('blank document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = layerState(tester);
          const expected = [
            ['Background'],
            [true],
            [100],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('layer actions', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = layerActionsEnabled(tester);
          const expected = [true, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('thumbnail', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  document: Document.blank(
                    width: 2,
                    height: 1,
                    background: PixelColor.white,
                  ),
                ),
              ),
            ),
          );
          final actual = pixelRows(layerThumbnail(tester));
          const expected = [
            [white, white],
          ];
          expect(actual, equals(expected));
        });
      });

      group('drawing', () {
        testWidgets('primary click', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black],
            [transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('secondary click', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(
            topLeft + const Offset(1, 5),
            buttons: kSecondaryMouseButton,
            kind: PointerDeviceKind.mouse,
          );
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent],
            [white, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('drag', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.moveTo(topLeft + const Offset(5, 5));
          await gesture.up();
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, transparent],
            [transparent, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('eraser', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(
            width: 2,
            height: 2,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Eraser'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black],
            [black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('bucket fill', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Fill'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black],
            [black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('rectangle drag', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.moveTo(topLeft + const Offset(9, 9));
          await gesture.up();
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black],
            [black, transparent, black],
            [black, black, black],
          ];
          expect(actual, equals(expected));
        });
      });
      group('cursor', () {
        testWidgets('hover', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PixelCanvas));
          final actual = find.text('1, 1');
          expect(actual, findsOneWidget);
        });
        testWidgets('exit', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.byType(PixelCanvas));
          await gesture.moveTo(Offset.zero);
          await tester.pump();
          final actual = find.text('-');
          expect(actual, findsOneWidget);
        });
      });
      group('pen tip', () {
        testWidgets('circle', (tester) async {
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
          await tester.tap(find.byTooltip('Circle tip'));
          await tester.pump();
          final actual = selectedTips(tester);
          const expected = [false, true];
          expect(actual, equals(expected));
        });
        testWidgets('back to square', (tester) async {
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
          await tester.tap(find.byTooltip('Circle tip'));
          await tester.pump();
          await tester.tap(find.byTooltip('Square tip'));
          await tester.pump();
          final actual = selectedTips(tester);
          const expected = [true, false];
          expect(actual, equals(expected));
        });
      });
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
          const expected = [false, true, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('bucket fill', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fill'));
          await tester.pump();
          final actual = selectedTools(tester);
          const expected = [false, false, true, false];
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
          const expected = [false, false, false, true];
          expect(actual, equals(expected));
        });
        testWidgets('line', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Line'));
          await tester.pump();
          final actual = [selectedTools(tester), selectedShapes(tester)];
          const expected = [
            [false, false, false, false],
            [true, false, false, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('rectangle', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle'));
          await tester.pump();
          final actual = [selectedTools(tester), selectedShapes(tester)];
          const expected = [
            [false, false, false, false],
            [false, true, false, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('circle', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Circle'));
          await tester.pump();
          final actual = [selectedTools(tester), selectedShapes(tester)];
          const expected = [
            [false, false, false, false],
            [false, false, true, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('arrow', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Arrow'));
          await tester.pump();
          final actual = [selectedTools(tester), selectedShapes(tester)];
          const expected = [
            [false, false, false, false],
            [false, false, false, true],
          ];
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
          const expected = [true, false, false, false];
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
        testWidgets('shape width', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle options'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: widthRange(),
              matching: find.byTooltip('Increase'),
            ),
          );
          await tester.pump();
          final actual = tester.widget<NumericValueRange>(widthRange()).value;
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
      group('recent colors', () {
        testWidgets('after stroke', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final actual = recentSwatches(tester);
          const expected = [
            [Color(0xFF000000)],
            [null],
            [null],
            [null],
            [null],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('select recent', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byType(Swatch).at(2));
          await tester.pump();
          await tester.tap(
            find
                .descendant(
                  of: find.byType(SwatchGrid).last,
                  matching: find.byType(Swatch),
                )
                .first,
          );
          await tester.pump();
          final actual = wellColors(tester);
          const expected = [Color(0xFF000000), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
      });
      group('color picker tool', () {
        testWidgets('primary sample', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  document: Document.blank(
                    width: 2,
                    height: 2,
                    background: const PixelColor(argb: 0xFFFF0000),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Color picker'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final actual = wellColors(tester);
          const expected = [Color(0xFFFF0000), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
        testWidgets('secondary sample', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  document: Document.blank(
                    width: 2,
                    height: 2,
                    background: const PixelColor(argb: 0xFFFF0000),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Color picker'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(
            topLeft + const Offset(1, 1),
            buttons: kSecondaryMouseButton,
            kind: PointerDeviceKind.mouse,
          );
          await tester.pump();
          final actual = wellColors(tester);
          const expected = [Color(0xFF000000), Color(0xFFFF0000)];
          expect(actual, equals(expected));
        });
      });
      group('color picker switch back', () {
        testWidgets('to eraser', (tester) async {
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
          await tester.tap(find.byTooltip('Color picker'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final actual = selectedTools(tester);
          const expected = [false, true, false, false];
          expect(actual, equals(expected));
        });
      });
      group('edit colors', () {
        testWidgets('primary', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Edit colors'));
          await tester.pumpAndSettle();
          await tester.enterText(channelField('Red:'), '255');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = wellColors(tester);
          const expected = [Color(0xFFFF0000), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
        testWidgets('secondary', (tester) async {
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
          await tester.tap(find.byTooltip('Edit colors'));
          await tester.pumpAndSettle();
          await tester.enterText(channelField('Red:'), '0');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = wellColors(tester);
          const expected = [Color(0xFF000000), Color(0xFF00FFFF)];
          expect(actual, equals(expected));
        });
        testWidgets('cancel', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Edit colors'));
          await tester.pumpAndSettle();
          await tester.enterText(channelField('Red:'), '255');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = wellColors(tester);
          const expected = [Color(0xFF000000), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
      });
      group('selection', () {
        testWidgets('select tool', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select'));
          await tester.pump();
          final actual = [selectToolSelected(tester), selectedTools(tester)];
          const expected = [
            true,
            [false, false, false, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('select all', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 2);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          final actual = [
            selectToolSelected(tester),
            tester.widget<PixelCanvas>(find.byType(PixelCanvas)).selection,
            selectionActionsEnabled(tester),
          ];
          const expected = [
            true,
            PixelRectangle(left: 0, top: 0, width: 3, height: 2),
            [true, true, true, true],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('drag and move', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 1);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final selecting = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await selecting.moveTo(topLeft + const Offset(2, 2));
          await selecting.up();
          await tester.pump();
          final moving = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await moving.moveTo(topLeft + const Offset(9, 1));
          await moving.up();
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('move cursor', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await hoverOver(tester, find.byType(PixelCanvas));
          final actual = tester
              .widget<PixelCanvas>(find.byType(PixelCanvas))
              .cursor;
          const expected = SystemMouseCursors.move;
          expect(actual, equals(expected));
        });
        testWidgets('delete key', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('backspace key', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('other key', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('zoom field backspace', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.tap(
            find.descendant(
              of: find.ancestor(
                of: find.text('Zoom:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(TextField),
            ),
          );
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('rotate left', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.tap(find.byTooltip('Rotate left'));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent],
            [black, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('rotate right', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.tap(find.byTooltip('Rotate right'));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black],
            [transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('mirror horizontally', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 1);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.tap(find.byTooltip('Mirror horizontally'));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('mirror vertically', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 1, height: 2);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.tap(find.byTooltip('Mirror vertically'));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent],
            [black],
          ];
          expect(actual, equals(expected));
        });
      });
      group('history', () {
        testWidgets('after stroke', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [black, transparent],
              [transparent, transparent],
            ],
            [
              ['Start', 'Pen'],
              1,
            ],
            [true, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('after two strokes', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tapAt(topLeft + const Offset(5, 5));
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [black, transparent],
              [transparent, black],
            ],
            [
              ['Start', 'Pen', 'Pen'],
              2,
            ],
            [true, false],
          ];
          expect(actual, equals(expected));
        });
      });

      group('history thumbnails', () {
        testWidgets('start', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final actual = historyThumbnails(tester);
          final expected = [
            [
              Layer.filled(width: 2, height: 2, color: PixelColor.transparent),
              null,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('after stroke', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          final actual = historyThumbnails(tester).last;
          final expected = [
            Layer.filled(width: 2, height: 2, color: PixelColor.transparent)
              ..setPixel(
                point: const PixelPoint(x: 1, y: 0),
                color: PixelColor.black,
              ),
            const Rect.fromLTWH(1, 0, 1, 1),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('large document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  document: Document.blank(width: 48, height: 48),
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(13, 13));
          await tester.pump();
          final actual = historyThumbnails(tester).last;
          final expected = [
            Layer.filled(width: 24, height: 24, color: PixelColor.transparent)
              ..setPixel(
                point: const PixelPoint(x: 1, y: 1),
                color: PixelColor.black,
              ),
            const Rect.fromLTWH(1.5, 1.5, 0.5, 0.5),
          ];
          expect(actual, equals(expected));
        });
      });

      group('undo redo buttons', () {
        testWidgets('undo', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo'));
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [transparent, transparent],
              [transparent, transparent],
            ],
            [
              ['Start', 'Pen'],
              0,
            ],
            [false, true],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('redo', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo'));
          await tester.pump();
          await tester.tap(find.byTooltip('Redo'));
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [black, transparent],
              [transparent, transparent],
            ],
            [
              ['Start', 'Pen'],
              1,
            ],
            [true, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('stroke after undo', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo'));
          await tester.pump();
          await tester.tapAt(topLeft + const Offset(5, 5));
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [transparent, transparent],
              [transparent, black],
            ],
            [
              ['Start', 'Pen'],
              1,
            ],
            [true, false],
          ];
          expect(actual, equals(expected));
        });
      });

      group('shortcuts', () {
        testWidgets('ctrl z', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [transparent, transparent],
              [transparent, transparent],
            ],
            [
              ['Start', 'Pen'],
              0,
            ],
            [false, true],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl y', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyY);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [black, transparent],
              [transparent, transparent],
            ],
            [
              ['Start', 'Pen'],
              1,
            ],
            [true, false],
          ];
          expect(actual, equals(expected));
        });
      });

      group('history list', () {
        testWidgets('jump to start', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tapAt(topLeft + const Offset(5, 5));
          await tester.pump();
          await tester.tap(find.text('Start'));
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [transparent, transparent],
              [transparent, transparent],
            ],
            [
              ['Start', 'Pen', 'Pen'],
              0,
            ],
            [false, true],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('jump forward', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tapAt(topLeft + const Offset(5, 5));
          await tester.pump();
          await tester.tap(find.text('Start'));
          await tester.pump();
          await tester.tap(find.text('Pen').last);
          await tester.pump();
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
            undoRedoEnabled(tester),
          ];
          const expected = [
            [
              [black, transparent],
              [transparent, black],
            ],
            [
              ['Start', 'Pen', 'Pen'],
              2,
            ],
            [true, false],
          ];
          expect(actual, equals(expected));
        });
      });

      group('layers pane', () {
        testWidgets('add layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          final actual = [
            layerState(tester),
            layerActionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Background', 'Layer 2'],
              [true, true],
              [100, 100],
              1,
            ],
            [true, true, false, true],
            [
              ['Start', 'Add layer'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('remove layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          await tester.tap(find.byTooltip('Remove layer'));
          await tester.pump();
          final actual = [
            layerState(tester),
            layerActionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            [true, false, false, false],
            [
              ['Start', 'Add layer', 'Remove layer'],
              2,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('move layer down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          await tester.tap(find.byTooltip('Move layer down'));
          await tester.pump();
          final actual = [
            layerState(tester),
            layerActionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Layer 2', 'Background'],
              [true, true],
              [100, 100],
              0,
            ],
            [true, true, true, false],
            [
              ['Start', 'Add layer', 'Move layer down'],
              2,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('move layer up', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          await tester.tap(find.byTooltip('Move layer down'));
          await tester.pump();
          await tester.tap(find.byTooltip('Move layer up'));
          await tester.pump();
          final actual = [
            layerState(tester),
            layerActionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Background', 'Layer 2'],
              [true, true],
              [100, 100],
              1,
            ],
            [true, true, false, true],
            [
              ['Start', 'Add layer', 'Move layer down', 'Move layer up'],
              3,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('select layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          await tester.tap(find.text('Background'));
          await tester.pump();
          final actual = [
            layerState(tester),
            layerActionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Background', 'Layer 2'],
              [true, true],
              [100, 100],
              0,
            ],
            [true, true, true, false],
            [
              ['Start', 'Add layer'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('undo add layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo'));
          await tester.pump();
          final actual = [
            layerState(tester),
            layerActionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            [true, false, false, false],
            [
              ['Start', 'Add layer'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('layer history thumbnail', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 1)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          final actual = historyThumbnails(tester).last;
          final expected = [
            Layer.filled(width: 2, height: 1, color: PixelColor.transparent),
            null,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('draw on selected layer', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: EditorView(document: document)),
            ),
          );
          await tester.tap(find.byTooltip('Add layer'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          final actual = [
            for (final layer in document.layers) pixelRows(layer.pixels),
          ];
          const expected = [
            [
              [transparent, transparent],
            ],
            [
              [transparent, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('hide layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Hide layer'));
          await tester.pump();
          final actual = [
            layerState(tester),
            [for (final layer in canvasLayers(tester)) layer.name],
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [false],
              [100],
              0,
            ],
            ['Pointer'],
            [
              ['Start', 'Hide layer'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('show layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Hide layer'));
          await tester.pump();
          await tester.tap(find.byTooltip('Show layer'));
          await tester.pump();
          final actual = [
            layerState(tester),
            [for (final layer in canvasLayers(tester)) layer.name],
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            ['Background', 'Pointer'],
            [
              ['Start', 'Hide layer', 'Show layer'],
              2,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('opacity slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity'));
          await tester.pumpAndSettle();
          tester
              .widget<Slider>(
                find.descendant(
                  of: find.ancestor(
                    of: find.text('Opacity:'),
                    matching: find.byType(NumericValueRange),
                  ),
                  matching: find.byType(Slider),
                ),
              )
              .onChanged!(30);
          await tester.pump();
          final actual = [
            layerState(tester),
            canvasLayers(tester).first.opacity,
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [30],
              0,
            ],
            30,
            [
              ['Start'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('opacity drag', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity'));
          await tester.pumpAndSettle();
          await tester.drag(
            find.descendant(
              of: find.ancestor(
                of: find.text('Opacity:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(Slider),
            ),
            const Offset(-40, 0),
          );
          await tester.pump();
          final actual = [
            canvasLayers(tester).first.opacity < 100,
            historyState(tester),
          ];
          const expected = [
            true,
            [
              ['Start', 'Layer opacity'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('opacity decrease', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.ancestor(
                of: find.text('Opacity:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byTooltip('Decrease'),
            ),
          );
          await tester.pump();
          final actual = [layerState(tester), historyState(tester)];
          const expected = [
            [
              ['Background'],
              [true],
              [99],
              0,
            ],
            [
              ['Start', 'Layer opacity'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('undo opacity drag', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 2)),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Layer opacity'));
          await tester.pumpAndSettle();
          await tester.drag(
            find.descendant(
              of: find.ancestor(
                of: find.text('Opacity:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(Slider),
            ),
            const Offset(-40, 0),
          );
          await tester.pump();
          await tester.tap(find.byTooltip('Undo'));
          await tester.pump();
          final actual = [layerState(tester), historyState(tester)];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            [
              ['Start', 'Layer opacity'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('thumbnail after stroke', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(document: Document.blank(width: 2, height: 1)),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          final actual = pixelRows(layerThumbnail(tester));
          const expected = [
            [transparent, black],
          ];
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
          tester
              .widget<Slider>(
                find.descendant(
                  of: find.ancestor(
                    of: find.text('Zoom:'),
                    matching: find.byType(NumericValueRange),
                  ),
                  matching: find.byType(Slider),
                ),
              )
              .onChanged!(3);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(16, 16);
          expect(actual, equals(expected));
        });
      });
    });
  });
}
