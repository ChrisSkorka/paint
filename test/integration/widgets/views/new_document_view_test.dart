import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/views/new_document_view.dart';

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
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          final actual = [
            find.text('Create new').evaluate().length,
            tester
                .widgetList<TextField>(find.byType(TextField))
                .map((textField) => textField.controller!.text)
                .toList(),
          ];
          const expected = [
            1,
            ['64', '64'],
          ];
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
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Create'));
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
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.enterText(find.byKey(const Key('height')), '2');
          await tester.pump();
          await tester.tap(find.byTooltip('Create'));
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
                    .widget<PaintIconButton>(
                      find.ancestor(
                        of: find.byTooltip('Create'),
                        matching: find.byType(PaintIconButton),
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
                  clipboard: StubImageClipboard(image: image),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Create from clipboard'));
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
                  clipboard: StubImageClipboard(),
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Create from clipboard'));
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
          await tester.tap(find.byTooltip('Create from clipboard'));
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
          await tester.tap(find.byTooltip('Create from clipboard'));
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
                  clipboard: stubClipboard,
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Create from clipboard'));
          await tester.pump();
          stubClipboard.image = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          await tester.tap(find.byTooltip('Create from clipboard'));
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
                  clipboard: stubClipboard,
                  onCreate: stubOnCreate,
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Create from clipboard'));
          await tester.pumpWidget(const SizedBox());
          stubClipboard.pendingReads.single.complete(
            Layer.filled(width: 1, height: 1, color: PixelColor.white),
          );
          await tester.pump();
          final actual = [created, tester.takeException()];
          const expected = [[], null];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
