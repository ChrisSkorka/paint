import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'document_store.dart';
import 'stored_document.dart';

class FileDocumentStore implements DocumentStore {
  const FileDocumentStore({required this.directory});

  static const indexFileName = 'index.json';

  final Directory directory;

  File get _indexFile => File('${directory.path}/$indexFileName');

  File _documentFile({required String id}) => File('${directory.path}/$id.ora');

  @override
  Future<List<StoredDocument>> list() async {
    if (!await _indexFile.exists()) return [];
    final entries = jsonDecode(await _indexFile.readAsString()) as List;
    return [
      for (final entry in entries)
        StoredDocument.fromJson(entry as Map<String, Object?>),
    ];
  }

  @override
  Future<Uint8List?> load({required String id}) async {
    final file = _documentFile(id: id);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<void> save({
    required StoredDocument entry,
    required Uint8List bytes,
  }) async {
    await directory.create(recursive: true);
    await _documentFile(id: entry.id).writeAsBytes(bytes);
    final entries = await list();
    await _writeIndex(
      entries: [...entries.where((stored) => stored.id != entry.id), entry],
    );
  }

  @override
  Future<void> delete({required String id}) async {
    final file = _documentFile(id: id);
    if (await file.exists()) await file.delete();
    final entries = await list();
    await _writeIndex(
      entries: entries.where((stored) => stored.id != id).toList(),
    );
  }

  Future<void> _writeIndex({required List<StoredDocument> entries}) async {
    await directory.create(recursive: true);
    await _indexFile.writeAsString(
      jsonEncode([for (final entry in entries) entry.toJson()]),
    );
  }
}
