import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/widgets/components/paint_icon_button.dart';
import 'package:paint/widgets/views/new_document_view.dart';

void main() {
  group('class NewDocumentView', () {
    group('render', () {
      group('defaults', () {
        testWidgets('initial fields', (tester) async {
          void stubOnCreate(Document document) {}
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
              home: Scaffold(body: NewDocumentView(onCreate: stubOnCreate)),
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
    });
  });
}
