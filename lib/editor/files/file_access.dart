import 'dart:typed_data';

import 'export_format.dart';

typedef OpenedFile = ({String name, Uint8List bytes, String? path});

abstract interface class FileAccess {
  Future<OpenedFile?> open({String? directory});
  Future<String?> saveAs({
    required String fileName,
    required String? directory,
    required ExportFormat format,
    required Uint8List bytes,
  });
  Future<void> overwrite({
    required String path,
    required ExportFormat format,
    required Uint8List bytes,
  });
}
