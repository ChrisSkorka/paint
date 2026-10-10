import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/layer_timeframe.dart';
import 'package:paint/editor/files/document_format_exception.dart';
import 'package:paint/editor/files/gif_codec.dart';
import 'package:paint/editor/files/image_codec.dart';

import '../../../support/layer_probes.dart';

void main() {
  const red = 0xFFFF0000;
  const blue = 0xFF0000FF;
  const transparent = 0x00000000;

  Document animatedDocument() => Document(
    width: 2,
    height: 1,
    layers: [
      DocumentLayer(
        name: 'Background',
        images: [
          layerFromRows([
            [red, transparent],
          ]),
        ],
      ),
      DocumentLayer(
        name: 'Sprite',
        images: [
          layerFromRows([
            [transparent, blue],
          ]),
          layerFromRows([
            [blue, transparent],
          ]),
        ],
        timeframe: LayerTimeframe.perFrame,
      ),
    ],
    activeLayerIndex: 1,
    frameHolds: [1, 2],
  );

  Layer gradient({required int colors}) {
    final rgba = Uint8List(colors * 4);
    for (var index = 0; index < colors; index++) {
      rgba[index * 4] = index % 256;
      rgba[index * 4 + 1] = index ~/ 256;
      rgba[index * 4 + 3] = 255;
    }
    return Layer(width: colors, height: 1, rgba: rgba);
  }

  Uint8List gifWithDelays(List<int> delays) {
    final encoder = image.GifEncoder();
    for (final delay in delays) {
      encoder.addFrame(
        ImageCodec.toImage(
          layer: layerFromRows([
            [red],
          ]),
        ),
        duration: delay,
      );
    }
    return encoder.finish()!;
  }

  group('class GifCodec', () {
    group('method holdCentiseconds', () {
      group('fps', () {
        test('default', () {
          final actual = GifCodec.holdCentiseconds(fps: 10);
          const expected = 10;
          expect(actual, equals(expected));
        });
        test('rounded', () {
          final actual = GifCodec.holdCentiseconds(fps: 30);
          const expected = 3;
          expect(actual, equals(expected));
        });
        test('faster than a centisecond', () {
          final actual = GifCodec.holdCentiseconds(fps: 250);
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
    });

    group('method encode', () {
      group('round trip', () {
        test('single frame', () {
          final bytes = GifCodec.encode(
            document: Document.fromImage(
              image: layerFromRows([
                [red, blue],
              ]),
            ),
          );
          final actual = GifCodec.decode(name: 'Cat', bytes: bytes);
          final expected = Document(
            name: 'Cat',
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                images: [
                  layerFromRows([
                    [red, blue],
                  ]),
                ],
                timeframe: LayerTimeframe.perFrame,
              ),
            ],
            activeLayerIndex: 0,
          );
          expect(actual, equals(expected));
        });
        test('multiple frames', () {
          final bytes = GifCodec.encode(document: animatedDocument());
          final actual = GifCodec.decode(name: 'Cat', bytes: bytes);
          final expected = Document(
            name: 'Cat',
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                images: [
                  layerFromRows([
                    [red, blue],
                  ]),
                  layerFromRows([
                    [blue, transparent],
                  ]),
                ],
                timeframe: LayerTimeframe.perFrame,
              ),
            ],
            activeLayerIndex: 0,
            frameHolds: [1, 2],
          );
          expect(actual, equals(expected));
        });
      });

      group('transparency', () {
        test('transparent pixel', () {
          final bytes = GifCodec.encode(
            document: Document.fromImage(
              image: layerFromRows([
                [red, transparent],
              ]),
            ),
          );
          final actual = pixelRows(
            GifCodec.decode(name: 'Cat', bytes: bytes).activeLayer,
          );
          final expected = [
            [red, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('translucent pixels', () {
          final bytes = GifCodec.encode(
            document: Document.fromImage(
              image: layerFromRows([
                [0x80FF0000, 0x7FFF0000],
              ]),
            ),
          );
          final actual = pixelRows(
            GifCodec.decode(name: 'Cat', bytes: bytes).activeLayer,
          );
          final expected = [
            [red, transparent],
          ];
          expect(actual, equals(expected));
        });
      });

      group('timing', () {
        test('rounded hold', () {
          final bytes = GifCodec.encode(document: animatedDocument()..fps = 30);
          final decoded = GifCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            33,
            [1, 2],
          ];
          expect(actual, equals(expected));
        });
        test('hidden frame', () {
          final document = animatedDocument()..frameHolds = [1, 0];
          final bytes = GifCodec.encode(document: document);
          final decoded = GifCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.frameHolds, pixelRows(decoded.activeLayer)];
          final expected = [
            [1],
            [
              [red, blue],
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('colors', () {
        test('palette sized', () {
          final layer = gradient(colors: 255);
          final bytes = GifCodec.encode(
            document: Document.fromImage(image: layer),
          );
          final actual = pixelRows(
            GifCodec.decode(name: 'Cat', bytes: bytes).activeLayer,
          );
          final expected = pixelRows(layer);
          expect(actual, equals(expected));
        });
        test('more than palette', () {
          final bytes = GifCodec.encode(
            document: Document.fromImage(image: gradient(colors: 300)),
          );
          final decoded = GifCodec.decode(name: 'Cat', bytes: bytes);
          final colors = pixelRows(decoded.activeLayer).first.toSet();
          final actual = [colors.length <= 255, decoded.width];
          final expected = [true, 300];
          expect(actual, equals(expected));
        });
      });
    });

    group('method decode', () {
      group('timing', () {
        test('common unit', () {
          final decoded = GifCodec.decode(
            name: 'Cat',
            bytes: gifWithDelays([10, 20]),
          );
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            10,
            [1, 2],
          ];
          expect(actual, equals(expected));
        });
        test('zero delay', () {
          final decoded = GifCodec.decode(
            name: 'Cat',
            bytes: gifWithDelays([0, 5]),
          );
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            20,
            [2, 1],
          ];
          expect(actual, equals(expected));
        });
      });

      group('errors', () {
        test('not a gif', () {
          void event() => GifCodec.decode(
            name: 'Cat',
            bytes: Uint8List.fromList([1, 2, 3]),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('truncated', () {
          final bytes = gifWithDelays([10]).sublist(0, 6);
          void event() => GifCodec.decode(name: 'Cat', bytes: bytes);
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('too large', () {
          final bytes = image.encodeGif(image.Image(width: 4097, height: 1));
          void event() => GifCodec.decode(name: 'Cat', bytes: bytes);
          expect(event, throwsA(equals(DocumentFormatException.tooLarge())));
        });
      });
    });
  });
}
