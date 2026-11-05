import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/layer_timeframe.dart';
import 'package:paint/editor/canvas/pixel_color.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const red = 0xFFFF0000;
  const green = 0xFF00FF00;
  const blue = 0xFF0000FF;
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
    group('factory merged', () {
      group('pixels', () {
        test('opaque top', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red, red],
                ]),
              ],
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue, transparent],
                ]),
              ],
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [blue, red],
              ]),
            ],
          );
          expect(actual, equals(expected));
        });
        test('translucent top', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red],
                ]),
              ],
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [0x800000FF],
                ]),
              ],
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [0xFF7F0080],
              ]),
            ],
          );
          expect(actual, equals(expected));
        });
        test('top opacity', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red],
                ]),
              ],
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue],
                ]),
              ],
              opacity: 50,
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [0xFF800080],
              ]),
            ],
          );
          expect(actual, equals(expected));
        });
        test('bottom opacity', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red],
                ]),
              ],
              opacity: 50,
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue],
                ]),
              ],
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [blue],
              ]),
            ],
            opacity: 50,
          );
          expect(actual, equals(expected));
        });
        test('hidden top', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red],
                ]),
              ],
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue],
                ]),
              ],
              visible: false,
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [blue],
              ]),
            ],
          );
          expect(actual, equals(expected));
        });
      });
      group('timeframes', () {
        test('constant on constant', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red, red],
                ]),
              ],
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue, transparent],
                ]),
              ],
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [blue, red],
              ]),
            ],
          );
          expect(actual, equals(expected));
        });
        test('constant on per frame', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red, red],
                ]),
                layerFromRows([
                  [green, green],
                ]),
              ],
              timeframe: LayerTimeframe.perFrame,
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue, transparent],
                ]),
              ],
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [blue, red],
              ]),
              layerFromRows([
                [blue, green],
              ]),
            ],
            timeframe: LayerTimeframe.perFrame,
          );
          expect(actual, equals(expected));
        });
        test('per frame on constant', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red, red],
                ]),
              ],
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue, transparent],
                ]),
                layerFromRows([
                  [transparent, blue],
                ]),
              ],
              timeframe: LayerTimeframe.perFrame,
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [blue, red],
              ]),
              layerFromRows([
                [red, blue],
              ]),
            ],
            timeframe: LayerTimeframe.perFrame,
          );
          expect(actual, equals(expected));
        });
        test('per frame on per frame', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red, red],
                ]),
                layerFromRows([
                  [green, green],
                ]),
              ],
              timeframe: LayerTimeframe.perFrame,
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [blue, transparent],
                ]),
                layerFromRows([
                  [transparent, blue],
                ]),
              ],
              timeframe: LayerTimeframe.perFrame,
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [blue, red],
              ]),
              layerFromRows([
                [green, blue],
              ]),
            ],
            timeframe: LayerTimeframe.perFrame,
          );
          expect(actual, equals(expected));
        });
      });
      group('settings', () {
        test('bottom settings kept', () {
          final actual = DocumentLayer.merged(
            bottom: DocumentLayer(
              name: 'Background',
              images: [
                layerFromRows([
                  [red],
                ]),
              ],
              visible: false,
              opacity: 40,
            ),
            top: DocumentLayer(
              name: 'Sketch',
              images: [
                layerFromRows([
                  [transparent],
                ]),
              ],
              opacity: 70,
            ),
          );
          final expected = DocumentLayer(
            name: 'Background',
            images: [
              layerFromRows([
                [red],
              ]),
            ],
            visible: false,
            opacity: 40,
          );
          expect(actual, equals(expected));
        });
      });
      group('images', () {
        test('originals unchanged', () {
          final bottomImage = layerFromRows([
            [red],
          ]);
          final topImage = layerFromRows([
            [blue],
          ]);
          DocumentLayer.merged(
            bottom: DocumentLayer(name: 'Background', images: [bottomImage]),
            top: DocumentLayer(name: 'Sketch', images: [topImage]),
          );
          final actual = [pixelRows(bottomImage), pixelRows(topImage)];
          const expected = [
            [
              [red],
            ],
            [
              [blue],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

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
