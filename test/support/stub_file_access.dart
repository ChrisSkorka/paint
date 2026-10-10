import 'dart:typed_data';

import 'package:paint/editor/files/export_format.dart';
import 'package:paint/editor/files/file_access.dart';

typedef StubSavedFile = ({
  String fileName,
  ExportFormat format,
  Uint8List bytes,
});

class StubFileAccess implements FileAccess {
  StubFileAccess({this.file, this.saveError});

  OpenedFile? file;
  final Exception? saveError;
  final saved = <StubSavedFile>[];

  @override
  Future<OpenedFile?> open() async => file;

  @override
  Future<void> save({
    required String fileName,
    required ExportFormat format,
    required Uint8List bytes,
  }) async {
    if (saveError case final error?) throw error;
    saved.add((fileName: fileName, format: format, bytes: bytes));
  }
}
