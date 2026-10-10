import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/files/stored_document.dart';
import 'package:paint/widgets/components/stored_document_list.dart';

import '../../../support/stored_documents.dart';

void main() {
  List<String?> texts(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data)
      .toList();

  group('class StoredDocumentList', () {
    group('render', () {
      group('documents', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: StoredDocumentList(
                documents: const [],
                onOpen: (_) {},
                onDelete: (_) {},
              ),
            ),
          );
          final actual = texts(tester);
          const expected = ['No saved documents'];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: StoredDocumentList(
                documents: [
                  storedDocument(id: '1', name: 'Cat', minute: 5),
                  storedDocument(id: '2', name: 'Dog', minute: 30),
                ],
                onOpen: (_) {},
                onDelete: (_) {},
              ),
            ),
          );
          final actual = texts(tester);
          const expected = [
            'Cat',
            '2026-10-10 12:05',
            'Dog',
            '2026-10-10 12:30',
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tap', () {
        testWidgets('name', (tester) async {
          final opened = <StoredDocument>[];
          await tester.pumpWidget(
            MaterialApp(
              home: StoredDocumentList(
                documents: [
                  storedDocument(id: '1', name: 'Cat'),
                  storedDocument(id: '2', name: 'Dog'),
                ],
                onOpen: opened.add,
                onDelete: (_) {},
              ),
            ),
          );
          await tester.tap(find.text('Dog'));
          final actual = opened;
          final expected = [storedDocument(id: '2', name: 'Dog')];
          expect(actual, equals(expected));
        });
        testWidgets('delete', (tester) async {
          final opened = <StoredDocument>[];
          final deleted = <StoredDocument>[];
          await tester.pumpWidget(
            MaterialApp(
              home: StoredDocumentList(
                documents: [
                  storedDocument(id: '1', name: 'Cat'),
                  storedDocument(id: '2', name: 'Dog'),
                ],
                onOpen: opened.add,
                onDelete: deleted.add,
              ),
            ),
          );
          await tester.tap(find.byTooltip('Delete Cat'));
          final actual = [opened, deleted];
          final expected = [
            [],
            [storedDocument(id: '1', name: 'Cat')],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method formatModified', () {
      group('padding', () {
        test('single digits', () {
          final actual = StoredDocumentList.formatModified(
            DateTime(2026, 1, 2, 3, 4),
          );
          const expected = '2026-01-02 03:04';
          expect(actual, equals(expected));
        });
        test('double digits', () {
          final actual = StoredDocumentList.formatModified(
            DateTime(2026, 11, 12, 13, 14),
          );
          const expected = '2026-11-12 13:14';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
