import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/files/document_format_exception.dart';

void main() {
  group('class DocumentFormatException', () {
    group('factory tooLarge', () {
      group('message', () {
        test('maximum size', () {
          final actual = DocumentFormatException.tooLarge().message;
          const expected = 'Image is larger than 4096 × 4096';
          expect(actual, equals(expected));
        });
      });
    });

    group('factory unsupported', () {
      group('message', () {
        test('unsupported', () {
          final actual = DocumentFormatException.unsupported().message;
          const expected = 'File is not a supported image';
          expect(actual, equals(expected));
        });
      });
    });

    group('factory missing', () {
      group('message', () {
        test('missing', () {
          final actual = DocumentFormatException.missing().message;
          const expected = 'Document no longer exists';
          expect(actual, equals(expected));
        });
      });
    });

    group('method checkSize', () {
      group('within', () {
        test('maximum', () {
          void event() =>
              DocumentFormatException.checkSize(width: 4096, height: 4096);
          expect(event, returnsNormally);
        });
      });

      group('errors', () {
        test('too wide', () {
          void event() =>
              DocumentFormatException.checkSize(width: 4097, height: 1);
          expect(event, throwsA(equals(DocumentFormatException.tooLarge())));
        });
        test('too tall', () {
          void event() =>
              DocumentFormatException.checkSize(width: 1, height: 4097);
          expect(event, throwsA(equals(DocumentFormatException.tooLarge())));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same message', () {
          const exception = DocumentFormatException(message: 'a');
          const other = DocumentFormatException(message: 'a');
          final actual = exception == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different message', () {
          const exception = DocumentFormatException(message: 'a');
          const other = DocumentFormatException(message: 'b');
          final actual = exception == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same message', () {
          const exception = DocumentFormatException(message: 'a');
          const other = DocumentFormatException(message: 'a');
          final actual = exception.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('message', () {
        test('message', () {
          const exception = DocumentFormatException(message: 'a');
          final actual = exception.toString();
          const expected = 'DocumentFormatException(a)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
