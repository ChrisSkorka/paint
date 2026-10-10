// coverage:ignore-file

import 'package:idb_shim/idb_browser.dart';

import 'document_store.dart';
import 'idb_document_store.dart';

Future<DocumentStore> createPlatformDocumentStore() async {
  return IdbDocumentStore.open(factory: idbFactoryBrowser);
}
