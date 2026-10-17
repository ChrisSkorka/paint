import 'dart:typed_data';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'document_codec.dart';
import 'export_format.dart';
import 'file_access.dart';
import 'file_location.dart';

class SelectorFileAccess implements FileAccess {
  const SelectorFileAccess({required this.platform, required this.web});

  static const openableTypes = [
    XTypeGroup(label: 'Images', extensions: DocumentCodec.openableExtensions),
  ];

  final FileSelectorPlatform platform;
  final bool web;

  @override
  Future<OpenedFile?> open({String? directory}) async {
    final file = await platform.openFile(
      acceptedTypeGroups: openableTypes,
      initialDirectory: directory,
    );
    if (file == null) return null;
    return (
      name: file.name,
      bytes: await file.readAsBytes(),
      path: web ? null : file.path,
    );
  }

  @override
  Future<String?> saveAs({
    required String fileName,
    required String? directory,
    required ExportFormat format,
    required Uint8List bytes,
  }) async {
    if (web) {
      await _write(path: fileName, format: format, bytes: bytes);
      return null;
    }
    final location = await platform.getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(label: format.label, extensions: [format.extension]),
      ],
      options: SaveDialogOptions(
        initialDirectory: directory,
        suggestedName: fileName,
      ),
    );
    if (location == null) return null;
    final path = format.matches(path: location.path)
        ? location.path
        : '${location.path}.${format.extension}';
    await _write(path: path, format: format, bytes: bytes);
    return path;
  }

  @override
  Future<void> overwrite({
    required String path,
    required ExportFormat format,
    required Uint8List bytes,
  }) => _write(path: path, format: format, bytes: bytes);

  Future<void> _write({
    required String path,
    required ExportFormat format,
    required Uint8List bytes,
  }) => XFile.fromData(
    bytes,
    name: fileNameOf(path: path),
    mimeType: format.mimeType,
  ).saveTo(path);
}
