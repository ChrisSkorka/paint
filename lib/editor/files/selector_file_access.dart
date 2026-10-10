import 'dart:typed_data';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'document_codec.dart';
import 'export_format.dart';
import 'file_access.dart';

class SelectorFileAccess implements FileAccess {
  const SelectorFileAccess({required this.platform, required this.web});

  static const openableTypes = [
    XTypeGroup(label: 'Images', extensions: DocumentCodec.openableExtensions),
  ];

  final FileSelectorPlatform platform;
  final bool web;

  @override
  Future<OpenedFile?> open() async {
    final file = await platform.openFile(acceptedTypeGroups: openableTypes);
    if (file == null) return null;
    return (name: file.name, bytes: await file.readAsBytes());
  }

  @override
  Future<void> save({
    required String fileName,
    required ExportFormat format,
    required Uint8List bytes,
  }) async {
    final file = XFile.fromData(
      bytes,
      name: fileName,
      mimeType: format.mimeType,
    );
    if (web) return file.saveTo(fileName);
    final location = await platform.getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(label: format.label, extensions: [format.extension]),
      ],
      options: SaveDialogOptions(suggestedName: fileName),
    );
    if (location == null) return;
    final extension = '.${format.extension}';
    final path = location.path.toLowerCase().endsWith(extension)
        ? location.path
        : '${location.path}$extension';
    await file.saveTo(path);
  }
}
