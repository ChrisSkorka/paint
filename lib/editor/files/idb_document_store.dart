import 'dart:typed_data';

import 'package:idb_shim/idb.dart';

import 'document_store.dart';
import 'stored_document.dart';

class IdbDocumentStore implements DocumentStore {
  IdbDocumentStore({required this.database});

  factory IdbDocumentStore.open({required IdbFactory factory}) {
    return IdbDocumentStore(
      database: factory.open(
        databaseName,
        version: 1,
        onUpgradeNeeded: (event) => event.database
          ..createObjectStore(documentsStoreName)
          ..createObjectStore(indexStoreName),
      ),
    );
  }

  static const databaseName = 'paint';
  static const documentsStoreName = 'documents';
  static const indexStoreName = 'index';

  final Future<Database> database;

  Future<Transaction> _transaction({required String mode}) async =>
      (await database).transactionList([
        documentsStoreName,
        indexStoreName,
      ], mode);

  @override
  Future<List<StoredDocument>> list() async {
    final transaction = await _transaction(mode: idbModeReadOnly);
    final entries = await transaction.objectStore(indexStoreName).getAll();
    await transaction.completed;
    return [
      for (final entry in entries)
        StoredDocument.fromJson((entry as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<Uint8List?> load({required String id}) async {
    final transaction = await _transaction(mode: idbModeReadOnly);
    final bytes = await transaction
        .objectStore(documentsStoreName)
        .getObject(id);
    await transaction.completed;
    return bytes as Uint8List?;
  }

  @override
  Future<void> save({
    required StoredDocument entry,
    required Uint8List bytes,
  }) async {
    final transaction = await _transaction(mode: idbModeReadWrite);
    await transaction.objectStore(documentsStoreName).put(bytes, entry.id);
    await transaction.objectStore(indexStoreName).put(entry.toJson(), entry.id);
    await transaction.completed;
  }

  @override
  Future<void> delete({required String id}) async {
    final transaction = await _transaction(mode: idbModeReadWrite);
    await transaction.objectStore(documentsStoreName).delete(id);
    await transaction.objectStore(indexStoreName).delete(id);
    await transaction.completed;
  }
}
