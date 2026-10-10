import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/files/stored_document.dart';

void main() {
  StoredDocument storedDocument({
    String id = '1',
    String name = 'Cat',
    int minute = 0,
    PixelColor color = PixelColor.white,
  }) => StoredDocument(
    id: id,
    name: name,
    modified: DateTime(2026, 10, 10, 12, minute),
    thumbnail: Layer.filled(width: 2, height: 1, color: color),
  );

  group('class StoredDocument', () {
    group('factory fromJson', () {
      group('round trip', () {
        test('all fields', () {
          final actual = StoredDocument.fromJson(storedDocument().toJson());
          final expected = storedDocument();
          expect(actual, equals(expected));
        });
      });
    });

    group('method toJson', () {
      group('fields', () {
        test('all fields', () {
          final actual = storedDocument().toJson().keys.toList();
          const expected = ['id', 'name', 'modified', 'thumbnail'];
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final actual = storedDocument() == storedDocument();
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different id', () {
          final actual = storedDocument() == storedDocument(id: '2');
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different name', () {
          final actual = storedDocument() == storedDocument(name: 'Dog');
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different modified', () {
          final actual = storedDocument() == storedDocument(minute: 1);
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different thumbnail', () {
          final actual =
              storedDocument() == storedDocument(color: PixelColor.black);
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final actual = storedDocument().hashCode == storedDocument().hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different id', () {
          final actual =
              storedDocument().hashCode == storedDocument(id: '2').hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('id name modified', () {
          final actual = storedDocument().toString();
          const expected = 'StoredDocument(1, Cat, 2026-10-10 12:00:00.000)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
