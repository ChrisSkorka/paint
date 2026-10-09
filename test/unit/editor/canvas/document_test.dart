import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';

void main() {
  group('class Document', () {
    group('factory blank', () {
      group('background', () {
        test('default', () {
          final actual = Document.blank(width: 2, height: 1);
          final expected = Document(
            width: 2,
            height: 1,
            layers: [
              Layer(
                width: 2,
                height: 1,
                rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
              ),
            ],
            activeLayerIndex: 0,
          );
          expect(actual, equals(expected));
        });
        test('white', () {
          final actual = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.white,
          );
          final expected = Document(
            width: 2,
            height: 1,
            layers: [
              Layer(
                width: 2,
                height: 1,
                rgba: Uint8List.fromList([
                  0xff,
                  0xff,
                  0xff,
                  0xff,
                  0xff,
                  0xff,
                  0xff,
                  0xff,
                ]),
              ),
            ],
            activeLayerIndex: 0,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('getter activeLayer', () {
      group('single layer', () {
        test('only', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              Layer(
                width: 1,
                height: 1,
                rgba: Uint8List.fromList([1, 2, 3, 4]),
              ),
            ],
            activeLayerIndex: 0,
          );
          final actual = document.activeLayer;
          final expected = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          expect(actual, equals(expected));
        });
      });
      group('multiple layers', () {
        test('first', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              Layer(
                width: 1,
                height: 1,
                rgba: Uint8List.fromList([1, 2, 3, 4]),
              ),
              Layer(
                width: 1,
                height: 1,
                rgba: Uint8List.fromList([5, 6, 7, 8]),
              ),
            ],
            activeLayerIndex: 0,
          );
          final actual = document.activeLayer;
          final expected = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([1, 2, 3, 4]),
          );
          expect(actual, equals(expected));
        });
        test('second', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              Layer(
                width: 1,
                height: 1,
                rgba: Uint8List.fromList([1, 2, 3, 4]),
              ),
              Layer(
                width: 1,
                height: 1,
                rgba: Uint8List.fromList([5, 6, 7, 8]),
              ),
            ],
            activeLayerIndex: 1,
          );
          final actual = document.activeLayer;
          final expected = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.fromList([5, 6, 7, 8]),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final document = Document.blank(width: 2, height: 1);
          final other = Document.blank(width: 2, height: 1);
          final actual = document == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different width', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: const [],
            activeLayerIndex: 0,
          );
          final other = Document(
            width: 3,
            height: 1,
            layers: const [],
            activeLayerIndex: 0,
          );
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different height', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: const [],
            activeLayerIndex: 0,
          );
          final other = Document(
            width: 2,
            height: 3,
            layers: const [],
            activeLayerIndex: 0,
          );
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different active layer index', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: const [],
            activeLayerIndex: 0,
          );
          final other = Document(
            width: 2,
            height: 1,
            layers: const [],
            activeLayerIndex: 1,
          );
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different layer pixels', () {
          final document = Document.blank(width: 2, height: 1);
          final other = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.white,
          );
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different layer count', () {
          final document = Document.blank(width: 2, height: 1);
          final other = Document(
            width: 2,
            height: 1,
            layers: const [],
            activeLayerIndex: 0,
          );
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          final document = Document.blank(width: 2, height: 1);
          final Object other = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final document = Document.blank(width: 2, height: 1);
          final other = Document.blank(width: 2, height: 1);
          final actual = document.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different layer pixels', () {
          final document = Document.blank(width: 2, height: 1);
          final other = Document.blank(
            width: 2,
            height: 1,
            background: PixelColor.white,
          );
          final actual = document.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('layers', () {
        test('single', () {
          final document = Document.blank(width: 2, height: 1);
          final actual = document.toString();
          const expected = 'Document(2, 1, layers: 1, active: 0)';
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              Layer.filled(width: 2, height: 1, color: PixelColor.transparent),
              Layer.filled(width: 2, height: 1, color: PixelColor.transparent),
            ],
            activeLayerIndex: 1,
          );
          final actual = document.toString();
          const expected = 'Document(2, 1, layers: 2, active: 1)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
