import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../canvas/document.dart';
import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import 'document_format_exception.dart';
import 'document_store.dart';
import 'ora_codec.dart';
import 'stored_document.dart';

class DocumentLibrary extends ChangeNotifier {
  DocumentLibrary({required this.store, required this.now});

  static const thumbnailSize = 48;

  final DocumentStore store;
  final DateTime Function() now;
  var _documents = const <StoredDocument>[];

  List<StoredDocument> get documents => _documents;

  Future<void> refresh() async {
    final documents = await store.list();
    _documents = documents.sorted(
      (first, second) => second.modified.compareTo(first.modified),
    );
    notifyListeners();
  }

  Future<void> save({required Document document}) async {
    final modified = now();
    final id = document.storeId ??= '${modified.microsecondsSinceEpoch}';
    final entry = StoredDocument(
      id: id,
      name: document.name,
      modified: modified,
      thumbnail: Layer.thumbnail(
        layer: document.flatten(background: PixelColor.transparent, frame: 0),
        maximumSize: thumbnailSize,
      ),
    );
    await store.save(
      entry: entry,
      bytes: OraCodec.encode(document: document),
    );
    await refresh();
  }

  Future<Document> open({required StoredDocument entry}) async {
    final bytes = await store.load(id: entry.id);
    if (bytes == null) throw DocumentFormatException.missing();
    return OraCodec.decode(name: entry.name, bytes: bytes)..storeId = entry.id;
  }

  Future<void> delete({required StoredDocument entry}) async {
    await store.delete(id: entry.id);
    await refresh();
  }
}
