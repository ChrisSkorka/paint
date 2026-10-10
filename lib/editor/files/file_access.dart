import 'dart:typed_data';

import 'export_format.dart';

typedef OpenedFile = ({String name, Uint8List bytes});

abstract interface class FileAccess {
  Future<OpenedFile?> open();
  Future<void> save({
    required String fileName,
    required ExportFormat format,
    required Uint8List bytes,
  });
}
