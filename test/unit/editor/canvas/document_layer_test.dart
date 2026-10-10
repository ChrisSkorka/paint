import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/layer_timeframe.dart';
import 'package:paint/editor/canvas/pixel_color.dart';

void main() {
  final stubPixels = Layer.filled(
    width: 2,
    height: 1,
    color: PixelColor.transparent,
  );
  final stubOtherPixels = Layer.filled(
    width: 2,
    height: 1,
    color: PixelColor.white,
  );

  group('class DocumentLayer', () {
    group('method copyWith', () {
      group('fields', () {
        test('none', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            visible: false,
            opacity: 40,
          );
          final actual = documentLayer.copyWith();
          final expected = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            visible: false,
            opacity: 40,
          );
          expect(actual, equals(expected));
        });
        test('visible', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = documentLayer.copyWith(visible: false);
          final expected = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            visible: false,
          );
          expect(actual, equals(expected));
        });
        test('opacity', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = documentLayer.copyWith(opacity: 25);
          final expected = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            opacity: 25,
          );
          expect(actual, equals(expected));
        });
        test('both', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = documentLayer.copyWith(visible: false, opacity: 25);
          final expected = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            visible: false,
            opacity: 25,
          );
          expect(actual, equals(expected));
        });
        test('name', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = documentLayer.copyWith(name: 'Sketch');
          final expected = DocumentLayer(name: 'Sketch', images: [stubPixels]);
          expect(actual, equals(expected));
        });
        test('images', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = documentLayer.copyWith(
            images: [stubPixels, stubOtherPixels],
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [stubPixels, stubOtherPixels],
          );
          expect(actual, equals(expected));
        });
        test('timeframe', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = documentLayer.copyWith(
            timeframe: LayerTimeframe.perFrame,
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            timeframe: LayerTimeframe.perFrame,
          );
          expect(actual, equals(expected));
        });
      });
      group('pixels', () {
        test('shared', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = identical(
            documentLayer.copyWith(visible: false).images.first,
            stubPixels,
          );
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('method imageAt', () {
      group('constant', () {
        test('first frame', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = identical(documentLayer.imageAt(0), stubPixels);
          const expected = true;
          expect(actual, equals(expected));
        });
        test('later frame', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = identical(documentLayer.imageAt(3), stubPixels);
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('per frame', () {
        test('first frame', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels, stubOtherPixels],
            timeframe: LayerTimeframe.perFrame,
          );
          final actual = identical(documentLayer.imageAt(0), stubPixels);
          const expected = true;
          expect(actual, equals(expected));
        });
        test('later frame', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels, stubOtherPixels],
            timeframe: LayerTimeframe.perFrame,
          );
          final actual = identical(documentLayer.imageAt(1), stubOtherPixels);
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [Layer.copyOf(stubPixels)],
          );
          final actual = documentLayer == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different name', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(name: 'Layer 2', images: [stubPixels]);
          final actual = documentLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different pixels', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [stubOtherPixels],
          );
          final actual = documentLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different visible', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            visible: false,
          );
          final actual = documentLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different opacity', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            opacity: 50,
          );
          final actual = documentLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different image count', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [stubPixels, stubPixels],
          );
          final actual = documentLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different timeframe', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            timeframe: LayerTimeframe.perFrame,
          );
          final actual = documentLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final Object other = stubPixels;
          final actual = documentLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [Layer.copyOf(stubPixels)],
          );
          final actual = documentLayer.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different opacity', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final other = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            opacity: 50,
          );
          final actual = documentLayer.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('default', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
          );
          final actual = documentLayer.toString();
          const expected =
              'DocumentLayer(Background, constant, visible: true, opacity: 100)';
          expect(actual, equals(expected));
        });
        test('hidden translucent', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels],
            visible: false,
            opacity: 30,
          );
          final actual = documentLayer.toString();
          const expected =
              'DocumentLayer(Background, constant, visible: false, opacity: 30)';
          expect(actual, equals(expected));
        });
        test('per frame', () {
          final documentLayer = DocumentLayer(
            name: 'Background',
            images: [stubPixels, stubOtherPixels],
            timeframe: LayerTimeframe.perFrame,
          );
          final actual = documentLayer.toString();
          const expected =
              'DocumentLayer(Background, perFrame, visible: true, opacity: 100)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
