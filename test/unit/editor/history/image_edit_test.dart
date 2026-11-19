import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/image_edit.dart';
import 'package:paint/editor/history/layer_snapshot.dart';

void main() {
  final image = Layer.filled(
    width: 2,
    height: 1,
    color: PixelColor.transparent,
  );

  group('class ImageEdit', () {
    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final other = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final actual = imageEdit == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });

      group('not equals', () {
        test('different entry index', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final other = ImageEdit(
            entryIndex: 1,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final actual = imageEdit == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('equal but different image', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final other = ImageEdit(
            entryIndex: 0,
            image: Layer.copyOf(image),
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final actual = imageEdit == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different before', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final other = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([3, 3, 3, 3]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final actual = imageEdit == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different after', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final other = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([3, 3, 3, 3]),
            ),
          );
          final actual = imageEdit == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final Object other = image;
          final actual = imageEdit == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final other = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final actual = imageEdit.hashCode;
          final expected = other.hashCode;
          expect(actual, equals(expected));
        });
      });

      group('not equals', () {
        test('different entry index', () {
          final imageEdit = ImageEdit(
            entryIndex: 0,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final other = ImageEdit(
            entryIndex: 1,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final actual = imageEdit.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('format', () {
        test('entry index and area', () {
          final imageEdit = ImageEdit(
            entryIndex: 3,
            image: image,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 1, 1, 1]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([2, 2, 2, 2]),
            ),
          );
          final actual = imageEdit.toString();
          const expected = 'ImageEdit(entry: 3, PixelRectangle(1, 0, 1, 1))';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
