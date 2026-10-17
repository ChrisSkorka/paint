import 'dart:async';
import 'dart:typed_data';

import 'package:paint/editor/files/export_format.dart';
import 'package:paint/editor/files/file_access.dart';

typedef StubSavedFile = ({
  String fileName,
  String? directory,
  ExportFormat format,
  Uint8List bytes,
});

typedef StubOverwrittenFile = ({
  String path,
  ExportFormat format,
  Uint8List bytes,
});

class StubFileAccess implements FileAccess {
  StubFileAccess({this.file, this.saveError, this.savePath, this.saveGate});

  OpenedFile? file;
  final Exception? saveError;
  final String? savePath;
  final Completer<void>? saveGate;
  final openDirectories = <String?>[];
  final saved = <StubSavedFile>[];
  final overwritten = <StubOverwrittenFile>[];

  @override
  Future<OpenedFile?> open({String? directory}) async {
    openDirectories.add(directory);
    return file;
  }

  @override
  Future<String?> saveAs({
    required String fileName,
    required String? directory,
    required ExportFormat format,
    required Uint8List bytes,
  }) async {
    if (saveError case final error?) throw error;
    saved.add((
      fileName: fileName,
      directory: directory,
      format: format,
      bytes: bytes,
    ));
    await saveGate?.future;
    return savePath;
  }

  @override
  Future<void> overwrite({
    required String path,
    required ExportFormat format,
    required Uint8List bytes,
  }) async {
    if (saveError case final error?) throw error;
    overwritten.add((path: path, format: format, bytes: bytes));
  }
}
