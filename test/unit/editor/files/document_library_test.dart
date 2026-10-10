import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/files/document_format_exception.dart';
import 'package:paint/editor/files/document_library.dart';
import 'package:paint/editor/files/ora_codec.dart';
import 'package:paint/editor/files/stored_document.dart';

import '../../../support/stub_document_store.dart';
import '../../../support/stored_documents.dart';

void main() {
  final start = DateTime(2026, 10, 10, 12);

  DocumentLibrary documentLibrary({required StubDocumentStore stubStore}) =>
      DocumentLibrary(
        store: stubStore,
        now: StubClock(start: start).call,
      );

  group('class DocumentLibrary', () {
    group('method refresh', () {
      group('order', () {
        test('newest first', () async {
          final stubStore = StubDocumentStore()
            ..entries['1'] = storedDocument(id: '1', minute: 1)
            ..entries['2'] = storedDocument(id: '2', minute: 3)
            ..entries['3'] = storedDocument(id: '3', minute: 2);
          final library = documentLibrary(stubStore: stubStore);
          await library.refresh();
          final actual = [for (final entry in library.documents) entry.id];
          const expected = ['2', '3', '1'];
          expect(actual, equals(expected));
        });
      });

      group('listeners', () {
        test('notified', () async {
          final library = documentLibrary(stubStore: StubDocumentStore());
          var notifications = 0;
          library.addListener(() => notifications++);
          await library.refresh();
          final actual = notifications;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
    });

    group('method save', () {
      group('documents', () {
        test('new', () async {
          final stubStore = StubDocumentStore();
          final library = documentLibrary(stubStore: stubStore);
          final document = Document.blank(
            name: 'Cat',
            width: 2,
            height: 1,
            background: PixelColor.white,
          );
          await library.save(document: document);
          final id = '${start.microsecondsSinceEpoch}';
          final actual = [
            document.storeId,
            library.documents,
            OraCodec.decode(name: 'Cat', bytes: stubStore.files[id]!),
          ];
          final expected = [
            id,
            [
              StoredDocument(
                id: id,
                name: 'Cat',
                modified: start,
                thumbnail: Layer.filled(
                  width: 2,
                  height: 1,
                  color: PixelColor.white,
                ),
              ),
            ],
            Document.blank(
              name: 'Cat',
              width: 2,
              height: 1,
              background: PixelColor.white,
            ),
          ];
          expect(actual, equals(expected));
        });
        test('previously saved', () async {
          final stubStore = StubDocumentStore();
          final library = documentLibrary(stubStore: stubStore);
          final document = Document.blank(name: 'Cat', width: 2, height: 1)
            ..storeId = '7';
          await library.save(document: document);
          final actual = [
            document.storeId,
            [for (final entry in library.documents) entry.id],
          ];
          final expected = [
            '7',
            ['7'],
          ];
          expect(actual, equals(expected));
        });
      });

      group('thumbnail', () {
        test('large document', () async {
          final library = documentLibrary(stubStore: StubDocumentStore());
          await library.save(
            document: Document.blank(
              width: 96,
              height: 48,
              background: PixelColor.white,
            ),
          );
          final actual = library.documents.single.thumbnail;
          final expected = Layer.filled(
            width: 48,
            height: 24,
            color: PixelColor.white,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('method open', () {
      group('entries', () {
        test('stored', () async {
          final stubStore = StubDocumentStore()
            ..files['1'] = OraCodec.encode(
              document: Document.blank(width: 2, height: 1),
            );
          final library = documentLibrary(stubStore: stubStore);
          final actual = await library.open(
            entry: storedDocument(id: '1', name: 'Dog'),
          );
          final expected = Document.blank(name: 'Dog', width: 2, height: 1)
            ..storeId = '1';
          expect(actual, equals(expected));
        });
      });

      group('errors', () {
        test('missing', () async {
          final library = documentLibrary(stubStore: StubDocumentStore());
          Future<void> event() => library.open(entry: storedDocument(id: '1'));
          await expectLater(
            event,
            throwsA(equals(DocumentFormatException.missing())),
          );
        });
      });
    });

    group('method delete', () {
      group('entries', () {
        test('stored', () async {
          final stubStore = StubDocumentStore()
            ..entries['1'] = storedDocument(id: '1')
            ..entries['2'] = storedDocument(id: '2')
            ..files['1'] = Uint8List.fromList([1]);
          final library = documentLibrary(stubStore: stubStore);
          await library.delete(entry: storedDocument(id: '1'));
          final actual = [
            [for (final entry in library.documents) entry.id],
            stubStore.files,
          ];
          final expected = [
            ['2'],
            {},
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
