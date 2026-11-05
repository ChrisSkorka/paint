import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/layer_timeframe.dart';
import 'package:paint/editor/canvas/onion_skin.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/files/export_format.dart';
import 'package:paint/editor/files/ora_codec.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/tool_kind.dart';
import 'package:paint/editor/tools/tool_preset.dart';
import 'package:paint/editor/tools/text_format.dart';
import 'package:paint/editor/tools/text_orientation.dart';
import 'package:paint/editor/tools/tool_presets.dart';
import 'package:paint/widgets/components/edge_shadow.dart';
import 'package:paint/widgets/components/number_stepper.dart';
import 'package:paint/widgets/components/numeric_value_range.dart';
import 'package:paint/widgets/components/paint_bar.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/components/paint_status_button.dart';
import 'package:paint/widgets/components/paint_style.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';
import 'package:paint/widgets/components/side_pane.dart';
import 'package:paint/widgets/components/side_panel.dart';
import 'package:paint/widgets/components/swatch_grid.dart';
import 'package:paint/widgets/components/text_draft.dart';
import 'package:paint/widgets/components/timeline.dart';
import 'package:paint/widgets/views/editor_view.dart';

import '../../../support/color_dialog_probes.dart';
import '../../../support/desktop_view.dart';
import '../../../support/document_probes.dart';
import '../../../support/editor_view_probes.dart';
import '../../../support/scroll_probes.dart';
import '../../../support/hover.dart';
import '../../../support/keyboard.dart';
import '../../../support/right_click.dart';
import '../../../support/layer_probes.dart';
import '../../../support/view_probes.dart';
import '../../../support/wheel.dart';
import '../../../support/stored_documents.dart';
import '../../../support/stub_document_store.dart';
import '../../../support/stub_file_access.dart';
import '../../../support/stub_image_clipboard.dart';
import '../../../support/text_commits.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;
  const white = 0xFFFFFFFF;
  const red = 0xFFFF0000;
  const green = 0xFF00FF00;
  const blue = 0xFF0000FF;

  group('class EditorView', () {
    group('render', () {
      group('defaults', () {
        testWidgets('tool', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = selectedTips(tester);
          const expected = [true, false];
          expect(actual, equals(expected));
        });
        testWidgets('tool presets', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = toolPresetList(tester).presets;
          const expected = <ToolPreset>[];
          expect(actual, equals(expected));
        });
        testWidgets('swatch grids', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = find.byType(SwatchGrid).evaluate().length;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('selection actions', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
      group('all frames button', () {
        testWidgets('per frame layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: filmDocument(
                    frames: [
                      [
                        [red, transparent],
                      ],
                      [
                        [green, transparent],
                      ],
                    ],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          final actual = allFramesButtonState(tester);
          const expected = [true, false];
          expect(actual, equals(expected));
        });
        testWidgets('constant layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          final actual = allFramesButtonState(tester);
          const expected = [false, false];
          expect(actual, equals(expected));
        });
        testWidgets('selected', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: filmDocument(
                    frames: [
                      [
                        [red, transparent],
                      ],
                      [
                        [green, transparent],
                      ],
                    ],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('All frames'));
          await tester.pump();
          final actual = allFramesButtonState(tester);
          const expected = [true, true];
          expect(actual, equals(expected));
        });
      });
      group('all frames options', () {
        testWidgets('defaults', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: filmDocument(
                    frames: [
                      [
                        [red, transparent],
                      ],
                      [
                        [green, transparent],
                      ],
                    ],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('All frames options'));
          await tester.pumpAndSettle();
          final actual = allFramesDirections(tester);
          const expected = [true, true];
          expect(actual, equals(expected));
        });
      });
      group('pen settings', () {
        testWidgets('pen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = penSettingsEnabled(tester);
          const expected = [true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('eraser', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser (E)'));
          await tester.pump();
          final actual = penSettingsEnabled(tester);
          const expected = [true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('line', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Line (L)'));
          await tester.pump();
          final actual = penSettingsEnabled(tester);
          const expected = [true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('circle', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Circle (O)'));
          await tester.pump();
          final actual = penSettingsEnabled(tester);
          const expected = [true, true, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('fill', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fill (G)'));
          await tester.pump();
          final actual = penSettingsEnabled(tester);
          const expected = [false, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('select', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select (M)'));
          await tester.pump();
          final actual = penSettingsEnabled(tester);
          const expected = [false, false, false, false];
          expect(actual, equals(expected));
        });
      });
      group('text tool', () {
        testWidgets('cursor', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          final actual = tester
              .widget<PixelCanvas>(find.byType(PixelCanvas))
              .cursor;
          const expected = SystemMouseCursors.text;
          expect(actual, equals(expected));
        });
        testWidgets('transform buttons', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          await tester.tapAt(tester.getTopLeft(find.byType(PixelCanvas)));
          await tester.pump();
          final actual = selectionActionsEnabled(tester);
          const expected = [true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('options', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          final actual = textOptions(tester);
          const expected = [12, false, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('no draft', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          final actual = find.byType(TextDraft).evaluate().length;
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('draft', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(9, 5));
          await tester.pump();
          final actual = [
            textFieldOffset(tester),
            tester.widget<TextDraft>(find.byType(TextDraft)).style,
          ];
          final expected = [
            const Offset(8, 4),
            const TextFormat().style(scale: 4, color: PixelColor.black),
          ];
          expect(actual, equals(expected));
        });
      });

      group('shape style', () {
        testWidgets('pen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = shapeStyle(tester);
          const expected = [true, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('rectangle', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [true, true, false, true];
          expect(actual, equals(expected));
        });
        testWidgets('circle', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Circle (O)'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [true, true, false, true];
          expect(actual, equals(expected));
        });
        testWidgets('line', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Line (L)'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [true, false, false, false];
          expect(actual, equals(expected));
        });
      });

      group('pen size', () {
        testWidgets('field width', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = tester
              .getSize(
                find.descendant(
                  of: sizeStepper(),
                  matching: find.byType(TextField),
                ),
              )
              .width;
          const expected = 56.0;
          expect(actual, equals(expected));
        });
      });
      group('file status', () {
        testWidgets('new document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          final actual = [
            find.text('Cat').evaluate().length,
            find.text('Not saved').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('stored document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1)..storeId = '1',
                ),
              ),
            ),
          );
          final actual = find.text('Saved').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });

      group('timeline', () {
        testWidgets('single frame', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = [
            timelineState(tester),
            find.text('1 / 1').evaluate().length,
            frameControlsEnabled(tester),
          ];
          const expected = [
            [
              0,
              [0],
              10,
              false,
              0,
            ],
            1,
            [true, true, false, false, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('animation', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          final actual = [
            timelineState(tester),
            layerTimeframes(tester),
            frameHolds(tester),
            frameControlsEnabled(tester),
          ];
          const expected = [
            [
              0,
              [0, 1],
              10,
              false,
              0,
            ],
            [LayerTimeframe.constant, LayerTimeframe.perFrame],
            [1, 2],
            [true, true, true, false, true],
          ];
          expect(actual, equals(expected));
        });
      });

      group('layout', () {
        testWidgets('side pane below top bar', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final layersPanel = tester.getRect(find.byType(SidePanel).first);
          final historyPanel = tester.getRect(find.byType(SidePanel).last);
          final topBar = tester.getRect(find.byType(PaintBar).first);
          final bottomBar = tester.getRect(find.byType(PaintBar).last);
          final actual = [
            layersPanel.top == topBar.bottom,
            layersPanel.right,
            (historyPanel.bottom - bottomBar.top).abs() < 0.001,
            topBar.top,
            topBar.width,
            bottomBar.width,
          ];
          const expected = [true, 1280.0, true, 0.0, 1280.0, 1280.0];
          expect(actual, equals(expected));
        });
        testWidgets('top bar divider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final topBar = tester.widget<PaintBar>(find.byType(PaintBar).first);
          final actual = [topBar.shadow, topBar.border];
          const expected = [
            false,
            Border(bottom: BorderSide(color: PaintStyle.separatorColor)),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('status widths', (tester) async {
          useDesktopView(tester);
          final library = stubDocumentLibrary();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: library,
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 128, height: 64),
                ),
              ),
            ),
          );
          final initial = statusSectionWidths(tester);
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          final afterStroke = statusSectionWidths(tester);
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyS);
          await tester.pumpAndSettle();
          final afterSave = statusSectionWidths(tester);
          final actual = [afterStroke, afterSave];
          final expected = [initial, initial];
          expect(actual, equals(expected));
        });
        testWidgets('status widths while sizing', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 128, height: 64),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select (M)'));
          await tester.pump();
          final initial = statusSectionWidths(tester);
          final dragging = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 0, y: 0)),
          );
          await dragging.moveTo(
            canvasPixelCenter(tester, const PixelPoint(x: 5, y: 3)),
          );
          await tester.pump();
          final actual = statusSectionWidths(tester);
          final expected = initial;
          expect(actual, equals(expected));
        });
        testWidgets('shape buttons', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final line = tester.getCenter(find.byTooltip('Line (L)'));
          final arrow = tester.getCenter(find.byTooltip('Arrow (A)'));
          final circle = tester.getCenter(find.byTooltip('Circle (O)'));
          final rectangle = tester.getCenter(find.byTooltip('Rectangle (R)'));
          final actual = [
            arrow.dx == line.dx,
            arrow.dy > line.dy,
            circle.dx > line.dx,
            rectangle.dx == circle.dx,
            rectangle.dy > circle.dy,
          ];
          const expected = [true, true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('canvas edge shadow', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
          final sidePane = tester.getRect(find.byType(SidePane));
          final bottomBar = tester.getRect(find.byType(PaintBar).last);
          final actual = [
            edgeShadow.left,
            edgeShadow.top == topBar.bottom,
            edgeShadow.right == sidePane.left,
            edgeShadow.bottom == bottomBar.top,
          ];
          const expected = [0.0, true, true, true];
          expect(actual, equals(expected));
        });
      });
      group('canvas position', () {
        testWidgets('scrollbars', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = [
            for (final scrollbar in tester.widgetList<Scrollbar>(
              find.descendant(
                of: canvasArea(),
                matching: find.byType(Scrollbar),
              ),
            ))
              [
                scrollbar.thumbVisibility,
                scrollbar.trackVisibility,
                scrollbar.thickness,
              ],
          ];
          const expected = [
            [true, true, 12.0],
            [true, true, 12.0],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('scrollbar margin', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = tester
              .widget<ScrollbarTheme>(
                find.descendant(
                  of: canvasArea(),
                  matching: find.byType(ScrollbarTheme),
                ),
              )
              .data
              .crossAxisMargin;
          const expected = 2.0;
          expect(actual, equals(expected));
        });
        testWidgets('fit on open', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 64, height: 48),
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          final hidden = tester
              .widget<Opacity>(
                find
                    .descendant(
                      of: canvasArea(),
                      matching: find.byType(Opacity),
                    )
                    .first,
              )
              .opacity;
          await tester.pump();
          final actual = [
            hidden,
            tester
                .widget<Opacity>(
                  find
                      .descendant(
                        of: canvasArea(),
                        matching: find.byType(Opacity),
                      )
                      .first,
                )
                .opacity,
            canvasOffCenter(tester),
            canvasSize(tester),
          ];
          const expected = [0.0, 1.0, Offset.zero, Size(768, 576)];
          expect(actual, equals(expected));
        });
        testWidgets('loading until fit', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 64, height: 48),
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          final loading = find.text('Loading...').evaluate().length;
          await tester.pump();
          final actual = [loading, find.text('Loading...').evaluate().length];
          const expected = [1, 0];
          expect(actual, equals(expected));
        });
        testWidgets('fit on open reduced', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4000, height: 1000),
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          await tester.pump();
          final actual = [canvasOffCenter(tester), canvasSize(tester)];
          const expected = [Offset.zero, Size(1000, 250)];
          expect(actual, equals(expected));
        });
        testWidgets('small initial', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = canvasOffset(tester);
          const expected = Offset(15, 15);
          expect(actual, equals(expected));
        });
        testWidgets('small scrolled down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await scrollWheel(
            tester,
            at: tester.getCenter(canvasArea()),
            delta: const Offset(0, -100),
          );
          final actual = canvasOffset(tester);
          const expected = Offset(15, 115);
          expect(actual, equals(expected));
        });
        testWidgets('small scrolled right', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await scrollWheel(
            tester,
            at: tester.getCenter(canvasArea()),
            delta: const Offset(-100, 0),
          );
          final actual = canvasOffset(tester);
          const expected = Offset(115, 15);
          expect(actual, equals(expected));
        });
        testWidgets('small scrolled past end', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await scrollWheel(
            tester,
            at: tester.getCenter(canvasArea()),
            delta: const Offset(0, -5000),
          );
          final actual = canvasOffset(tester);
          const expected = Offset(15, 599);
          expect(actual, equals(expected));
        });
        testWidgets('large initial', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 400, height: 300),
                ),
              ),
            ),
          );
          final actual = canvasOffset(tester);
          const expected = Offset(15, 15);
          expect(actual, equals(expected));
        });
        testWidgets('large scrolled', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 400, height: 300),
                ),
              ),
            ),
          );
          await scrollWheel(
            tester,
            at: tester.getCenter(canvasArea()),
            delta: const Offset(0, 100),
          );
          final actual = canvasOffset(tester);
          const expected = Offset(15, -85);
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = [
            for (final sidePanel in tester.widgetList<SidePanel>(
              find.byType(SidePanel),
            ))
              sidePanel.title,
          ];
          const expected = ['Layers', 'Frames', 'History'];
          expect(actual, equals(expected));
        });
        testWidgets('panel divider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final actual = layerActionsEnabled(tester);
          const expected = [true, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('layer options', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          final actual = layerOptionsEnabled(tester);
          const expected = [false, true, false];
          expect(actual, equals(expected));
        });
        testWidgets('layer options with multiple layers', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          final actual = layerOptionsEnabled(tester);
          const expected = [true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('layer options on bottom layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Sketch'],
                    activeLayerIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          final actual = layerOptionsEnabled(tester);
          const expected = [false, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('close layer options', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          final actual = layerOptionsEnabled(tester);
          const expected = <bool>[];
          expect(actual, equals(expected));
        });
        testWidgets('thumbnail', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
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

      group('touch and stylus', () {
        testWidgets('touch drag', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 8, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          final initialOffsets = scrollOffsets(tester);
          final gesture = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 0, y: 0)),
            kind: PointerDeviceKind.touch,
          );
          for (var x = 1; x < 8; x++) {
            await gesture.moveTo(
              canvasPixelCenter(tester, PixelPoint(x: x, y: 0)),
            );
            await tester.pump();
          }
          await gesture.up();
          await tester.pump();
          final actual = [
            scrollOffsets(tester),
            pixelRows(document.activeLayer),
          ];
          final expected = [
            initialOffsets,
            [
              [black, black, black, black, black, black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('stylus drag', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 8, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          final initialOffsets = scrollOffsets(tester);
          final gesture = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 0, y: 0)),
            kind: PointerDeviceKind.stylus,
          );
          for (var x = 1; x < 8; x++) {
            await gesture.moveTo(
              canvasPixelCenter(tester, PixelPoint(x: x, y: 0)),
            );
            await tester.pump();
          }
          await gesture.up();
          await tester.pump();
          final actual = [
            scrollOffsets(tester),
            pixelRows(document.activeLayer),
          ];
          final expected = [
            initialOffsets,
            [
              [black, black, black, black, black, black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('invertedStylus drag', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 8, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          final initialOffsets = scrollOffsets(tester);
          final gesture = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 0, y: 0)),
            kind: PointerDeviceKind.invertedStylus,
          );
          for (var x = 1; x < 8; x++) {
            await gesture.moveTo(
              canvasPixelCenter(tester, PixelPoint(x: x, y: 0)),
            );
            await tester.pump();
          }
          await gesture.up();
          await tester.pump();
          final actual = [
            scrollOffsets(tester),
            pixelRows(document.activeLayer),
          ];
          final expected = [
            initialOffsets,
            [
              [black, black, black, black, black, black, black, black],
            ],
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser (E)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fill (G)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser (E)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fill (G)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Color picker (I)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Line (L)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Circle (O)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Arrow (A)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser (E)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Pen (P)'));
          await tester.pump();
          final actual = selectedTools(tester);
          const expected = [true, false, false, false];
          expect(actual, equals(expected));
        });
      });
      group('temporary tools', () {
        testWidgets('eraser', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await rightClick(tester, find.byTooltip('Eraser (E)'));
          final selected = selectedTools(tester);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          final actual = [selected, selectedTools(tester)];
          const expected = [
            [false, true, false, false],
            [true, false, false, false],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('pen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser (E)'));
          await tester.pump();
          await rightClick(tester, find.byTooltip('Pen (P)'));
          final actual = selectedTools(tester);
          const expected = [true, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('fill', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await rightClick(tester, find.byTooltip('Fill (G)'));
          final actual = selectedTools(tester);
          const expected = [false, false, true, false];
          expect(actual, equals(expected));
        });
        testWidgets('text', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await rightClick(tester, find.byTooltip('Text (T)'));
          final actual = textToolSelected(tester);
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('select', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await rightClick(tester, find.byTooltip('Select (M)'));
          final actual = selectToolSelected(tester);
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('shape', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await rightClick(tester, find.byTooltip('Circle (O)'));
          final actual = selectedShapes(tester);
          const expected = [false, false, true, false];
          expect(actual, equals(expected));
        });
        testWidgets('shape style', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await rightClick(tester, find.byTooltip('Fill shape'));
          await rightClick(tester, find.byTooltip('Outline'));
          final actual = shapeStyle(tester);
          const expected = [false, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('tip', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await rightClick(tester, find.byTooltip('Circle tip'));
          final actual = selectedTips(tester);
          const expected = [false, true];
          expect(actual, equals(expected));
        });
        testWidgets('size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await rightClick(tester, find.byTooltip('Increase size'));
          final actual = tester.widget<NumberStepper>(sizeStepper()).value;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('color', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await rightClick(tester, find.byType(Swatch).at(5));
          final colors = wellColors(tester);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          final actual = [
            colors,
            wellColors(tester),
            pixelRows(document.activeLayer),
          ];
          const expected = [
            [Color(0xff821717), Color(0xffffffff)],
            [Color(0xff000000), Color(0xffffffff)],
            [
              [transparent, 0xff821717],
              [transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('text format', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await rightClick(tester, find.byTooltip('Increase text size'));
          for (final tooltip in [
            'Bold',
            'Italic',
            'Underline',
            'Strikethrough',
          ]) {
            await rightClick(tester, find.byTooltip(tooltip));
          }
          final actual = textOptions(tester);
          const expected = [13, true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('text outline', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await rightClick(tester, find.byTooltip('Outline text'));
          await rightClick(tester, find.byTooltip('Increase outline width'));
          await rightClick(tester, find.byTooltip('Fill text'));
          final actual = textOutlineOptions(tester);
          const expected = [false, true, 2, true];
          expect(actual, equals(expected));
        });
      });
      group('tool sizes', () {
        testWidgets('pen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase size'));
          await tester.pump();
          final actual = tester.widget<NumberStepper>(sizeStepper()).value;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('eraser', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser (E)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Increase size'));
          await tester.pump();
          final actual = tester.widget<NumberStepper>(sizeStepper()).value;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('shape size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Increase size'));
          await tester.pump();
          final actual = tester.widget<NumberStepper>(sizeStepper()).value;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.drag(sizeSlider(), const Offset(200, 0));
          await tester.pump();
          final actual = tester.widget<NumberStepper>(sizeStepper()).value;
          const expected = 1000;
          expect(actual, equals(expected));
        });
        testWidgets('stepper moves slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase size'));
          await tester.pump();
          final actual = tester.widget<Slider>(sizeSlider()).value;
          const expected = 0.10034333188799373;
          expect(actual, equals(expected));
        });
        testWidgets('shared between tools', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase size'));
          await tester.tap(find.byTooltip('Circle tip'));
          await tester.tap(find.byTooltip('Line (L)'));
          await tester.pump();
          final actual = [
            tester.widget<NumberStepper>(sizeStepper()).value,
            selectedTips(tester),
          ];
          const expected = [
            2,
            [false, true],
          ];
          expect(actual, equals(expected));
        });
      });
      group('colors', () {
        testWidgets('primary swatch', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
      group('tool presets', () {
        testWidgets('after stroke', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final list = toolPresetList(tester);
          final actual = [list.presets, list.selected];
          const expected = [
            [
              ToolPreset(
                kind: ToolKind.pen,
                color: PixelColor.black,
                size: 1,
                tip: BrushTip.square,
              ),
            ],
            ToolPreset(
              kind: ToolKind.pen,
              color: PixelColor.black,
              size: 1,
              tip: BrushTip.square,
            ),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('apply', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Eraser (E)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Pen'));
          await tester.pump();
          final actual = allSelectedTools(tester);
          const expected = [
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('lock', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Add to favorites'));
          await tester.pump();
          final actual = [
            toolPresetList(tester).lockedCount,
            document.toolPresets,
          ];
          const expected = [
            1,
            ToolPresets(
              locked: [
                ToolPreset(
                  kind: ToolKind.pen,
                  color: PixelColor.black,
                  size: 1,
                  tip: BrushTip.square,
                ),
              ],
            ),
          ];
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
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(
                    width: 2,
                    height: 2,
                    background: const PixelColor(argb: 0xFFFF0000),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Color picker (I)'));
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
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(
                    width: 2,
                    height: 2,
                    background: const PixelColor(argb: 0xFFFF0000),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Color picker (I)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Eraser (E)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Color picker (I)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Edit colors'));
          await tester.pumpAndSettle();
          await tester.enterText(hexField(), '#FF0000');
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Secondary color'));
          await tester.pump();
          await tester.tap(find.byTooltip('Edit colors'));
          await tester.pumpAndSettle();
          await tester.enterText(hexField(), '#00FFFF');
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Edit colors'));
          await tester.pumpAndSettle();
          await tester.enterText(hexField(), '#FF0000');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = wellColors(tester);
          const expected = [Color(0xFF000000), Color(0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
      });
      group('image size', () {
        testWidgets('crop without selection', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 3, height: 2),
                ),
              ),
            ),
          );
          final actual = tester
              .widget<PaintIconButton>(
                find.ancestor(
                  of: find.byTooltip('Crop to selection'),
                  matching: find.byType(PaintIconButton),
                ),
              )
              .onPressed;
          const expected = null;
          expect(actual, equals(expected));
        });
        testWidgets('status bar size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 3, height: 2),
                ),
              ),
            ),
          );
          final actual = find
              .descendant(
                of: find.byType(PaintStatusButton),
                matching: find.text('3 × 2'),
              )
              .evaluate()
              .length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('status bar selecting', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 9, height: 9),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select (M)'));
          await tester.pump();
          final dragging = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 1, y: 2)),
          );
          await dragging.moveTo(
            canvasPixelCenter(tester, const PixelPoint(x: 4, y: 7)),
          );
          await tester.pump();
          final actual = find
              .descendant(
                of: find.byType(PaintStatusButton),
                matching: find.text('4 × 6'),
              )
              .evaluate()
              .length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('status bar shape', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 9, height: 9),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          final dragging = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 6, y: 5)),
          );
          await dragging.moveTo(
            canvasPixelCenter(tester, const PixelPoint(x: 2, y: 4)),
          );
          await tester.pump();
          final actual = find
              .descendant(
                of: find.byType(PaintStatusButton),
                matching: find.text('5 × 2'),
              )
              .evaluate()
              .length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('status bar constrained', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 9, height: 9),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          final dragging = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 2, y: 1)),
          );
          await dragging.moveTo(
            canvasPixelCenter(tester, const PixelPoint(x: 7, y: 3)),
          );
          await tester.pump();
          final actual = find
              .descendant(
                of: find.byType(PaintStatusButton),
                matching: find.text('6 × 6'),
              )
              .evaluate()
              .length;
          await dragging.up();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('status bar centered', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 9, height: 9),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          final dragging = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 4, y: 4)),
          );
          await dragging.moveTo(
            canvasPixelCenter(tester, const PixelPoint(x: 6, y: 5)),
          );
          await tester.pump();
          final actual = find
              .descendant(
                of: find.byType(PaintStatusButton),
                matching: find.text('5 × 3'),
              )
              .evaluate()
              .length;
          await dragging.up();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('status bar released', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 9, height: 9),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select (M)'));
          await tester.pump();
          final dragging = await tester.startGesture(
            canvasPixelCenter(tester, const PixelPoint(x: 1, y: 2)),
          );
          await dragging.moveTo(
            canvasPixelCenter(tester, const PixelPoint(x: 4, y: 7)),
          );
          await dragging.up();
          await tester.pump();
          final actual = find
              .descendant(
                of: find.byType(PaintStatusButton),
                matching: find.text('9 × 9'),
              )
              .evaluate()
              .length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('crop selection', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 2);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 2, y: 1),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select (M)'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final selecting = await tester.startGesture(
            topLeft + const Offset(5, 1),
          );
          await selecting.moveTo(topLeft + const Offset(9, 5));
          await selecting.up();
          await tester.pump();
          await tester.tap(find.byTooltip('Crop to selection'));
          await tester.pump();
          final actual = [
            canvasSize(tester),
            pixelRows(document.activeLayer),
            find.byTooltip('Resize image').evaluate().length,
            texts(tester).contains('2 × 2'),
          ];
          const expected = [
            Size(8, 8),
            [
              [transparent, transparent],
              [transparent, black],
            ],
            1,
            true,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('resize ok', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 1);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Resize image'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Width (px)')), '3');
          await tester.enterText(find.byKey(const Key('Height (px)')), '2');
          await tester.enterText(find.byKey(const Key('Offset X (px)')), '1');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = [canvasSize(tester), pixelRows(document.activeLayer)];
          const expected = [
            Size(12, 8),
            [
              [transparent, black, transparent],
              [transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('resize cancel', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Resize image'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Width (px)')), '3');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = [canvasSize(tester), document.width];
          const expected = [Size(8, 4), 2];
          expect(actual, equals(expected));
        });
        testWidgets('undo resize', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Resize image'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Width (px)')), '3');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Undo (Ctrl+Z)'));
          await tester.pump();
          final actual = [canvasSize(tester), document.width];
          const expected = [Size(8, 4), 2];
          expect(actual, equals(expected));
        });
      });

      group('canvas cursor', () {
        testWidgets('pen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PixelCanvas));
          final actual = tester
              .widget<PixelCanvas>(find.byType(PixelCanvas))
              .cursor;
          const expected = SystemMouseCursors.basic;
          expect(actual, equals(expected));
        });
        testWidgets('color picker', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Color picker (I)'));
          await tester.pump();
          await hoverOver(tester, find.byType(PixelCanvas));
          final actual = tester
              .widget<PixelCanvas>(find.byType(PixelCanvas))
              .cursor;
          const expected = SystemMouseCursors.basic;
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select (M)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select (M)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('right and down arrows', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.arrowRight);
          await pressShortcut(tester, key: LogicalKeyboardKey.arrowDown);
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
              [transparent, black, transparent],
              [transparent, transparent, transparent],
            ],
            [
              ['Start', 'Move selection', 'Move selection'],
              2,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('left and up arrows', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 2, y: 2),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.arrowLeft);
          await pressShortcut(tester, key: LogicalKeyboardKey.arrowUp);
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
              [transparent, black, transparent],
              [transparent, transparent, transparent],
            ],
            [
              ['Start', 'Move selection', 'Move selection'],
              2,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('shift arrow', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 11, height: 1);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.arrowRight,
            modifiers: [LogicalKeyboardKey.shiftLeft],
          );
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
          ];
          const expected = [
            [
              [
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                transparent,
                black,
              ],
            ],
            [
              ['Start', 'Move selection'],
              1,
            ],
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
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
      group('rename', () {
        testWidgets('status bar name', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          final actual = find
              .descendant(
                of: find.byType(PaintStatusButton),
                matching: find.text('Cat'),
              )
              .evaluate()
              .length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('ok', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(name: 'Cat', width: 2, height: 1);
          var renames = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                  onRenamed: () => renames++,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rename document'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Dog');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = [
            document.name,
            texts(tester).contains('Dog'),
            renames,
          ];
          const expected = ['Dog', true, 1];
          expect(actual, equals(expected));
        });
        testWidgets('cancel', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(name: 'Cat', width: 2, height: 1);
          var renames = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                  onRenamed: () => renames++,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rename document'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Dog');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = [document.name, renames];
          const expected = ['Cat', 0];
          expect(actual, equals(expected));
        });
        testWidgets('after save', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Rename document'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Dog');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          final actual = [
            find.text('Unsaved changes').evaluate().length,
            stubStore.entries.values.single.name,
          ];
          const expected = [1, 'Cat'];
          expect(actual, equals(expected));
        });
        testWidgets('save renamed', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rename document'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Dog');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          final actual = [
            find.text('Saved').evaluate().length,
            stubStore.entries.values.single.name,
          ];
          const expected = [1, 'Dog'];
          expect(actual, equals(expected));
        });
      });

      group('save', () {
        testWidgets('button', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          final actual = [
            stubStore.entries.length,
            find.text('Saved').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl s', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyS);
          await tester.pump();
          final actual = [
            stubStore.entries.length,
            find.text('Saved').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('save twice', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          final actual = stubStore.entries.length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('change after save', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          final actual = find.text('Unsaved changes').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('undo after save', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo (Ctrl+Z)'));
          await tester.pump();
          final actual = find.text('Unsaved changes').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('change during save', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore(holdSaves: true);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          stubStore.pendingSaves.single.complete();
          await tester.pump();
          final actual = find.text('Unsaved changes').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('failure', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore(saveError: Exception('disk'));
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          final actual = [
            find.text('Could not save').evaluate().length,
            find.text('Not saved').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('after close', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore(holdSaves: true);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pumpWidget(const SizedBox());
          stubStore.pendingSaves.single.complete();
          await tester.pump();
          final actual = [stubStore.entries.length, tester.takeException()];
          const expected = [1, null];
          expect(actual, equals(expected));
        });
        testWidgets('failure after close', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore(
            saveError: Exception('disk'),
            holdSaves: true,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pumpWidget(const SizedBox());
          stubStore.pendingSaves.single.complete();
          await tester.pump();
          final actual = tester.takeException();
          const expected = null;
          expect(actual, equals(expected));
        });
      });

      group('export', () {
        testWidgets('default format', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export as PNG (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.format],
          ];
          const expected = [
            ['Cat.png', ExportFormat.png],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('chosen format', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export formats'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Export as ORA'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Export as ORA (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.format],
          ];
          const expected = [
            ['Cat.ora', ExportFormat.ora],
            ['Cat.ora', ExportFormat.ora],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('gif', (tester) async {
          final stubFiles = StubFileAccess();
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export formats'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Export as GIF'));
          await tester.pumpAndSettle();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.format],
          ];
          const expected = [
            ['Cat.gif', ExportFormat.gif],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('remembered path', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess(savePath: '/pictures/dog.png');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export as PNG (Ctrl+Shift+E)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Export to dog.png (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.directory],
            for (final file in stubFiles.overwritten) [file.path, file.format],
          ];
          const expected = [
            ['Cat.png', null],
            ['/pictures/dog.png', ExportFormat.png],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('opened path', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1)
                    ..filePath = '/pictures/cat.png',
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export to cat.png (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.format],
            for (final file in stubFiles.overwritten) [file.path, file.format],
          ];
          const expected = [
            ['/pictures/cat.png', ExportFormat.png],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('path of other format', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1)
                    ..filePath = '/pictures/cat.gif',
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export as PNG (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.directory],
            for (final file in stubFiles.overwritten) [file.path, file.format],
          ];
          const expected = [
            ['Cat.png', '/pictures/'],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('dropdown with path', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1)
                    ..filePath = '/pictures/cat.png',
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export formats'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Export as PNG'));
          await tester.pumpAndSettle();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.directory],
            for (final file in stubFiles.overwritten) [file.path, file.format],
          ];
          const expected = [
            ['Cat.png', '/pictures/'],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('recent directory', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess();
          final library = stubDocumentLibrary(
            store: StubDocumentStore()
              ..entries['1'] = storedDocument(
                id: '1',
                filePath: '/recent/dog.png',
              ),
          );
          await library.refresh();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: library,
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export as PNG (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.directory],
          ];
          const expected = [
            ['Cat.png', '/recent/'],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('overwrite failure', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(saveError: Exception('denied')),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1)
                    ..filePath = '/pictures/cat.png',
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export to cat.png (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = find.text('Could not export').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('closed while choosing', (tester) async {
          useDesktopView(tester);
          final saveGate = Completer<void>();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(
                    savePath: '/pictures/dog.png',
                    saveGate: saveGate,
                  ),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export as PNG (Ctrl+Shift+E)'));
          await tester.pumpWidget(const SizedBox());
          saveGate.complete();
          await tester.pump();
          final actual = tester.takeException();
          const expected = null;
          expect(actual, equals(expected));
        });
        testWidgets('failure', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(saveError: Exception('denied')),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Export as PNG (Ctrl+Shift+E)'));
          await tester.pump();
          final actual = find.text('Could not export').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });

      group('timeline', () {
        testWidgets('add frame', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add frame (Alt+N)'));
          await tester.pump();
          final actual = [timelineState(tester), historyState(tester)];
          const expected = [
            [
              1,
              [0, 1],
              10,
              false,
              1,
            ],
            [
              ['Start', 'Add frame'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('copy frame', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Copy frame (Alt+D)'));
          await tester.pump();
          final actual = [
            timelineState(tester),
            frameHolds(tester),
            historyState(tester),
          ];
          const expected = [
            [
              1,
              [0, 1, 2],
              10,
              false,
              1,
            ],
            [1, 1, 2],
            [
              ['Start', 'Copy frame'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('remove frame', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Remove frame (Alt+Del)'));
          await tester.pump();
          final actual = [timelineState(tester), historyState(tester)];
          const expected = [
            [
              0,
              [0],
              10,
              false,
              0,
            ],
            [
              ['Start', 'Remove frame'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('move frame', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Move frame down (Alt+.)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Move frame up (Alt+,)'));
          await tester.pump();
          final actual = [frameHolds(tester), historyState(tester)];
          const expected = [
            [1, 2],
            [
              ['Start', 'Move frame down', 'Move frame up'],
              2,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('select from slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          final slider = find.descendant(
            of: find.byType(Timeline),
            matching: find.byType(Slider),
          );
          await tester.ensureVisible(slider);
          await tester.drag(slider, const Offset(2000, 0));
          await tester.pump();
          final actual = timelineState(tester);
          const expected = [
            1,
            [0, 1],
            10,
            false,
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('select from frames pane', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(
            find
                .byWidgetPredicate(
                  (widget) => widget is Text && widget.data == '2',
                )
                .first,
          );
          await tester.pump();
          final actual = timelineState(tester);
          const expected = [
            1,
            [0, 1],
            10,
            false,
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('next and previous', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Next frame (.)'));
          await tester.pump();
          final next = timelineState(tester).first;
          await tester.tap(find.byTooltip('Previous frame (,)'));
          await tester.pump();
          final actual = [next, timelineState(tester).first];
          const expected = [1, 0];
          expect(actual, equals(expected));
        });
        testWidgets('frame holds', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fewer holds').last);
          await tester.pump();
          final actual = [
            timelineState(tester),
            frameHolds(tester),
            historyState(tester),
          ];
          const expected = [
            [
              0,
              [0, 1],
              10,
              false,
              0,
            ],
            [1, 1],
            [
              ['Start', 'Frame holds'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('hide frame', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Fewer holds').last);
          await tester.pump();
          await tester.tap(find.byTooltip('Fewer holds').last);
          await tester.pump();
          final actual = [
            timelineState(tester),
            find.text('1 / 1').evaluate().length,
          ];
          const expected = [
            [
              0,
              [0],
              10,
              false,
              0,
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('frame rate', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.ensureVisible(find.byTooltip('Increase frame rate'));
          await tester.tap(find.byTooltip('Increase frame rate'));
          await tester.pump();
          final actual = [timelineState(tester), historyState(tester)];
          const expected = [
            [
              0,
              [0, 1],
              11,
              false,
              0,
            ],
            [
              ['Start', 'Frame rate'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('onion skinning', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          final before = canvasLayers(tester).length;
          await tester.ensureVisible(find.byTooltip('Onion skinning (F3)'));
          await tester.tap(find.byTooltip('Onion skinning (F3)'));
          await tester.pump();
          final actual = [before, canvasLayers(tester).length];
          const expected = [2, 3];
          expect(actual, equals(expected));
        });
        testWidgets('layer timeframe', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Use image per frame'));
          await tester.pump();
          final actual = [layerTimeframes(tester), historyState(tester)];
          const expected = [
            [LayerTimeframe.perFrame, LayerTimeframe.perFrame],
            [
              ['Start', 'Image per frame'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('playback', () {
        testWidgets('play', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Play (Enter)'));
          await tester.pump();
          final started = timelineState(tester);
          await tester.pump(const Duration(milliseconds: 100));
          final advanced = timelineState(tester);
          await tester.pump(const Duration(milliseconds: 200));
          final wrapped = timelineState(tester);
          await tester.tap(find.byTooltip('Pause (Enter)'));
          await tester.pump();
          final actual = [started, advanced, wrapped];
          const expected = [
            [
              0,
              [0, 1],
              10,
              true,
              0,
            ],
            [
              1,
              [0, 1],
              10,
              true,
              1,
            ],
            [
              0,
              [0, 1],
              10,
              true,
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('pause', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Play (Enter)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Pause (Enter)'));
          await tester.pump(const Duration(milliseconds: 500));
          final actual = [timelineState(tester), historyState(tester)];
          const expected = [
            [
              0,
              [0, 1],
              10,
              false,
              0,
            ],
            [
              ['Start'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('onion skinning off', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.ensureVisible(find.byTooltip('Onion skinning (F3)'));
          await tester.tap(find.byTooltip('Onion skinning (F3)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Play (Enter)'));
          await tester.pump();
          final playing = canvasLayers(tester).length;
          await tester.tap(find.byTooltip('Pause (Enter)'));
          await tester.pump();
          final actual = [playing, canvasLayers(tester).length];
          const expected = [2, 3];
          expect(actual, equals(expected));
        });
        testWidgets('drawing', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Play (Enter)'));
          await tester.pump();
          await tester.tap(find.byType(PixelCanvas));
          await tester.pump(const Duration(milliseconds: 500));
          final actual = timelineState(tester);
          const expected = [
            0,
            [0, 1],
            10,
            false,
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('dispose while playing', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Play (Enter)'));
          await tester.pump();
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(milliseconds: 500));
          final actual = find.byType(EditorView).evaluate().length;
          const expected = 0;
          expect(actual, equals(expected));
        });
      });

      group('clipboard', () {
        testWidgets('actions without selection', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          final actual = clipboardActionsEnabled(tester);
          const expected = [true, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('actions with selection', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          final actual = clipboardActionsEnabled(tester);
          const expected = [true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('copy button', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard();
          final document = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Copy (Ctrl+C)'));
          await tester.pump();
          final actual = [
            [for (final image in stubClipboard.written) pixelRows(image)],
            pixelRows(document.activeLayer),
            historyState(tester),
          ];
          const expected = [
            [
              [
                [black, black],
              ],
            ],
            [
              [black, black],
            ],
            [
              ['Start'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('cut button', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard();
          final document = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Cut (Ctrl+X)'));
          await tester.pump();
          final actual = [
            [for (final image in stubClipboard.written) pixelRows(image)],
            pixelRows(document.activeLayer),
            historyState(tester),
          ];
          const expected = [
            [
              [
                [black, black],
              ],
            ],
            [
              [transparent, transparent],
            ],
            [
              ['Start', 'Cut'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('paste button', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(
                    image: layerFromRows([
                      [black, black, black],
                    ]),
                  ),
                  document: document,
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pump();
          final actual = [
            layerState(tester),
            pixelRows(document.activeLayer),
            historyState(tester),
            selectToolSelected(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            [
              [transparent, transparent, transparent],
              [black, black, black],
              [transparent, transparent, transparent],
            ],
            [
              ['Start', 'Paste'],
              1,
            ],
            true,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('paste at pointer', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(
                    image: layerFromRows([
                      [black, black, black],
                    ]),
                  ),
                  document: document,
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          await tester.pump();
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          addTearDown(mouse.removePointer);
          await mouse.moveTo(
            tester.getTopLeft(find.byType(PixelCanvas)) +
                const Offset(2.5, 0.5) *
                    tester.widget<PixelCanvas>(find.byType(PixelCanvas)).zoom,
          );
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black, black],
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('paste at pointer outside document', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(
                    image: layerFromRows([
                      [black, black, black],
                    ]),
                  ),
                  document: document,
                ),
              ),
            ),
          );
          await tester.pump();
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          addTearDown(mouse.removePointer);
          await mouse.moveTo(
            tester.getTopLeft(find.byType(PixelCanvas)) +
                const Offset(-0.5, 2.5) *
                    tester.widget<PixelCanvas>(find.byType(PixelCanvas)).zoom,
          );
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
            [black, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('paste after pointer exit', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(
                    image: layerFromRows([
                      [black, black, black],
                    ]),
                  ),
                  document: document,
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          await tester.pump();
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          addTearDown(mouse.removePointer);
          await mouse.moveTo(
            tester.getTopLeft(find.byType(PixelCanvas)) +
                const Offset(0.5, 0.5) *
                    tester.widget<PixelCanvas>(find.byType(PixelCanvas)).zoom,
          );
          await mouse.moveTo(Offset.zero);
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent, transparent],
            [black, black, black],
            [transparent, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('paste empty clipboard', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pump();
          final actual = historyState(tester);
          const expected = [
            ['Start'],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('paste after close', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard(holdReads: true);
          final document = Document.blank(width: 2, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pumpWidget(const SizedBox());
          stubClipboard.pendingReads.single.complete(
            layerFromRows([
              [black],
            ]),
          );
          await tester.pump();
          final actual = [document.layers.length, tester.takeException()];
          const expected = [1, null];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl c', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: Document.blank(
                    width: 2,
                    height: 1,
                    background: PixelColor.black,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyC);
          final actual = [
            for (final image in stubClipboard.written) pixelRows(image),
          ];
          const expected = [
            [
              [black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl c without selection', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyC);
          final actual = stubClipboard.written;
          const expected = [];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl x', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard();
          final document = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyX);
          final actual = [
            [for (final image in stubClipboard.written) pixelRows(image)],
            pixelRows(document.activeLayer),
          ];
          const expected = [
            [
              [
                [black, black],
              ],
            ],
            [
              [transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl x without selection', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyX);
          final actual = [stubClipboard.written, historyState(tester)];
          const expected = [
            [],
            [
              ['Start'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl v into selection', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 1);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(
                    image: layerFromRows([
                      [black],
                    ]),
                  ),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyV);
          final actual = [
            pixelRows(document.activeLayer),
            historyState(tester),
          ];
          const expected = [
            [
              [black, transparent],
            ],
            [
              ['Start', 'Paste'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('copy delete paste', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 1);
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyC);
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          await tester.pump();
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyV);
          final actual = [
            pixelRows(document.activeLayer),
            document.layers.length,
            historyState(tester),
          ];
          const expected = [
            [
              [black, transparent],
            ],
            1,
            [
              ['Start', 'Delete selection', 'Paste'],
              2,
            ],
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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

      group('all frames', () {
        testWidgets('toggle off', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: filmDocument(
                    frames: [
                      [
                        [red, transparent],
                      ],
                      [
                        [green, transparent],
                      ],
                    ],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('All frames'));
          await tester.pump();
          await tester.tap(find.byTooltip('All frames'));
          await tester.pump();
          final actual = allFramesButtonState(tester);
          const expected = [true, false];
          expect(actual, equals(expected));
        });
        testWidgets('copy delete paste', (tester) async {
          final document = filmDocument(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
            activeFrameIndex: 0,
          );
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.byTooltip('All frames'));
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Copy (Ctrl+C)'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pump();
          final actual = framePixelRows(document);
          const expected = [
            [
              [red, transparent],
            ],
            [
              [green, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('external override', (tester) async {
          final stubClipboard = StubImageClipboard();
          final document = filmDocument(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
            activeFrameIndex: 0,
          );
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  document: document,
                  fitOnOpen: true,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.byTooltip('All frames'));
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Copy (Ctrl+C)'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          stubClipboard.image = layerFromRows([
            [blue, blue],
          ]);
          await tester.tap(find.byTooltip('Paste (Ctrl+V)'));
          await tester.pump();
          final actual = framePixelRows(document);
          const expected = [
            [
              [blue, blue],
            ],
            [
              [blue, blue],
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('history thumbnail', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: filmDocument(
                    frames: [
                      [
                        [red, transparent],
                      ],
                      [
                        [green, transparent],
                      ],
                    ],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('All frames'));
          await tester.tap(find.byTooltip('Select all (Ctrl+A)'));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          await tester.pump();
          final actual = historyThumbnails(tester)[1];
          final expected = [
            Layer.filled(width: 2, height: 1, color: PixelColor.transparent),
            const Rect.fromLTRB(0, 0, 2, 1),
          ];
          expect(actual, equals(expected));
        });
      });
      group('all frames options', () {
        testWidgets('toggle previous', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: filmDocument(
                    frames: [
                      [
                        [red, transparent],
                      ],
                      [
                        [green, transparent],
                      ],
                    ],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('All frames options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Include previous frames'));
          await tester.pump();
          final actual = allFramesDirections(tester);
          const expected = [false, true];
          expect(actual, equals(expected));
        });
        testWidgets('toggle next', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: filmDocument(
                    frames: [
                      [
                        [red, transparent],
                      ],
                      [
                        [green, transparent],
                      ],
                    ],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('All frames options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Include next frames'));
          await tester.pump();
          final actual = allFramesDirections(tester);
          const expected = [true, false];
          expect(actual, equals(expected));
        });
      });
      group('history thumbnails', () {
        testWidgets('start', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
        testWidgets('stroke before resize', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Resize image'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Width (px)')), '4');
          await tester.enterText(find.byKey(const Key('Height (px)')), '4');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = historyThumbnails(tester)[1];
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
        testWidgets('after stroke', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo (Ctrl+Z)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo (Ctrl+Z)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Redo (Ctrl+Y / Ctrl+Shift+Z)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo (Ctrl+Z)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
        testWidgets(
          'cmd z on macos',
          (tester) async {
            useDesktopView(tester);
            final document = Document.blank(width: 2, height: 2);
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: EditorView(
                    files: StubFileAccess(),
                    library: stubDocumentLibrary(),
                    clipboard: StubImageClipboard(),
                    document: document,
                  ),
                ),
              ),
            );
            final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
            await tester.tapAt(topLeft + const Offset(1, 1));
            await tester.pump();
            await pressShortcut(
              tester,
              key: LogicalKeyboardKey.keyZ,
              modifiers: [LogicalKeyboardKey.metaLeft],
            );
            final actual = historyState(tester);
            const expected = [
              ['Start', 'Pen'],
              0,
            ];
            expect(actual, equals(expected));
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
        testWidgets(
          'ctrl z on macos',
          (tester) async {
            useDesktopView(tester);
            final document = Document.blank(width: 2, height: 2);
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: EditorView(
                    files: StubFileAccess(),
                    library: stubDocumentLibrary(),
                    clipboard: StubImageClipboard(),
                    document: document,
                  ),
                ),
              ),
            );
            final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
            await tester.tapAt(topLeft + const Offset(1, 1));
            await tester.pump();
            await pressShortcut(
              tester,
              key: LogicalKeyboardKey.keyZ,
              modifiers: [LogicalKeyboardKey.controlLeft],
            );
            final actual = historyState(tester);
            const expected = [
              ['Start', 'Pen'],
              1,
            ];
            expect(actual, equals(expected));
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
        testWidgets(
          'cmd tooltip on macos',
          (tester) async {
            useDesktopView(tester);
            final document = Document.blank(width: 2, height: 2);
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: EditorView(
                    files: StubFileAccess(),
                    library: stubDocumentLibrary(),
                    clipboard: StubImageClipboard(),
                    document: document,
                  ),
                ),
              ),
            );
            final actual = find.byTooltip('Save (Cmd+S)');
            expect(actual, findsOneWidget);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
        testWidgets('ctrl y', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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

      group('file shortcuts', () {
        testWidgets('ctrl shift e', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(name: 'Cat', width: 2, height: 1),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyE,
            modifiers: [
              LogicalKeyboardKey.controlLeft,
              LogicalKeyboardKey.shiftLeft,
            ],
          );
          final actual = [
            for (final file in stubFiles.saved) [file.fileName, file.format],
          ];
          const expected = [
            ['Cat.png', ExportFormat.png],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl shift z', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyZ,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyZ,
            modifiers: [
              LogicalKeyboardKey.controlLeft,
              LogicalKeyboardKey.shiftLeft,
            ],
          );
          final actual = historyState(tester);
          const expected = [
            ['Start', 'Pen'],
            1,
          ];
          expect(actual, equals(expected));
        });
      });

      group('selection shortcuts', () {
        testWidgets('ctrl a', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyA,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          final actual = [
            selectToolSelected(tester),
            selectionActionsEnabled(tester),
          ];
          const expected = [
            true,
            [true, true, true, true],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('escape', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyA,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.escape);
          final actual = [
            selectToolSelected(tester),
            selectionActionsEnabled(tester),
          ];
          const expected = [
            true,
            [false, false, false, false],
          ];
          expect(actual, equals(expected));
        });
      });

      group('tool shortcuts', () {
        testWidgets('tab', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2)
                    ..toolPresets = const ToolPresets(
                      recent: [
                        ToolPreset(
                          kind: ToolKind.eraser,
                          size: 1,
                          tip: BrushTip.square,
                        ),
                        ToolPreset(
                          kind: ToolKind.bucketFill,
                          color: PixelColor.black,
                        ),
                      ],
                    ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.tab);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('shift tab', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2)
                    ..toolPresets = const ToolPresets(
                      recent: [
                        ToolPreset(
                          kind: ToolKind.eraser,
                          size: 1,
                          tip: BrushTip.square,
                        ),
                        ToolPreset(
                          kind: ToolKind.bucketFill,
                          color: PixelColor.black,
                        ),
                      ],
                    ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.tab,
            modifiers: [LogicalKeyboardKey.shiftLeft],
          );
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('1', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2)
                    ..toolPresets = const ToolPresets(
                      locked: [ToolPreset(kind: ToolKind.eraser, size: 1)],
                    ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.digit1);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('recent preset', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2)
                    ..toolPresets = const ToolPresets(
                      recent: [ToolPreset(kind: ToolKind.eraser, size: 1)],
                    ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.digit1);
          final actual = allSelectedTools(tester);
          const expected = [
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('p', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          await pressShortcut(tester, key: LogicalKeyboardKey.keyP);
          final actual = allSelectedTools(tester);
          const expected = [
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('e', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('g', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyG);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('i', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyI);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('m', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyM);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            false,
            false,
            true,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('l', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyL);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            false,
            false,
            false,
            true,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('r', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyR);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            false,
            false,
            false,
            false,
            true,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('o', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyO);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            true,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('a', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyA);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            true,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('brackets', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.bracketRight);
          await pressShortcut(tester, key: LogicalKeyboardKey.bracketRight);
          await pressShortcut(tester, key: LogicalKeyboardKey.bracketLeft);
          final actual = tester.widget<NumberStepper>(sizeStepper()).value;
          const expected = 2;
          expect(actual, equals(expected));
        });
      });

      group('color shortcuts', () {
        testWidgets('x', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyX);
          final actual = wellColors(tester);
          const expected = [Color(0xFFFFFFFF), Color(0xFF000000)];
          expect(actual, equals(expected));
        });
      });

      group('view shortcuts', () {
        testWidgets('ctrl equal', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.equal,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('ctrl equal keeps center pixel', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 400, height: 400),
                ),
              ),
            ),
          );
          final center = canvasAreaCenter(tester);
          final before = canvasPixelAt(tester, point: center);
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.equal,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          final actual = canvasPixelAt(tester, point: center);
          final expected = before;
          expect(actual, equals(expected));
        });
        testWidgets('ctrl 0 after scrolling', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 64, height: 48),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.digit0,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          await scrollWheel(
            tester,
            at: tester.getCenter(canvasArea()),
            delta: const Offset(0, 100),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.digit0,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          final actual = [canvasOffCenter(tester), canvasSize(tester)];
          const expected = [Offset.zero, Size(768, 576)];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl scroll at maximum', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.enterText(
            find.descendant(
              of: find.ancestor(
                of: find.text('Zoom:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(TextField),
            ),
            '96',
          );
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(
            tester,
            at: tester.getCenter(canvasArea()),
            delta: const Offset(0, -50),
          );
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          final actual = canvasSize(tester);
          const expected = Size(192, 192);
          expect(actual, equals(expected));
        });
        testWidgets('ctrl minus', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.minus,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          final actual = canvasSize(tester);
          const expected = Size(6, 6);
          expect(actual, equals(expected));
        });
        testWidgets('ctrl 0', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.equal,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.digit0,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          final actual = [canvasOffCenter(tester), canvasSize(tester)];
          const expected = [Offset.zero, Size(192, 192)];
          expect(actual, equals(expected));
        });
      });

      group('animation shortcuts', () {
        testWidgets('comma', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.comma);
          final actual = timelineState(tester);
          const expected = [
            0,
            [0, 1, 2],
            10,
            false,
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('period', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.period);
          final actual = timelineState(tester);
          const expected = [
            2,
            [0, 1, 2],
            10,
            false,
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('home', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.home);
          final actual = timelineState(tester);
          const expected = [
            0,
            [0, 1, 2],
            10,
            false,
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('end', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.end);
          final actual = timelineState(tester);
          const expected = [
            2,
            [0, 1, 2],
            10,
            false,
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('enter', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.enter);
          final playing = timelineState(tester);
          await pressShortcut(tester, key: LogicalKeyboardKey.enter);
          final actual = [playing, timelineState(tester)];
          const expected = [
            [
              1,
              [0, 1, 2],
              10,
              true,
              1,
            ],
            [
              1,
              [0, 1, 2],
              10,
              false,
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('f3', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.f3);
          final actual = timelineOnionSkin(tester);
          const expected = OnionSkin(enabled: true);
          expect(actual, equals(expected));
        });
        testWidgets('alt n', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyN,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [frameHolds(tester), timelineState(tester).first];
          const expected = [
            [1, 2, 1, 3],
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt d', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyD,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [frameHolds(tester), timelineState(tester).first];
          const expected = [
            [1, 2, 2, 3],
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt delete', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.delete,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [frameHolds(tester), timelineState(tester).first];
          const expected = [
            [1, 3],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt comma', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.comma,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [frameHolds(tester), timelineState(tester).first];
          const expected = [
            [2, 1, 3],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt period', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.period,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [frameHolds(tester), timelineState(tester).first];
          const expected = [
            [1, 3, 2],
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt minus', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.minus,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [frameHolds(tester), timelineState(tester).first];
          const expected = [
            [1, 1, 3],
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt equal', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.equal,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [frameHolds(tester), timelineState(tester).first];
          const expected = [
            [1, 3, 3],
            1,
          ];
          expect(actual, equals(expected));
        });
      });

      group('layer shortcuts', () {
        testWidgets('shift n', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyN,
            modifiers: [LogicalKeyboardKey.shiftLeft],
          );
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Middle', 'Layer 4', 'Top'],
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('shift d', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyD,
            modifiers: [LogicalKeyboardKey.shiftLeft],
          );
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Middle', 'Middle copy', 'Top'],
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl e', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.keyE,
            modifiers: [LogicalKeyboardKey.controlLeft],
          );
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Top'],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('f2', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.f2);
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Ink');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Ink', 'Top'],
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('shift delete', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.delete,
            modifiers: [LogicalKeyboardKey.shiftLeft],
          );
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Top'],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('page up', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.pageUp);
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Middle', 'Top'],
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('page down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.pageDown);
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Middle', 'Top'],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt page up', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.pageUp,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Background', 'Top', 'Middle'],
            2,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt page down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: layeredDocument(
                    names: ['Background', 'Middle', 'Top'],
                    activeLayerIndex: 1,
                  ),
                ),
              ),
            ),
          );
          await pressShortcut(
            tester,
            key: LogicalKeyboardKey.pageDown,
            modifiers: [LogicalKeyboardKey.altLeft],
          );
          final actual = [layerState(tester).first, layerState(tester).last];
          const expected = [
            ['Middle', 'Background', 'Top'],
            0,
          ];
          expect(actual, equals(expected));
        });
      });

      group('shape style', () {
        testWidgets('fill on', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill shape'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('outline off', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill shape'));
          await tester.pump();
          await tester.tap(find.byTooltip('Outline'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [false, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('last style stays', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Outline'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [true, true, false, true];
          expect(actual, equals(expected));
        });
        testWidgets('fill off', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill shape'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill shape'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [true, true, false, true];
          expect(actual, equals(expected));
        });
        testWidgets('outline on', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill shape'));
          await tester.pump();
          await tester.tap(find.byTooltip('Outline'));
          await tester.pump();
          await tester.tap(find.byTooltip('Outline'));
          await tester.pump();
          final actual = shapeStyle(tester);
          const expected = [true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('filled rectangle', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill shape'));
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
            [black, white, black],
            [black, black, black],
          ];
          expect(actual, equals(expected));
        });
      });

      group('held shape constraint', () {
        testWidgets('shift down', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.moveTo(topLeft + const Offset(9, 5));
          await gesture.up();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black],
            [black, transparent, black],
            [black, black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('shift up', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.moveTo(topLeft + const Offset(9, 5));
          await gesture.up();
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black],
            [black, black, black],
            [transparent, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('right shift', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftRight);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.moveTo(topLeft + const Offset(9, 5));
          await gesture.up();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftRight);
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

      group('text tool', () {
        testWidgets('shortcut', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyT);
          final actual = textToolSelected(tester);
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('rotate draft', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          await tester.tapAt(tester.getTopLeft(find.byType(PixelCanvas)));
          await tester.pump();
          await tester.tap(find.byTooltip('Rotate right'));
          await tester.pump();
          final actual = tester
              .widget<RotatedBox>(
                find.descendant(
                  of: find.byType(TextDraft),
                  matching: find.byType(RotatedBox),
                ),
              )
              .quarterTurns;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('mirror draft', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          await tester.tapAt(tester.getTopLeft(find.byType(PixelCanvas)));
          await tester.pump();
          await tester.tap(find.byTooltip('Mirror horizontally'));
          await tester.pump();
          final actual = tester
              .widget<TextDraft>(find.byType(TextDraft))
              .orientation;
          const expected = TextOrientation(mirrored: true);
          expect(actual, equals(expected));
        });
        testWidgets('transform keeps focus', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          await tester.tapAt(tester.getTopLeft(find.byType(PixelCanvas)));
          await tester.pump();
          await tester.tap(find.byTooltip('Rotate left'));
          await tester.pump();
          final actual =
              FocusManager.instance.primaryFocus?.context
                  ?.findAncestorWidgetOfExactType<TextDraft>() !=
              null;
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('increase size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await tester.tap(find.byTooltip('Increase text size'));
          await tester.pump();
          final actual = textOptions(tester);
          const expected = [13, false, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('increase rounded size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await tester.enterText(
            find.descendant(
              of: find.ancestor(
                of: find.byTooltip('Increase text size'),
                matching: find.byType(NumberStepper),
              ),
              matching: find.byType(TextField),
            ),
            '63',
          );
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          await tester.tap(find.byTooltip('Increase text size'));
          await tester.pump();
          final actual = textOptions(tester);
          const expected = [65, false, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('decrease rounded size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await tester.enterText(
            find.descendant(
              of: find.ancestor(
                of: find.byTooltip('Increase text size'),
                matching: find.byType(NumberStepper),
              ),
              matching: find.byType(TextField),
            ),
            '63',
          );
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          await tester.tap(find.byTooltip('Decrease text size'));
          await tester.pump();
          final actual = textOptions(tester);
          const expected = [60, false, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('size slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await tester.tap(
            find.descendant(
              of: find
                  .ancestor(
                    of: find.byTooltip('Increase text size'),
                    matching: find.byType(IntrinsicWidth),
                  )
                  .first,
              matching: find.byType(Slider),
            ),
          );
          await tester.pump();
          final actual = textOptions(tester);
          const expected = [22, false, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('rounded size slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          final slider = find.descendant(
            of: find
                .ancestor(
                  of: find.byTooltip('Increase text size'),
                  matching: find.byType(IntrinsicWidth),
                )
                .first,
            matching: find.byType(Slider),
          );
          final rect = tester.getRect(slider);
          await tester.tapAt(
            Offset(rect.left + rect.width * 0.75, rect.center.dy),
          );
          await tester.pump();
          final actual = textOptions(tester);
          const expected = [130, false, false, false, false];
          expect(actual, equals(expected));
        });
        testWidgets('toggles', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          for (final tooltip in [
            'Bold',
            'Italic',
            'Underline',
            'Strikethrough',
          ]) {
            await tester.tap(find.byTooltip(tooltip));
            await tester.pump();
          }
          final actual = textOptions(tester);
          const expected = [12, true, true, true, true];
          expect(actual, equals(expected));
        });
        testWidgets('outline options', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await tester.tap(find.byTooltip('Outline text'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill text'));
          await tester.pump();
          await tester.tap(find.byTooltip('Increase outline width'));
          await tester.pump();
          final actual = textOutlineOptions(tester);
          const expected = [false, true, 2, true];
          expect(actual, equals(expected));
        });
        testWidgets('outline width disabled', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          final actual = textOutlineOptions(tester);
          const expected = [true, false, 1, false];
          expect(actual, equals(expected));
        });
        testWidgets('hollow draft', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          await tester.tapAt(tester.getTopLeft(find.byType(PixelCanvas)));
          await tester.pump();
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await tester.tap(find.byTooltip('Outline text'));
          await tester.pump();
          await tester.tap(find.byTooltip('Fill text'));
          await tester.pump();
          final textDraft = tester.widget<TextDraft>(find.byType(TextDraft));
          final actual = [
            textDraft.style.color,
            textDraft.outlineStyle?.foreground?.color,
            textDraft.cursorColor,
            textDraft.padding,
          ];
          const expected = [
            Color(0x00000000),
            Color(0xffffffff),
            Color(0xff000000),
            4.0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('draft style', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          await tester.tapAt(tester.getTopLeft(find.byType(PixelCanvas)));
          await tester.pump();
          await tester.tap(find.byTooltip('Text options'));
          await tester.pump();
          await tester.tap(find.byTooltip('Bold'));
          await tester.pump();
          final actual = tester.widget<TextDraft>(find.byType(TextDraft)).style;
          final expected = const TextFormat(
            bold: true,
          ).style(scale: 4, color: PixelColor.black);
          expect(actual, equals(expected));
        });
        testWidgets('move draft', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 5));
          await tester.pump();
          final gesture = await tester.startGesture(
            tester.getTopLeft(find.byType(TextDraft)) + const Offset(2, 2),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.moveBy(const Offset(8, 4));
          await gesture.up();
          await tester.pump();
          final actual = textFieldOffset(tester);
          const expected = Offset(12, 8);
          expect(actual, equals(expected));
        });
        testWidgets('move draft partial pixels', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 5));
          await tester.pump();
          final gesture = await tester.startGesture(
            tester.getTopLeft(find.byType(TextDraft)) + const Offset(2, 2),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.moveBy(const Offset(30, 0));
          await gesture.moveBy(const Offset(-21, 0));
          await gesture.moveBy(const Offset(-2, 0));
          await gesture.up();
          await tester.pump();
          final actual = textFieldOffset(tester);
          const expected = Offset(12, 4);
          expect(actual, equals(expected));
        });
        testWidgets('typing letters', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          await tester.tapAt(tester.getTopLeft(find.byType(PixelCanvas)));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
          await tester.pump();
          final actual = textToolSelected(tester);
          const expected = true;
          expect(actual, equals(expected));
        });
        testWidgets('commit', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 5, height: 5);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(9, 9));
          await tester.pump();
          await tester.enterText(
            find.descendant(
              of: find.byType(TextDraft),
              matching: find.byType(TextField),
            ),
            'a',
          );
          await tester.tapAt(topLeft + const Offset(1, 1));
          await settleTextCommit(tester);
          final actual = [
            pixelRows(document.activeLayer),
            find.byType(TextDraft).evaluate().length,
          ];
          const expected = [
            [
              [transparent, transparent, transparent, transparent, transparent],
              [transparent, transparent, transparent, transparent, transparent],
              [transparent, transparent, transparent, transparent, transparent],
              [transparent, transparent, black, black, black],
              [transparent, transparent, black, black, black],
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('shortcuts after commit', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Text (T)'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(13, 13));
          await tester.pump();
          await tester.tapAt(topLeft);
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.keyP);
          final actual = selectedTools(tester);
          const expected = [true, false, false, false];
          expect(actual, equals(expected));
        });
      });

      group('held shape centering', () {
        testWidgets('ctrl down', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(5, 5),
          );
          await gesture.moveTo(topLeft + const Offset(9, 9));
          await gesture.up();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black],
            [black, transparent, black],
            [black, black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('ctrl up', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(5, 5),
          );
          await gesture.moveTo(topLeft + const Offset(9, 9));
          await gesture.up();
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent, transparent],
            [transparent, black, black],
            [transparent, black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('right ctrl', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 3, height: 3);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Rectangle (R)'));
          await tester.pump();
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlRight);
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(5, 5),
          );
          await gesture.moveTo(topLeft + const Offset(9, 9));
          await gesture.up();
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlRight);
          await tester.pump();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black],
            [black, transparent, black],
            [black, black, black],
          ];
          expect(actual, equals(expected));
        });
        testWidgets(
          'cmd on macos',
          (tester) async {
            useDesktopView(tester);
            final document = Document.blank(width: 3, height: 3);
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: EditorView(
                    files: StubFileAccess(),
                    library: stubDocumentLibrary(),
                    clipboard: StubImageClipboard(),
                    document: document,
                  ),
                ),
              ),
            );
            await tester.tap(find.byTooltip('Rectangle (R)'));
            await tester.pump();
            await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
            final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
            final gesture = await tester.startGesture(
              topLeft + const Offset(5, 5),
            );
            await gesture.moveTo(topLeft + const Offset(9, 9));
            await gesture.up();
            await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
            await tester.pump();
            final actual = pixelRows(document.activeLayer);
            const expected = [
              [black, black, black],
              [black, transparent, black],
              [black, black, black],
            ];
            expect(actual, equals(expected));
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
        testWidgets(
          'ctrl on macos',
          (tester) async {
            useDesktopView(tester);
            final document = Document.blank(width: 3, height: 3);
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: EditorView(
                    files: StubFileAccess(),
                    library: stubDocumentLibrary(),
                    clipboard: StubImageClipboard(),
                    document: document,
                  ),
                ),
              ),
            );
            await tester.tap(find.byTooltip('Rectangle (R)'));
            await tester.pump();
            await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
            final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
            final gesture = await tester.startGesture(
              topLeft + const Offset(5, 5),
            );
            await gesture.moveTo(topLeft + const Offset(9, 9));
            await gesture.up();
            await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
            await tester.pump();
            final actual = pixelRows(document.activeLayer);
            const expected = [
              [transparent, transparent, transparent],
              [transparent, black, black],
              [transparent, black, black],
            ];
            expect(actual, equals(expected));
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
      });

      group('held color picker', () {
        testWidgets('alt down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await tester.pump();
          final held = allSelectedTools(tester);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          final actual = held;
          const expected = [
            false,
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt up', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          await tester.pump();
          final actual = allSelectedTools(tester);
          const expected = [
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alt repeat', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await tester.sendKeyRepeatEvent(LogicalKeyboardKey.altLeft);
          await tester.pump();
          final held = allSelectedTools(tester);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          final actual = held;
          const expected = [
            false,
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('right alt', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altRight);
          await tester.pump();
          final held = allSelectedTools(tester);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altRight);
          final actual = held;
          const expected = [
            false,
            false,
            false,
            true,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
      });

      group('shortcuts while editing text', () {
        testWidgets('tool key in text field', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
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
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
      });

      group('unsaved changes', () {
        testWidgets('no change', (tester) async {
          useDesktopView(tester);
          final reported = <bool>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                  onUnsavedChanged: reported.add,
                ),
              ),
            ),
          );
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = reported;
          const expected = <bool>[];
          expect(actual, equals(expected));
        });
        testWidgets('after stroke', (tester) async {
          useDesktopView(tester);
          final reported = <bool>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                  onUnsavedChanged: reported.add,
                ),
              ),
            ),
          );
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          final actual = reported;
          const expected = [true];
          expect(actual, equals(expected));
        });
        testWidgets('second stroke', (tester) async {
          useDesktopView(tester);
          final reported = <bool>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                  onUnsavedChanged: reported.add,
                ),
              ),
            ),
          );
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          final actual = reported;
          const expected = [true];
          expect(actual, equals(expected));
        });
        testWidgets('after undo', (tester) async {
          useDesktopView(tester);
          final reported = <bool>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                  onUnsavedChanged: reported.add,
                ),
              ),
            ),
          );
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyZ);
          final actual = reported;
          const expected = [true, false];
          expect(actual, equals(expected));
        });
        testWidgets('after save', (tester) async {
          useDesktopView(tester);
          final reported = <bool>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                  onUnsavedChanged: reported.add,
                ),
              ),
            ),
          );
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyS);
          await tester.pumpAndSettle();
          final actual = reported;
          const expected = [true, false];
          expect(actual, equals(expected));
        });
      });
      group('keyboard focus', () {
        testWidgets('initial focus', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextField(autofocus: true),
                    Expanded(
                      child: EditorView(
                        files: StubFileAccess(),
                        library: stubDocumentLibrary(),
                        clipboard: StubImageClipboard(),
                        document: document,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('field inside unfocused', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
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
          FocusManager.instance.primaryFocus!.unfocus();
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('field outside focused', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextField(key: const Key('outside')),
                    Expanded(
                      child: EditorView(
                        files: StubFileAccess(),
                        library: stubDocumentLibrary(),
                        clipboard: StubImageClipboard(),
                        document: document,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.tap(find.byKey(const Key('outside')));
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('inactive', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                  active: false,
                ),
              ),
            ),
          );
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('activated', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextField(key: const Key('outside')),
                    Expanded(
                      child: EditorView(
                        files: StubFileAccess(),
                        library: stubDocumentLibrary(),
                        clipboard: StubImageClipboard(),
                        document: document,
                        active: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.tap(find.byKey(const Key('outside')));
          await tester.pump();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextField(key: const Key('outside')),
                    Expanded(
                      child: EditorView(
                        files: StubFileAccess(),
                        library: stubDocumentLibrary(),
                        clipboard: StubImageClipboard(),
                        document: document,
                        active: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('reassemble', (tester) async {
          useDesktopView(tester);
          final document = Document.blank(width: 2, height: 2);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextField(key: const Key('outside')),
                    Expanded(
                      child: EditorView(
                        files: StubFileAccess(),
                        library: stubDocumentLibrary(),
                        clipboard: StubImageClipboard(),
                        document: document,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.tap(find.byKey(const Key('outside')));
          await tester.pump();
          final reassembled = tester.binding.reassembleApplication();
          await tester.pump();
          await reassembled;
          await tester.pump();
          await pressShortcut(tester, key: LogicalKeyboardKey.keyE);
          final actual = allSelectedTools(tester);
          const expected = [
            false,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
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
        testWidgets('copy layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Copy layer (Shift+D)'));
          await tester.pump();
          final actual = [layerState(tester), historyState(tester)];
          const expected = [
            [
              ['Background', 'Background copy'],
              [true, true],
              [100, 100],
              1,
            ],
            [
              ['Start', 'Copy layer'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('add layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
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
            [true, false, true],
            [
              ['Start', 'Add layer'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('merge layer down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Merge layer down (Ctrl+E)'));
          await tester.pumpAndSettle();
          final actual = [
            layerState(tester),
            layerOptionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            <bool>[],
            [
              ['Start', 'Add layer', 'Merge layer down'],
              2,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('rename layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Rename layer (F2)'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Ink');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = [layerState(tester).first, historyState(tester)];
          const expected = [
            ['Ink'],
            [
              ['Start', 'Rename layer'],
              1,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('rename layer cancelled', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Rename layer (F2)'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Ink');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = [layerState(tester).first, historyState(tester)];
          const expected = [
            ['Background'],
            [
              ['Start'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('save renamed layer', (tester) async {
          useDesktopView(tester);
          final stubStore = StubDocumentStore();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Rename layer (F2)'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Name')), 'Ink');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Save (Ctrl+S)'));
          await tester.pump();
          final saved = OraCodec.decode(
            name: 'Untitled',
            bytes: stubStore.files.values.single,
          );
          final actual = [
            find.text('Saved').evaluate().length,
            layerStructure(saved),
          ];
          const expected = [
            1,
            [
              ['Ink'],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('remove layer', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          await tester.tap(find.byTooltip('More layer options'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Remove layer (Shift+Del)'));
          await tester.pumpAndSettle();
          final actual = [
            layerState(tester),
            layerActionsEnabled(tester),
            layerOptionsEnabled(tester),
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            [true, false, false],
            <bool>[],
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Move layer down (Alt+PgDn)'));
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
            [true, true, false],
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Move layer down (Alt+PgDn)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Move layer up (Alt+PgUp)'));
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
            [true, false, true],
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
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
            [true, true, false],
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          await tester.tap(find.byTooltip('Undo (Ctrl+Z)'));
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
            [true, false, false],
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
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
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: document,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Add layer (Shift+N)'));
          await tester.pump();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          await tester.pump();
          final actual = [
            for (final layer in document.layers) pixelRows(layer.images.first),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Hide layer'));
          await tester.pump();
          final actual = [
            layerState(tester),
            canvasLayers(tester).length,
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [false],
              [100],
              0,
            ],
            0,
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Hide layer'));
          await tester.pump();
          await tester.tap(find.byTooltip('Show layer'));
          await tester.pump();
          final actual = [
            layerState(tester),
            canvasLayers(tester).length,
            historyState(tester),
          ];
          const expected = [
            [
              ['Background'],
              [true],
              [100],
              0,
            ],
            1,
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
          await tester.tap(find.byTooltip('Undo (Ctrl+Z)'));
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
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 1),
                ),
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

      group('scroll zoom', () {
        testWidgets('ctrl scroll up', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(tester, at: center, delta: const Offset(0, -50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('ctrl scroll down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(tester, at: center, delta: const Offset(0, 50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(6, 6);
          expect(actual, equals(expected));
        });
        testWidgets('right ctrl', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlRight);
          await scrollWheel(tester, at: center, delta: const Offset(0, -50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlRight);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('canvas margin', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(
            tester,
            at: center + const Offset(200, 100),
            delta: const Offset(0, -50),
          );
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('without ctrl', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await scrollWheel(tester, at: center, delta: const Offset(0, -50));
          final actual = canvasSize(tester);
          const expected = Size(8, 8);
          expect(actual, equals(expected));
        });
        testWidgets('horizontal scroll', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(tester, at: center, delta: const Offset(-50, 0));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(8, 8);
          expect(actual, equals(expected));
        });
        testWidgets(
          'cmd on macos',
          (tester) async {
            useDesktopView(tester);
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: EditorView(
                    files: StubFileAccess(),
                    library: stubDocumentLibrary(),
                    clipboard: StubImageClipboard(),
                    document: Document.blank(width: 2, height: 2),
                  ),
                ),
              ),
            );
            final center = tester.getCenter(find.byType(PixelCanvas));
            await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
            await scrollWheel(tester, at: center, delta: const Offset(0, -50));
            await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
            await tester.pump();
            final actual = canvasSize(tester);
            const expected = Size(12, 12);
            expect(actual, equals(expected));
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
        testWidgets(
          'ctrl on macos',
          (tester) async {
            useDesktopView(tester);
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: EditorView(
                    files: StubFileAccess(),
                    library: stubDocumentLibrary(),
                    clipboard: StubImageClipboard(),
                    document: Document.blank(width: 2, height: 2),
                  ),
                ),
              ),
            );
            final center = tester.getCenter(find.byType(PixelCanvas));
            await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
            await scrollWheel(tester, at: center, delta: const Offset(0, -50));
            await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
            await tester.pump();
            final actual = canvasSize(tester);
            const expected = Size(8, 8);
            expect(actual, equals(expected));
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
        testWidgets('keeps cursor pixel', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 400, height: 400),
                ),
              ),
            ),
          );
          final cursor =
              tester.getTopLeft(find.byType(PixelCanvas)) +
              const Offset(300, 200);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(tester, at: cursor, delta: const Offset(0, -50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = [
            canvasPixelAt(tester, point: cursor),
            canvasSize(tester),
          ];
          const expected = [Offset(75, 50), Size(2400, 2400)];
          expect(actual, equals(expected));
        });
        testWidgets('fitting canvas keeps cursor pixel', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 20, height: 20),
                ),
              ),
            ),
          );
          final cursor =
              tester.getTopLeft(find.byType(PixelCanvas)) +
              const Offset(70, 70);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(tester, at: cursor, delta: const Offset(0, -50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = [
            canvasPixelAt(tester, point: cursor),
            canvasSize(tester),
          ];
          const expected = [Offset(17.5, 17.5), Size(120, 120)];
          expect(actual, equals(expected));
        });
      });
      group('scale zoom', () {
        testWidgets('scale up', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scaleWheel(tester, at: center, scale: 2);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('scale down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scaleWheel(tester, at: center, scale: 0.5);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(6, 6);
          expect(actual, equals(expected));
        });
        testWidgets('small scales accumulate', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await scaleWheel(tester, at: center, scale: 1.01);
          await scaleWheel(tester, at: center, scale: 1.01);
          await scaleWheel(tester, at: center, scale: 1.01);
          await scaleWheel(tester, at: center, scale: 1.01);
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('single small scale', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await scaleWheel(tester, at: center, scale: 1.01);
          final actual = canvasSize(tester);
          const expected = Size(8, 8);
          expect(actual, equals(expected));
        });
        testWidgets('scale without modifier', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await scaleWheel(tester, at: center, scale: 2);
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('scale at maximum', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.enterText(
            find.descendant(
              of: find.ancestor(
                of: find.text('Zoom:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(TextField),
            ),
            '96',
          );
          await tester.pump();
          await scaleWheel(
            tester,
            at: tester.getCenter(canvasArea()),
            scale: 2,
          );
          final actual = canvasSize(tester);
          const expected = Size(192, 192);
          expect(actual, equals(expected));
        });
        testWidgets('scale keeps cursor pixel', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 400, height: 400),
                ),
              ),
            ),
          );
          final cursor =
              tester.getTopLeft(find.byType(PixelCanvas)) +
              const Offset(300, 200);
          await scaleWheel(tester, at: cursor, scale: 2);
          final actual = [
            canvasPixelAt(tester, point: cursor),
            canvasSize(tester),
          ];
          const expected = [Offset(75, 50), Size(2400, 2400)];
          expect(actual, equals(expected));
        });
      });
      group('scroll scrub', () {
        testWidgets('alt scroll down', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await scrollWheel(tester, at: center, delta: const Offset(0, 50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          await tester.pump();
          final actual = timelineState(tester).first;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('alt scroll up', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await scrollWheel(tester, at: center, delta: const Offset(0, -50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          await tester.pump();
          final actual = timelineState(tester).first;
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('loops forward', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 2,
                  ),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await scrollWheel(tester, at: center, delta: const Offset(0, 50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          await tester.pump();
          final actual = timelineState(tester).first;
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('loops backward', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 0,
                  ),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
          await scrollWheel(tester, at: center, delta: const Offset(0, -50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
          await tester.pump();
          final actual = timelineState(tester).first;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('right alt', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.altRight);
          await scrollWheel(tester, at: center, delta: const Offset(0, 50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altRight);
          await tester.pump();
          final actual = timelineState(tester).first;
          const expected = 2;
          expect(actual, equals(expected));
        });
        testWidgets('without alt', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await scrollWheel(tester, at: center, delta: const Offset(0, 50));
          final actual = timelineState(tester).first;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('ctrl scroll', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: animatedDocument(
                    spriteColors: [black, white, black],
                    activeFrameIndex: 1,
                  ),
                ),
              ),
            ),
          );
          final center = tester.getCenter(find.byType(PixelCanvas));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await scrollWheel(tester, at: center, delta: const Offset(0, 50));
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final actual = timelineState(tester).first;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
      group('zoom', () {
        testWidgets('increase', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Increase'));
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(12, 12);
          expect(actual, equals(expected));
        });
        testWidgets('decrease', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Decrease'));
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(6, 6);
          expect(actual, equals(expected));
        });
        testWidgets('slider', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 2, height: 2),
                ),
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
        testWidgets('decrease below one', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          for (var tap = 0; tap < 4; tap++) {
            await tester.tap(find.byTooltip('Decrease'));
            await tester.pump();
          }
          final actual = [
            canvasSize(tester),
            tester
                .widget<TextField>(
                  find.descendant(
                    of: find.ancestor(
                      of: find.text('Zoom:'),
                      matching: find.byType(NumericValueRange),
                    ),
                    matching: find.byType(TextField),
                  ),
                )
                .controller!
                .text,
          ];
          const expected = [Size(2, 2), '1/2'];
          expect(actual, equals(expected));
        });
        testWidgets('typed negative', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.enterText(
            find.descendant(
              of: find.ancestor(
                of: find.text('Zoom:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(TextField),
            ),
            '-4',
          );
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(1, 1);
          expect(actual, equals(expected));
        });
        testWidgets('typed fraction', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
              ),
            ),
          );
          await tester.enterText(
            find.descendant(
              of: find.ancestor(
                of: find.text('Zoom:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(TextField),
            ),
            '1/4',
          );
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(1, 1);
          expect(actual, equals(expected));
        });
        testWidgets('slider twice per frame', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 400, height: 400),
                ),
              ),
            ),
          );
          final center = canvasAreaCenter(tester);
          final before = canvasPixelAt(tester, point: center);
          final slider = tester.widget<Slider>(
            find.descendant(
              of: find.ancestor(
                of: find.text('Zoom:'),
                matching: find.byType(NumericValueRange),
              ),
              matching: find.byType(Slider),
            ),
          );
          slider.onChanged!(2.5);
          slider.onChanged!(2.9);
          await tester.pump();
          final actual = [
            canvasPixelAt(tester, point: center),
            canvasSize(tester),
          ];
          final expected = [before, const Size(2800, 2800)];
          expect(actual, equals(expected));
        });
        testWidgets('typing through minus one', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 20, height: 20),
                ),
              ),
            ),
          );
          final field = find.descendant(
            of: find.ancestor(
              of: find.text('Zoom:'),
              matching: find.byType(NumericValueRange),
            ),
            matching: find.byType(TextField),
          );
          await tester.enterText(field, '-1');
          await tester.pump();
          final typed = [
            tester.widget<TextField>(field).controller!.text,
            canvasSize(tester),
          ];
          await tester.enterText(field, '-10');
          await tester.pump();
          final actual = [...typed, canvasSize(tester)];
          const expected = ['-1', Size(20, 20), Size(2, 2)];
          expect(actual, equals(expected));
        });
        testWidgets('slider below one', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: EditorView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  document: Document.blank(width: 4, height: 4),
                ),
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
              .onChanged!(-1);
          await tester.pump();
          final actual = canvasSize(tester);
          const expected = Size(2, 2);
          expect(actual, equals(expected));
        });
      });
    });
  });
}
