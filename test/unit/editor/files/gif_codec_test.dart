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
    frameDurations: [100, 250],
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
            frameDurations: [100, 250],
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

      group('durations', () {
        test('rounded', () {
          final bytes = GifCodec.encode(
            document: Document.blank(width: 1, height: 1)
              ..frameDurations = [25, 100],
          );
          final actual = GifCodec.decode(
            name: 'Cat',
            bytes: bytes,
          ).frameDurations;
          final expected = [30, 100];
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
      group('durations', () {
        test('zero', () {
          final actual = GifCodec.decode(
            name: 'Cat',
            bytes: gifWithDelays([0, 5]),
          ).frameDurations;
          final expected = [100, 50];
          expect(actual, equals(expected));
        });
        test('too long', () {
          final actual = GifCodec.decode(
            name: 'Cat',
            bytes: gifWithDelays([1500, 1]),
          ).frameDurations;
          final expected = [10000, 10];
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
