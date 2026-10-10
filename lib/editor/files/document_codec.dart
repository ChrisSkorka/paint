import 'dart:typed_data';

import '../canvas/document.dart';
import 'document_format_exception.dart';
import 'gif_codec.dart';
import 'image_codec.dart';
import 'ora_codec.dart';

abstract final class DocumentCodec {
  static const openableExtensions = ['ora', 'png', 'jpg', 'jpeg', 'gif'];
  static const _zipSignature = [0x50, 0x4B, 0x03, 0x04];
  static const _gifSignature = [0x47, 0x49, 0x46, 0x38];

  static Document decode({required String fileName, required Uint8List bytes}) {
    final name = documentName(fileName: fileName);
    if (_startsWith(bytes: bytes, signature: _zipSignature)) {
      return OraCodec.decode(name: name, bytes: bytes);
    }
    if (_startsWith(bytes: bytes, signature: _gifSignature)) {
      return GifCodec.decode(name: name, bytes: bytes);
    }
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

  static bool _startsWith({
    required Uint8List bytes,
    required List<int> signature,
  }) =>
      bytes.length >= signature.length &&
      Iterable<int>.generate(
        signature.length,
      ).every((index) => bytes[index] == signature[index]);
}
