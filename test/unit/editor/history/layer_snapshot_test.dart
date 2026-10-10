import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/layer_snapshot.dart';

void main() {
  group('class LayerSnapshot', () {
    group('factory capture', () {
      group('areas', () {
        test('inside', () {
          final layer = Layer(
            width: 3,
            height: 2,
            rgba: Uint8List.fromList(List.generate(24, (index) => index)),
          );
          final actual = LayerSnapshot.capture(
            layer: layer,
            area: const PixelRectangle(left: 1, top: 0, width: 2, height: 2),
          );
          final expected = LayerSnapshot(
            area: const PixelRectangle(left: 1, top: 0, width: 2, height: 2),
            rgba: Uint8List.fromList([
              4, 5, 6, 7, 8, 9, 10, 11, //
              16, 17, 18, 19, 20, 21, 22, 23,
            ]),
          );
          expect(actual, equals(expected));
        });
        test('whole layer', () {
          final layer = Layer(
            width: 2,
            height: 1,
            rgba: Uint8List.fromList(List.generate(8, (index) => index)),
          );
          final actual = LayerSnapshot.capture(
            layer: layer,
            area: layer.bounds,
          );
          final expected = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
            rgba: Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]),
          );
          expect(actual, equals(expected));
        });
        test('partly outside', () {
          final layer = Layer(
            width: 3,
            height: 2,
            rgba: Uint8List.fromList(List.generate(24, (index) => index)),
          );
          final actual = LayerSnapshot.capture(
            layer: layer,
            area: const PixelRectangle(left: 2, top: 1, width: 5, height: 5),
          );
          final expected = LayerSnapshot(
            area: const PixelRectangle(left: 2, top: 1, width: 1, height: 1),
            rgba: Uint8List.fromList([20, 21, 22, 23]),
          );
          expect(actual, equals(expected));
        });
        test('empty', () {
          final layer = Layer(
            width: 3,
            height: 2,
            rgba: Uint8List.fromList(List.generate(24, (index) => index)),
          );
          final actual = LayerSnapshot.capture(
            layer: layer,
            area: const PixelRectangle(left: 1, top: 1, width: 0, height: 0),
          );
          final expected = LayerSnapshot(
            area: const PixelRectangle(left: 1, top: 1, width: 0, height: 0),
            rgba: Uint8List(0),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('method restore', () {
      group('areas', () {
        test('inside', () {
          final layer = Layer(width: 3, height: 2, rgba: Uint8List(24));
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 1, top: 0, width: 2, height: 2),
            rgba: Uint8List.fromList(List.generate(16, (index) => index + 1)),
          );
          layerSnapshot.restore(layer);
          final actual = layer.rgba;
          final expected = Uint8List.fromList([
            0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, //
            0, 0, 0, 0, 9, 10, 11, 12, 13, 14, 15, 16,
          ]);
          expect(actual, equals(expected));
        });
        test('whole layer', () {
          final layer = Layer(width: 2, height: 1, rgba: Uint8List(8));
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
          );
          layerSnapshot.restore(layer);
          final actual = layer.rgba;
          final expected = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
          expect(actual, equals(expected));
        });
        test('empty', () {
          final layer = Layer(width: 2, height: 1, rgba: Uint8List(8));
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 1, top: 0, width: 0, height: 0),
            rgba: Uint8List(0),
          );
          layerSnapshot.restore(layer);
          final actual = layer.rgba;
          final expected = Uint8List(8);
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same area and pixels', () {
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final actual = layerSnapshot == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different area', () {
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = LayerSnapshot(
            area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final actual = layerSnapshot == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different pixels', () {
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 5]),
          );
          final actual = layerSnapshot == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final Object other = Uint8List.fromList([1, 2, 3, 4]);
          final actual = layerSnapshot == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same area and pixels', () {
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final actual = layerSnapshot.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different pixels', () {
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          final other = LayerSnapshot(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            rgba: Uint8List.fromList([1, 2, 3, 5]),
          );
          final actual = layerSnapshot.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('format', () {
        test('area', () {
          final layerSnapshot = LayerSnapshot(
            area: const PixelRectangle(left: 1, top: 2, width: 3, height: 4),
            rgba: Uint8List(48),
          );
          final actual = layerSnapshot.toString();
          const expected = 'LayerSnapshot(PixelRectangle(1, 2, 3, 4))';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
