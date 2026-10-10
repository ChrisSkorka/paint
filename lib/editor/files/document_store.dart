import 'dart:typed_data';

import 'stored_document.dart';

abstract interface class DocumentStore {
  Future<List<StoredDocument>> list();
  Future<Uint8List?> load({required String id});
  Future<void> save({required StoredDocument entry, required Uint8List bytes});
  Future<void> delete({required String id});
}
