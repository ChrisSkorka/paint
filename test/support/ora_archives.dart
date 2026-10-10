import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

Uint8List oraArchive({String? stack, Map<String, List<int>> files = const {}}) {
  final archive = Archive();
  if (stack != null) {
    archive.add(ArchiveFile.bytes('stack.xml', utf8.encode(stack)));
  }
  for (final file in files.entries) {
    archive.add(ArchiveFile.bytes(file.key, file.value));
  }
  return ZipEncoder().encodeBytes(archive);
}

List<String> archiveFileNames(Uint8List bytes) => [
  for (final file in ZipDecoder().decodeBytes(bytes)) file.name,
];

Uint8List archiveFile(Uint8List bytes, {required String name}) =>
    ZipDecoder().decodeBytes(bytes).findFile(name)!.readBytes()!;

String archiveText(Uint8List bytes, {required String name}) =>
    utf8.decode(archiveFile(bytes, name: name));
