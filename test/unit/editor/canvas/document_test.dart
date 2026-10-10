import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';

import '../../../support/layer_probes.dart';

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
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
                ),
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
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
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
              ),
            ],
            activeLayerIndex: 0,
          );
          expect(actual, equals(expected));
        });
      });

      group('name', () {
        test('default', () {
          final actual = Document.blank(width: 1, height: 1).name;
          const expected = 'Untitled';
          expect(actual, equals(expected));
        });
        test('given', () {
          final actual = Document.blank(name: 'Cat', width: 1, height: 1).name;
          const expected = 'Cat';
          expect(actual, equals(expected));
        });
      });
    });

    group('factory fromImage', () {
      group('name', () {
        test('default', () {
          final image = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          final actual = Document.fromImage(image: image).name;
          const expected = 'Untitled';
          expect(actual, equals(expected));
        });
        test('given', () {
          final image = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          final actual = Document.fromImage(name: 'Cat', image: image).name;
          const expected = 'Cat';
          expect(actual, equals(expected));
        });
      });

      group('image', () {
        test('background layer', () {
          final image = Layer.filled(
            width: 3,
            height: 2,
            color: PixelColor.white,
          );
          final actual = Document.fromImage(image: image);
          final expected = Document(
            width: 3,
            height: 2,
            layers: [DocumentLayer(name: 'Background', pixels: image)],
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
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 1,
                  height: 1,
                  rgba: Uint8List.fromList([1, 2, 3, 4]),
                ),
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
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 1,
                  height: 1,
                  rgba: Uint8List.fromList([1, 2, 3, 4]),
                ),
              ),
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 1,
                  height: 1,
                  rgba: Uint8List.fromList([5, 6, 7, 8]),
                ),
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
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 1,
                  height: 1,
                  rgba: Uint8List.fromList([1, 2, 3, 4]),
                ),
              ),
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 1,
                  height: 1,
                  rgba: Uint8List.fromList([5, 6, 7, 8]),
                ),
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

    group('method flatten', () {
      group('background', () {
        test('transparent', () {
          final document = Document.blank(width: 1, height: 1);
          final actual = pixelRows(
            document.flatten(background: PixelColor.transparent),
          );
          final expected = [
            [0x00000000],
          ];
          expect(actual, equals(expected));
        });
        test('white', () {
          final document = Document.blank(width: 1, height: 1);
          final actual = pixelRows(
            document.flatten(background: PixelColor.white),
          );
          final expected = [
            [0xFFFFFFFF],
          ];
          expect(actual, equals(expected));
        });
      });

      group('layers', () {
        test('opaque over opaque', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: layerFromRows([
                  [0xFFFF0000, 0xFFFF0000],
                ]),
              ),
              DocumentLayer(
                name: 'Top',
                pixels: layerFromRows([
                  [0xFF0000FF, 0x00000000],
                ]),
              ),
            ],
            activeLayerIndex: 0,
          );
          final actual = pixelRows(
            document.flatten(background: PixelColor.transparent),
          );
          final expected = [
            [0xFF0000FF, 0xFFFF0000],
          ];
          expect(actual, equals(expected));
        });
        test('translucent over opaque', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Top',
                pixels: layerFromRows([
                  [0x800000FF],
                ]),
              ),
            ],
            activeLayerIndex: 0,
          );
          final actual = pixelRows(
            document.flatten(background: PixelColor.white),
          );
          final expected = [
            [0xFF7F7FFF],
          ];
          expect(actual, equals(expected));
        });
        test('translucent over transparent', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Top',
                pixels: layerFromRows([
                  [0x800000FF],
                ]),
              ),
            ],
            activeLayerIndex: 0,
          );
          final actual = pixelRows(
            document.flatten(background: PixelColor.transparent),
          );
          final expected = [
            [0x800000FF],
          ];
          expect(actual, equals(expected));
        });
        test('hidden', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Top',
                pixels: layerFromRows([
                  [0xFF0000FF],
                ]),
                visible: false,
              ),
            ],
            activeLayerIndex: 0,
          );
          final actual = pixelRows(
            document.flatten(background: PixelColor.white),
          );
          final expected = [
            [0xFFFFFFFF],
          ];
          expect(actual, equals(expected));
        });
        test('half opacity', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Top',
                pixels: layerFromRows([
                  [0xFF000000],
                ]),
                opacity: 50,
              ),
            ],
            activeLayerIndex: 0,
          );
          final actual = pixelRows(
            document.flatten(background: PixelColor.white),
          );
          final expected = [
            [0xFF808080],
          ];
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
        test('different name', () {
          final document = Document.blank(name: 'A', width: 2, height: 1);
          final other = Document.blank(name: 'B', width: 2, height: 1);
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different store id', () {
          final document = Document.blank(width: 2, height: 1);
          final other = Document.blank(width: 2, height: 1)..storeId = '1';
          final actual = document == other;
          const expected = false;
          expect(actual, equals(expected));
        });
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
        test('different name', () {
          final document = Document.blank(name: 'A', width: 2, height: 1);
          final other = Document.blank(name: 'B', width: 2, height: 1);
          final actual = document.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different store id', () {
          final document = Document.blank(width: 2, height: 1);
          final other = Document.blank(width: 2, height: 1)..storeId = '1';
          final actual = document.hashCode == other.hashCode;
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
          const expected = 'Document(Untitled, 2, 1, layers: 1, active: 0)';
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer.filled(
                  width: 2,
                  height: 1,
                  color: PixelColor.transparent,
                ),
              ),
              DocumentLayer(
                name: 'Background',
                pixels: Layer.filled(
                  width: 2,
                  height: 1,
                  color: PixelColor.transparent,
                ),
              ),
            ],
            activeLayerIndex: 1,
          );
          final actual = document.toString();
          const expected = 'Document(Untitled, 2, 1, layers: 2, active: 1)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
