import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/files/ora_codec.dart';
import 'package:paint/widgets/views/editor_view.dart';
import 'package:paint/widgets/views/home_view.dart';

import '../../../support/desktop_view.dart';
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
          final actual = tabIndex(tester);
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tabs', () {
        testWidgets('no document placeholder', (tester) async {
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
          await tester.tap(find.text('Editor'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            find.text('No document open').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('back to new document', (tester) async {
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
          await tester.tap(find.text('New document'));
          await tester.pumpAndSettle();
          final actual = tabIndex(tester);
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
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
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            tester.widget<EditorView>(find.byType(EditorView)).document,
          ];
          final expected = [1, Document.blank(width: 64, height: 64)];
          expect(actual, equals(expected));
        });
        testWidgets('second create', (tester) async {
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
          await tester.tap(find.text('New document'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.pump();
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            tester.widget<EditorView>(find.byType(EditorView)).document,
          ];
          final expected = [1, Document.blank(width: 3, height: 64)];
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
            tabIndex(tester),
            editorView.document,
            identical(editorView.clipboard, stubClipboard),
          ];
          final expected = [
            1,
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
            tabIndex(tester),
            editorView.document,
            identical(editorView.files, stubFiles),
            identical(editorView.library, library),
          ];
          final expected = [
            1,
            Document.blank(name: 'cat', width: 3, height: 2),
            true,
            true,
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
