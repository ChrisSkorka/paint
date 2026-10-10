import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/files/image_codec.dart';
import 'package:paint/editor/files/ora_codec.dart';
import 'package:paint/widgets/components/paint_wide_button.dart';
import 'package:paint/widgets/views/new_document_view.dart';

import '../../../support/stored_documents.dart';
import '../../../support/stub_document_store.dart';
import '../../../support/stub_file_access.dart';
import '../../../support/stub_image_clipboard.dart';

void main() {
  group('class NewDocumentView', () {
    group('render', () {
      group('defaults', () {
        testWidgets('initial fields', (tester) async {
          void stubOnCreate(Document document) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          final actual = [
            find.text('Open').evaluate().length,
            tester
                .widgetList<TextField>(find.byType(TextField))
                .map((textField) => textField.controller!.text)
                .toList(),
          ];
          const expected = [
            1,
            ['Untitled', '64', '64'],
          ];
          expect(actual, equals(expected));
        });
      });

      group('saved documents', () {
        testWidgets('none', (tester) async {
          void stubOnCreate(Document document) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.pump();
          final actual = find.text('No saved documents').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('stored', (tester) async {
          void stubOnCreate(Document document) {}
          final stubStore = StubDocumentStore()
            ..entries['1'] = storedDocument(id: '1', name: 'Cat');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.pump();
          final actual = [
            find.text('Cat').evaluate().length,
            find.text('No saved documents').evaluate().length,
          ];
          const expected = [1, 0];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('create', () {
        testWidgets('default size', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('Create new'));
          final actual = created;
          final expected = [Document.blank(width: 64, height: 64)];
          expect(actual, equals(expected));
        });
        testWidgets('custom size', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.enterText(find.byKey(const Key('height')), '2');
          await tester.pump();
          await tester.tap(find.text('Create new'));
          final actual = created;
          final expected = [Document.blank(width: 3, height: 2)];
          expect(actual, equals(expected));
        });
        testWidgets('submit with enter', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          final actual = created;
          final expected = [Document.blank(width: 3, height: 64)];
          expect(actual, equals(expected));
        });
      });
      group('invalid width', () {
        testWidgets('zero', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '0');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [
            created,
            find.text('1 to 4096').evaluate().length,
            tester
                    .widget<PaintWideButton>(
                      find.ancestor(
                        of: find.text('Create new'),
                        matching: find.byType(PaintWideButton),
                      ),
                    )
                    .onPressed ==
                null,
          ];
          final expected = [<Document>[], 1, true];
          expect(actual, equals(expected));
        });
        testWidgets('too large', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '4097');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [created, find.text('1 to 4096').evaluate().length];
          final expected = [<Document>[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('empty', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [created, find.text('1 to 4096').evaluate().length];
          final expected = [<Document>[], 1];
          expect(actual, equals(expected));
        });
      });
      group('invalid height', () {
        testWidgets('zero', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('height')), '0');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [created, find.text('1 to 4096').evaluate().length];
          final expected = [<Document>[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('too large', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('height')), '4097');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [created, find.text('1 to 4096').evaluate().length];
          final expected = [<Document>[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('empty', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('height')), '');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [created, find.text('1 to 4096').evaluate().length];
          final expected = [<Document>[], 1];
          expect(actual, equals(expected));
        });
      });
      group('create from clipboard', () {
        testWidgets('image', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final image = Layer.filled(
            width: 3,
            height: 2,
            color: PixelColor.white,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(image: image),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pump();
          final actual = created;
          final expected = [Document.fromImage(image: image)];
          expect(actual, equals(expected));
        });
        testWidgets('no image', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pump();
          final actual = [
            created,
            find.text('Clipboard has no image').evaluate().length,
          ];
          const expected = [[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('too wide', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(
                    image: Layer.filled(
                      width: Document.maximumSize + 1,
                      height: 1,
                      color: PixelColor.white,
                    ),
                  ),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pump();
          final actual = [
            created,
            find.text('Image is larger than 4096 × 4096').evaluate().length,
          ];
          const expected = [[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('too tall', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(
                    image: Layer.filled(
                      width: 1,
                      height: Document.maximumSize + 1,
                      color: PixelColor.white,
                    ),
                  ),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pump();
          final actual = [
            created,
            find.text('Image is larger than 4096 × 4096').evaluate().length,
          ];
          const expected = [[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('error cleared', (tester) async {
          void stubOnCreate(Document document) {}
          final stubClipboard = StubImageClipboard();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pump();
          stubClipboard.image = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pump();
          final actual = find.text('Clipboard has no image').evaluate().length;
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('after close', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final stubClipboard = StubImageClipboard(holdReads: true);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pumpWidget(const SizedBox());
          stubClipboard.pendingReads.single.complete(
            Layer.filled(width: 1, height: 1, color: PixelColor.white),
          );
          await tester.pump();
          final actual = [created, tester.takeException()];
          const expected = [[], null];
          expect(actual, equals(expected));
        });
        testWidgets('error after close', (tester) async {
          void stubOnCreate(Document document) {}
          final stubClipboard = StubImageClipboard(holdReads: true);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: stubClipboard,
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From clipboard'));
          await tester.pumpWidget(const SizedBox());
          stubClipboard.pendingReads.single.complete(null);
          await tester.pump();
          final actual = tester.takeException();
          const expected = null;
          expect(actual, equals(expected));
        });
      });

      group('name', () {
        testWidgets('custom', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), ' Cat ');
          await tester.tap(find.text('Create new'));
          final actual = created;
          final expected = [Document.blank(name: 'Cat', width: 64, height: 64)];
          expect(actual, equals(expected));
        });
        testWidgets('submit with enter', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          final actual = created;
          final expected = [Document.blank(name: 'Cat', width: 64, height: 64)];
          expect(actual, equals(expected));
        });
        testWidgets('blank', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), '  ');
          await tester.tap(find.text('Create new'));
          final actual = created;
          final expected = [Document.blank(width: 64, height: 64)];
          expect(actual, equals(expected));
        });
        testWidgets('from clipboard', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final image = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(image: image),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.tap(find.text('From clipboard'));
          await tester.pump();
          final actual = created;
          final expected = [Document.fromImage(name: 'Cat', image: image)];
          expect(actual, equals(expected));
        });
      });

      group('open file', () {
        testWidgets('png', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final image = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          final stubFiles = StubFileAccess(
            file: (name: 'cat.png', bytes: ImageCodec.encodePng(layer: image)),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From file'));
          await tester.pump();
          final actual = created;
          final expected = [Document.fromImage(name: 'cat', image: image)];
          expect(actual, equals(expected));
        });
        testWidgets('ora', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final stubFiles = StubFileAccess(
            file: (
              name: 'cat.ora',
              bytes: OraCodec.encode(
                document: Document.blank(width: 2, height: 1),
              ),
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From file'));
          await tester.pump();
          final actual = created;
          final expected = [Document.blank(name: 'cat', width: 2, height: 1)];
          expect(actual, equals(expected));
        });
        testWidgets('cancelled', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From file'));
          await tester.pump();
          final actual = created;
          const expected = [];
          expect(actual, equals(expected));
        });
        testWidgets('unsupported', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final stubFiles = StubFileAccess(
            file: (name: 'cat.png', bytes: Uint8List.fromList([1, 2, 3])),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: stubFiles,
                  library: stubDocumentLibrary(),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.text('From file'));
          await tester.pump();
          final actual = [
            created,
            find.text('File is not a supported image').evaluate().length,
          ];
          const expected = [[], 1];
          expect(actual, equals(expected));
        });
      });

      group('saved documents', () {
        testWidgets('open', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final stubStore = StubDocumentStore()
            ..entries['1'] = storedDocument(id: '1', name: 'Cat')
            ..files['1'] = OraCodec.encode(
              document: Document.blank(width: 2, height: 1),
            );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.text('Cat'));
          await tester.pump();
          final actual = created;
          final expected = [
            Document.blank(name: 'Cat', width: 2, height: 1)..storeId = '1',
          ];
          expect(actual, equals(expected));
        });
        testWidgets('open missing', (tester) async {
          final created = <Document>[];
          void stubOnCreate(Document document) => created.add(document);
          final stubStore = StubDocumentStore()
            ..entries['1'] = storedDocument(id: '1', name: 'Cat');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.text('Cat'));
          await tester.pump();
          final actual = [
            created,
            find.text('Document no longer exists').evaluate().length,
          ];
          const expected = [[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('delete confirmed', (tester) async {
          void stubOnCreate(Document document) {}
          final stubStore = StubDocumentStore()
            ..entries['1'] = storedDocument(id: '1', name: 'Cat');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.byTooltip('Delete Cat'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();
          final actual = [
            stubStore.entries,
            find.text('No saved documents').evaluate().length,
          ];
          const expected = [{}, 1];
          expect(actual, equals(expected));
        });
        testWidgets('delete cancelled', (tester) async {
          void stubOnCreate(Document document) {}
          final stubStore = StubDocumentStore()
            ..entries['1'] = storedDocument(id: '1', name: 'Cat');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NewDocumentView(
                  files: StubFileAccess(),
                  library: stubDocumentLibrary(store: stubStore),
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.tap(find.byTooltip('Delete Cat'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          final actual = [
            stubStore.entries.keys.toList(),
            find.text('Cat').evaluate().length,
          ];
          const expected = [
            ['1'],
            1,
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
