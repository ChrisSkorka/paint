import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/files/ora_codec.dart';
import 'package:paint/widgets/components/document_tab_bar.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';
import 'package:paint/widgets/views/editor_view.dart';
import 'package:paint/widgets/views/home_view.dart';
import 'package:paint/widgets/views/new_document_view.dart';

import '../../../support/desktop_view.dart';
import '../../../support/document_tab_probes.dart';
import '../../../support/editor_view_probes.dart';
import '../../../support/keyboard.dart';
import '../../../support/view_probes.dart';
import '../../../support/stub_document_store.dart';
import '../../../support/stub_file_access.dart';
import '../../../support/stub_image_clipboard.dart';

void main() {
  group('class HomeView', () {
    group('render', () {
      group('initial tab', () {
        testWidgets('new document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          final actual = [
            documentTabState(tester),
            tabIndex(tester),
            find.byType(NewDocumentView).evaluate().length,
          ];
          const expected = [
            [
              [(title: 'New document', unsaved: false)],
              0,
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('documents', () {
        testWidgets('create', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final actual = [
            documentTabState(tester),
            tester.widget<EditorView>(find.byType(EditorView)).document,
          ];
          final expected = [
            [
              [(title: 'Cat', unsaved: false)],
              0,
            ],
            Document.blank(name: 'Cat', width: 64, height: 64),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('create from clipboard', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard(
            image: Layer.filled(width: 3, height: 2, color: PixelColor.white),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: stubClipboard,
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pumpAndSettle();
          final editorView = tester.widget<EditorView>(find.byType(EditorView));
          final actual = [
            documentTabState(tester),
            editorView.document,
            identical(editorView.clipboard, stubClipboard),
          ];
          final expected = [
            [
              [(title: 'Untitled', unsaved: false)],
              0,
            ],
            Document.fromImage(image: stubClipboard.image!),
            true,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('open file', (tester) async {
          useDesktopView(tester);
          final stubFiles = StubFileAccess(
            file: (
              name: 'cat.ora',
              bytes: OraCodec.encode(
                document: Document.blank(width: 3, height: 2),
              ),
            ),
          );
          final library = stubDocumentLibrary();
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: stubFiles,
                library: library,
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('From file'));
          await tester.pumpAndSettle();
          final editorView = tester.widget<EditorView>(find.byType(EditorView));
          final actual = [
            documentTabState(tester),
            editorView.document,
            identical(editorView.files, stubFiles),
            identical(editorView.library, library),
          ];
          final expected = [
            [
              [(title: 'cat', unsaved: false)],
              0,
            ],
            Document.blank(name: 'cat', width: 3, height: 2),
            true,
            true,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('create in second tab', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('name')), 'Dog');
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final actual = [
            documentTabState(tester),
            [
              for (final editorView in tester.widgetList<EditorView>(
                find.byType(EditorView, skipOffstage: false),
              ))
                [editorView.document, editorView.active],
            ],
          ];
          final expected = [
            [
              [(title: 'Cat', unsaved: false), (title: 'Dog', unsaved: false)],
              1,
            ],
            [
              [Document.blank(name: 'Cat', width: 64, height: 64), false],
              [Document.blank(name: 'Dog', width: 3, height: 64), true],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
      group('add tab', () {
        testWidgets('one added', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          final actual = [
            documentTabState(tester),
            tabIndex(tester),
            find.byType(NewDocumentView).evaluate().length,
          ];
          const expected = [
            [
              [
                (title: 'Untitled', unsaved: false),
                (title: 'New document', unsaved: false),
              ],
              1,
            ],
            1,
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('existing editor kept', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '2');
          await tester.enterText(find.byKey(const Key('height')), '2');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await selectDocumentTab(tester, title: 'Untitled');
          final actual = [
            documentTabState(tester),
            canvasLayers(
              tester,
            ).first.image.getPixel(const PixelPoint(x: 0, y: 0)),
          ];
          const expected = [
            [
              [
                (title: 'Untitled', unsaved: true),
                (title: 'New document', unsaved: false),
              ],
              0,
            ],
            PixelColor.black,
          ];
          expect(actual, equals(expected));
        });
      });
      group('new tab shortcut', () {
        testWidgets('new document page', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyN);
          await tester.pumpAndSettle();
          final actual = documentTabState(tester);
          const expected = [
            [
              (title: 'New document', unsaved: false),
              (title: 'New document', unsaved: false),
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('text field', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.byKey(const Key('name')));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyN);
          await tester.pumpAndSettle();
          final actual = documentTabState(tester);
          const expected = [
            [
              (title: 'New document', unsaved: false),
              (title: 'New document', unsaved: false),
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('editor', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyN);
          await tester.pumpAndSettle();
          final actual = documentTabState(tester);
          const expected = [
            [
              (title: 'Untitled', unsaved: false),
              (title: 'New document', unsaved: false),
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('dialog open', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await closeDocumentTab(tester, index: 0);
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyN);
          await tester.pumpAndSettle();
          final actual = documentTabState(tester);
          const expected = [
            [(title: 'Untitled', unsaved: true)],
            0,
          ];
          expect(actual, equals(expected));
        });
      });
      group('select tab', () {
        testWidgets('previous tab', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('New document').first);
          await tester.pumpAndSettle();
          final actual = [documentTabState(tester), tabIndex(tester)];
          const expected = [
            [
              [
                (title: 'New document', unsaved: false),
                (title: 'New document', unsaved: false),
              ],
              0,
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('shortcut after returning', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('name')));
          await tester.pump();
          await selectDocumentTab(tester, title: 'Untitled');
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
      group('unsaved changes', () {
        testWidgets('after stroke', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          final actual = documentTabState(tester);
          const expected = [
            [(title: 'Untitled', unsaved: true)],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('after undo', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyZ);
          final actual = documentTabState(tester);
          const expected = [
            [(title: 'Untitled', unsaved: false)],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('after save', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyS);
          await tester.pumpAndSettle();
          final actual = documentTabState(tester);
          const expected = [
            [(title: 'Untitled', unsaved: false)],
            0,
          ];
          expect(actual, equals(expected));
        });
      });
      group('close tab', () {
        testWidgets('only tab', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await closeDocumentTab(tester, index: 0);
          final actual = [
            documentTabState(tester),
            find.byType(EditorView).evaluate().length,
            find.byType(NewDocumentView).evaluate().length,
          ];
          const expected = [
            [
              [(title: 'New document', unsaved: false)],
              0,
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('selected last', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await closeDocumentTab(tester, index: 1);
          final actual = [documentTabState(tester), tabIndex(tester)];
          const expected = [
            [
              [(title: 'Untitled', unsaved: false)],
              0,
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('selected middle', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await selectDocumentTab(tester, title: 'Cat');
          await closeDocumentTab(tester, index: 1);
          final actual = [documentTabState(tester), tabIndex(tester)];
          const expected = [
            [
              [
                (title: 'New document', unsaved: false),
                (title: 'New document', unsaved: false),
              ],
              1,
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('before selected', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await closeDocumentTab(tester, index: 0);
          final actual = [
            documentTabState(tester),
            tabIndex(tester),
            find.byType(EditorView).evaluate().length,
          ];
          const expected = [
            [
              [(title: 'Cat', unsaved: false)],
              0,
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('after selected', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('New tab (Ctrl+N)'));
          await tester.pumpAndSettle();
          await selectDocumentTab(tester, title: 'Cat');
          await closeDocumentTab(tester, index: 1);
          final actual = [
            documentTabState(tester),
            tabIndex(tester),
            find.byType(EditorView).evaluate().length,
          ];
          const expected = [
            [
              [(title: 'Cat', unsaved: false)],
              0,
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('unsaved dialog', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await closeDocumentTab(tester, index: 0);
          final actual = [
            find.text('Close Cat?').evaluate().length,
            find.text('Unsaved changes will be lost.').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('unsaved confirmed', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await closeDocumentTab(tester, index: 0);
          await tester.tap(find.text('Close without saving'));
          await tester.pumpAndSettle();
          final actual = [
            documentTabState(tester),
            find.byType(AlertDialog).evaluate().length,
            find.byType(EditorView).evaluate().length,
          ];
          const expected = [
            [
              [(title: 'New document', unsaved: false)],
              0,
            ],
            0,
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('unsaved cancelled', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await closeDocumentTab(tester, index: 0);
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          final actual = [
            documentTabState(tester),
            find.byType(AlertDialog).evaluate().length,
            find.byType(EditorView).evaluate().length,
          ];
          const expected = [
            [
              [(title: 'Cat', unsaved: true)],
              0,
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('middle click unsaved', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await tester.tap(
            find.descendant(
              of: find.byType(DocumentTabBar),
              matching: find.text('Cat'),
            ),
            buttons: kMiddleMouseButton,
          );
          await tester.pumpAndSettle();
          final dialog = find.text('Close Cat?').evaluate().length;
          await tester.tap(find.text('Close without saving'));
          await tester.pumpAndSettle();
          final actual = [dialog, documentTabState(tester)];
          const expected = [
            1,
            [
              [(title: 'New document', unsaved: false)],
              0,
            ],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('unsaved dismissed', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: HomeView(
                files: StubFileAccess(),
                library: stubDocumentLibrary(),
                clipboard: StubImageClipboard(),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(1, 1),
          );
          await tester.pump();
          await closeDocumentTab(tester, index: 0);
          await tester.tapAt(const Offset(1, 1));
          await tester.pumpAndSettle();
          final actual = [
            documentTabState(tester),
            find.byType(AlertDialog).evaluate().length,
          ];
          const expected = [
            [
              [(title: 'Cat', unsaved: true)],
              0,
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
