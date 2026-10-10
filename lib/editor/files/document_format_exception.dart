import '../canvas/document.dart';

class DocumentFormatException implements Exception {
  const DocumentFormatException({required this.message});

  factory DocumentFormatException.tooLarge() {
    return const DocumentFormatException(
      message:
          'Image is larger than ${Document.maximumSize} × ${Document.maximumSize}',
    );
  }

  factory DocumentFormatException.unsupported() {
    return const DocumentFormatException(
      message: 'File is not a supported image',
    );
  }

  factory DocumentFormatException.missing() {
    return const DocumentFormatException(message: 'Document no longer exists');
  }

  static void checkSize({required int width, required int height}) {
    if (width > Document.maximumSize || height > Document.maximumSize) {
      throw DocumentFormatException.tooLarge();
    }
  }

  final String message;

  @override
  bool operator ==(Object other) =>
      other is DocumentFormatException && other.message == message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'DocumentFormatException($message)';
}
