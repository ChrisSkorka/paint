// coverage:ignore-file

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'document_store.dart';
import 'file_document_store.dart';

Future<DocumentStore> createPlatformDocumentStore() async {
  final supportDirectory = await getApplicationSupportDirectory();
  return FileDocumentStore(
    directory: Directory('${supportDirectory.path}/documents'),
  );
}
