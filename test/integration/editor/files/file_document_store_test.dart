import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/files/file_document_store.dart';
import 'package:paint/editor/files/stored_document.dart';

import '../../../support/stored_documents.dart';

void main() {
  FileDocumentStore documentStore() {
    final directory = Directory.systemTemp.createTempSync('paint_test');
    addTearDown(() => directory.deleteSync(recursive: true));
    return FileDocumentStore(
      directory: Directory('${directory.path}/documents'),
    );
  }

  group('class FileDocumentStore', () {
    group('method list', () {
      group('entries', () {
        test('none', () async {
          final actual = await documentStore().list();
          const expected = <StoredDocument>[];
          expect(actual, equals(expected));
        });
        test('single', () async {
          final store = documentStore();
          await store.save(
            entry: storedDocument(id: '1'),
            bytes: Uint8List.fromList([1]),
          );
          final actual = await store.list();
          final expected = [storedDocument(id: '1')];
          expect(actual, equals(expected));
        });
        test('multiple', () async {
          final store = documentStore();
          await store.save(
            entry: storedDocument(id: '1'),
            bytes: Uint8List.fromList([1]),
          );
          await store.save(
            entry: storedDocument(id: '2', name: 'Dog'),
            bytes: Uint8List.fromList([2]),
          );
          final actual = await store.list();
          final expected = [
            storedDocument(id: '1'),
            storedDocument(id: '2', name: 'Dog'),
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method load', () {
      group('ids', () {
        test('existing', () async {
          final store = documentStore();
          await store.save(
            entry: storedDocument(id: '1'),
            bytes: Uint8List.fromList([1, 2]),
          );
          final actual = await store.load(id: '1');
          final expected = [1, 2];
          expect(actual, equals(expected));
        });
        test('missing', () async {
          final actual = await documentStore().load(id: '1');
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });

    group('method save', () {
      group('ids', () {
        test('existing', () async {
          final store = documentStore();
          await store.save(
            entry: storedDocument(id: '1'),
            bytes: Uint8List.fromList([1]),
          );
          await store.save(
            entry: storedDocument(id: '1', minute: 1),
            bytes: Uint8List.fromList([2]),
          );
          final actual = [await store.list(), await store.load(id: '1')];
          final expected = [
            [storedDocument(id: '1', minute: 1)],
            [2],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method delete', () {
      group('ids', () {
        test('existing', () async {
          final store = documentStore();
          await store.save(
            entry: storedDocument(id: '1'),
            bytes: Uint8List.fromList([1]),
          );
          await store.save(
            entry: storedDocument(id: '2'),
            bytes: Uint8List.fromList([2]),
          );
          await store.delete(id: '1');
          final actual = [await store.list(), await store.load(id: '1')];
          final expected = [
            [storedDocument(id: '2')],
            null,
          ];
          expect(actual, equals(expected));
        });
        test('missing', () async {
          final store = documentStore();
          await store.save(
            entry: storedDocument(id: '1'),
            bytes: Uint8List.fromList([1]),
          );
          await store.delete(id: '2');
          final actual = await store.list();
          final expected = [storedDocument(id: '1')];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
