import 'dart:typed_data';

import '../canvas/document.dart';
import 'document_format_exception.dart';
import 'image_codec.dart';
import 'ora_codec.dart';

abstract final class DocumentCodec {
  static const openableExtensions = ['ora', 'png', 'jpg', 'jpeg'];
  static const _zipSignature = [0x50, 0x4B, 0x03, 0x04];

  static Document decode({required String fileName, required Uint8List bytes}) {
    final name = documentName(fileName: fileName);
    if (_isZip(bytes: bytes)) return OraCodec.decode(name: name, bytes: bytes);
    final image = ImageCodec.decode(bytes: bytes);
    if (image == null) throw DocumentFormatException.unsupported();
    DocumentFormatException.checkSize(width: image.width, height: image.height);
    return Document.fromImage(name: name, image: image);
  }

  static String documentName({required String fileName}) {
    final extensionStart = fileName.lastIndexOf('.');
    final name = extensionStart > 0
        ? fileName.substring(0, extensionStart)
        : fileName;
    return name.isEmpty ? Document.untitledName : name;
  }

  static bool _isZip({required Uint8List bytes}) =>
      bytes.length >= _zipSignature.length &&
      Iterable<int>.generate(
        _zipSignature.length,
      ).every((index) => bytes[index] == _zipSignature[index]);
}
