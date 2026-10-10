import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/layer_timeframe.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/files/document_format_exception.dart';
import 'package:paint/editor/files/image_codec.dart';
import 'package:paint/editor/files/ora_codec.dart';

import '../../../support/layer_probes.dart';
import '../../../support/ora_archives.dart';

void main() {
  const red = 0xFFFF0000;
  const blue = 0xFF0000FF;
  const transparent = 0x00000000;

  Document twoLayerDocument() => Document(
    name: 'Cat',
    width: 2,
    height: 1,
    layers: [
      DocumentLayer(
        name: 'Background',
        images: [
          layerFromRows([
            [red, red],
          ]),
        ],
      ),
      DocumentLayer(
        name: 'Top',
        images: [
          layerFromRows([
            [blue, transparent],
          ]),
        ],
        visible: false,
        opacity: 50,
      ),
    ],
    activeLayerIndex: 0,
  );

  Document animatedDocument() => Document(
    name: 'Cat',
    width: 2,
    height: 1,
    layers: [
      DocumentLayer(
        name: 'Background',
        images: [
          layerFromRows([
            [red, red],
          ]),
        ],
      ),
      DocumentLayer(
        name: 'Sprite',
        images: [
          layerFromRows([
            [blue, transparent],
          ]),
          layerFromRows([
            [transparent, blue],
          ]),
        ],
        timeframe: LayerTimeframe.perFrame,
        opacity: 50,
      ),
    ],
    activeLayerIndex: 1,
    frameHolds: [1, 2],
  );

  List<int> png(List<List<int>> rows) =>
      ImageCodec.encodePng(layer: layerFromRows(rows));

  group('class OraCodec', () {
    group('method encode', () {
      group('contents', () {
        test('file names', () {
          final actual = archiveFileNames(
            OraCodec.encode(document: twoLayerDocument()),
          );
          const expected = [
            'mimetype',
            'stack.xml',
            'mergedimage.png',
            'Thumbnails/thumbnail.png',
            'data/layer0.png',
            'data/layer1.png',
          ];
          expect(actual, equals(expected));
        });
        test('mimetype', () {
          final bytes = OraCodec.encode(document: twoLayerDocument());
          final mimetype = ZipDecoder().decodeBytes(bytes).first;
          final actual = [
            archiveText(bytes, name: 'mimetype'),
            mimetype.compression,
          ];
          const expected = ['image/openraster', CompressionType.none];
          expect(actual, equals(expected));
        });
        test('stack', () {
          final actual = archiveText(
            OraCodec.encode(document: twoLayerDocument()),
            name: 'stack.xml',
          );
          const expected =
              '<?xml version="1.0" encoding="UTF-8"?>\n'
              '<image xmlns:paint="urn:info.skorka.chris.paint" version="0.0.5" '
              'w="2" h="1" paint:fps="10" paint:frame-holds="1">\n'
              '  <stack>\n'
              '    <layer name="Top" src="data/layer1.png" x="0" y="0" '
              'visibility="hidden" opacity="0.50"/>\n'
              '    <layer name="Background" src="data/layer0.png" x="0" y="0" '
              'visibility="visible" opacity="1.00" selected="true"/>\n'
              '  </stack>\n'
              '</image>';
          expect(actual, equals(expected));
        });
        test('layer images', () {
          final bytes = OraCodec.encode(document: twoLayerDocument());
          final actual = [
            for (final name in ['data/layer0.png', 'data/layer1.png'])
              pixelRows(
                ImageCodec.decode(bytes: archiveFile(bytes, name: name))!,
              ),
          ];
          final expected = [
            [
              [red, red],
            ],
            [
              [blue, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('merged image', () {
          final actual = pixelRows(
            ImageCodec.decode(
              bytes: archiveFile(
                OraCodec.encode(document: twoLayerDocument()),
                name: 'mergedimage.png',
              ),
            )!,
          );
          final expected = [
            [red, red],
          ];
          expect(actual, equals(expected));
        });
      });

      group('thumbnail', () {
        test('small document', () {
          final actual = ImageCodec.decode(
            bytes: archiveFile(
              OraCodec.encode(document: twoLayerDocument()),
              name: 'Thumbnails/thumbnail.png',
            ),
          );
          final expected = layerFromRows([
            [red, red],
          ]);
          expect(actual, equals(expected));
        });
        test('large document', () {
          final actual = ImageCodec.decode(
            bytes: archiveFile(
              OraCodec.encode(
                document: Document.blank(
                  width: 512,
                  height: 256,
                  background: PixelColor.white,
                ),
              ),
              name: 'Thumbnails/thumbnail.png',
            ),
          );
          final expected = Layer.filled(
            width: 256,
            height: 128,
            color: PixelColor.white,
          );
          expect(actual, equals(expected));
        });
      });

      group('frames', () {
        test('file names', () {
          final actual = archiveFileNames(
            OraCodec.encode(document: animatedDocument()),
          );
          const expected = [
            'mimetype',
            'stack.xml',
            'mergedimage.png',
            'Thumbnails/thumbnail.png',
            'data/layer0.png',
            'data/layer1-frame0.png',
            'data/layer1-frame1.png',
          ];
          expect(actual, equals(expected));
        });
        test('stack', () {
          final actual = archiveText(
            OraCodec.encode(document: animatedDocument()),
            name: 'stack.xml',
          );
          const expected =
              '<?xml version="1.0" encoding="UTF-8"?>\n'
              '<image xmlns:paint="urn:info.skorka.chris.paint" version="0.0.5" '
              'w="2" h="1" paint:fps="10" paint:frame-holds="1,2">\n'
              '  <stack>\n'
              '    <stack name="Sprite" visibility="visible" opacity="0.50" '
              'selected="true" paint:timeframe="per-frame">\n'
              '      <layer name="Sprite 1" src="data/layer1-frame0.png" x="0" '
              'y="0" visibility="visible" opacity="1.00"/>\n'
              '      <layer name="Sprite 2" src="data/layer1-frame1.png" x="0" '
              'y="0" visibility="hidden" opacity="1.00"/>\n'
              '    </stack>\n'
              '    <layer name="Background" src="data/layer0.png" x="0" y="0" '
              'visibility="visible" opacity="1.00"/>\n'
              '  </stack>\n'
              '</image>';
          expect(actual, equals(expected));
        });
        test('merged image', () {
          final bytes = OraCodec.encode(
            document: animatedDocument()..activeFrameIndex = 1,
          );
          final actual = pixelRows(
            ImageCodec.decode(
              bytes: archiveFile(bytes, name: 'mergedimage.png'),
            )!,
          );
          final expected = [
            [0xFF800080, red],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method decode', () {
      group('round trip', () {
        test('single layer', () {
          final document = Document.blank(
            name: 'Cat',
            width: 2,
            height: 1,
            background: PixelColor.white,
          );
          final actual = OraCodec.decode(
            name: 'Cat',
            bytes: OraCodec.encode(document: document),
          );
          final expected = Document.blank(
            name: 'Cat',
            width: 2,
            height: 1,
            background: PixelColor.white,
          );
          expect(actual, equals(expected));
        });
        test('multiple layers', () {
          final actual = OraCodec.decode(
            name: 'Cat',
            bytes: OraCodec.encode(document: twoLayerDocument()),
          );
          final expected = twoLayerDocument();
          expect(actual, equals(expected));
        });
        test('name', () {
          final actual = OraCodec.decode(
            name: 'Dog',
            bytes: OraCodec.encode(document: twoLayerDocument()),
          ).name;
          const expected = 'Dog';
          expect(actual, equals(expected));
        });
      });

      group('other apps', () {
        test('missing attributes', () {
          final bytes = oraArchive(
            stack:
                '<image w="2" h="1"><stack>'
                '<layer src="a.png"/><layer src="b.png"/>'
                '</stack></image>',
            files: {
              'a.png': png([
                [blue, blue],
              ]),
              'b.png': png([
                [red, red],
              ]),
            },
          );
          final actual = OraCodec.decode(name: 'Cat', bytes: bytes);
          final expected = Document(
            name: 'Cat',
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Layer 1',
                images: [
                  layerFromRows([
                    [red, red],
                  ]),
                ],
              ),
              DocumentLayer(
                name: 'Layer 2',
                images: [
                  layerFromRows([
                    [blue, blue],
                  ]),
                ],
              ),
            ],
            activeLayerIndex: 1,
          );
          expect(actual, equals(expected));
        });
        test('offset layer', () {
          final bytes = oraArchive(
            stack:
                '<image w="3" h="1"><stack>'
                '<layer name="A" src="a.png" x="1" y="0"/>'
                '</stack></image>',
            files: {
              'a.png': png([
                [blue, blue, blue],
              ]),
            },
          );
          final actual = pixelRows(
            OraCodec.decode(
              name: 'Cat',
              bytes: bytes,
            ).layers.single.images.first,
          );
          final expected = [
            [transparent, blue, blue],
          ];
          expect(actual, equals(expected));
        });
        test('nested stack', () {
          final bytes = oraArchive(
            stack:
                '<image w="1" h="1"><stack>'
                '<stack><layer name="A" src="a.png"/></stack>'
                '<layer name="B" src="b.png"/>'
                '</stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
              'b.png': png([
                [red],
              ]),
            },
          );
          final actual = [
            for (final layer in OraCodec.decode(
              name: 'Cat',
              bytes: bytes,
            ).layers)
              layer.name,
          ];
          const expected = ['B', 'A'];
          expect(actual, equals(expected));
        });
        test('out of range opacity', () {
          final bytes = oraArchive(
            stack:
                '<image w="1" h="1"><stack>'
                '<layer name="A" src="a.png" opacity="1.5"/>'
                '<layer name="B" src="a.png" opacity="-1"/>'
                '</stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final actual = [
            for (final layer in OraCodec.decode(
              name: 'Cat',
              bytes: bytes,
            ).layers)
              layer.opacity,
          ];
          const expected = [0, 100];
          expect(actual, equals(expected));
        });
      });

      group('frames', () {
        test('round trip', () {
          final actual = OraCodec.decode(
            name: 'Cat',
            bytes: OraCodec.encode(document: animatedDocument()),
          );
          final expected = animatedDocument();
          expect(actual, equals(expected));
        });
        test('missing timing', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1">'
                '<stack><layer src="a.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final decoded = OraCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            10,
            [1],
          ];
          expect(actual, equals(expected));
        });
        test('invalid timing', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1" paint:fps="abc" paint:frame-holds="abc,0,500">'
                '<stack><layer src="a.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final decoded = OraCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            10,
            [1, 0, 100],
          ];
          expect(actual, equals(expected));
        });
        test('zero first hold', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1" paint:fps="0" paint:frame-holds="0,2">'
                '<stack><layer src="a.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final decoded = OraCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            1,
            [1, 2],
          ];
          expect(actual, equals(expected));
        });
        test('fps too high', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1" paint:fps="500" paint:frame-holds="1">'
                '<stack><layer src="a.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final decoded = OraCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            100,
            [1],
          ];
          expect(actual, equals(expected));
        });
        test('legacy durations', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1" paint:frame-durations="100,200">'
                '<stack><layer src="a.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final decoded = OraCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            10,
            [1, 2],
          ];
          expect(actual, equals(expected));
        });
        test('invalid legacy durations', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1" paint:frame-durations="abc, 50">'
                '<stack><layer src="a.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final decoded = OraCodec.decode(name: 'Cat', bytes: bytes);
          final actual = [decoded.fps, decoded.frameHolds];
          final expected = [
            20,
            [2, 1],
          ];
          expect(actual, equals(expected));
        });
        test('missing frame images', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1" paint:frame-durations="100,100">'
                '<stack><stack name="A" paint:timeframe="per-frame">'
                '<layer src="a.png"/>'
                '</stack></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final actual = [
            for (final image in OraCodec.decode(
              name: 'Cat',
              bytes: bytes,
            ).layers.single.images)
              pixelRows(image),
          ];
          final expected = [
            [
              [blue],
            ],
            [
              [transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('extra frame images', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1">'
                '<stack><stack name="A" paint:timeframe="per-frame">'
                '<layer src="a.png"/><layer src="b.png"/>'
                '</stack></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
              'b.png': png([
                [red],
              ]),
            },
          );
          final actual = OraCodec.decode(name: 'Cat', bytes: bytes);
          final expected = Document(
            name: 'Cat',
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'A',
                images: [
                  layerFromRows([
                    [blue],
                  ]),
                ],
                timeframe: LayerTimeframe.perFrame,
              ),
            ],
            activeLayerIndex: 0,
          );
          expect(actual, equals(expected));
        });
        test('frame stack in nested stack', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1">'
                '<stack><stack>'
                '<stack name="A" paint:timeframe="per-frame">'
                '<layer src="a.png"/></stack>'
                '</stack><layer name="B" src="b.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
              'b.png': png([
                [red],
              ]),
            },
          );
          final actual = [
            for (final layer in OraCodec.decode(
              name: 'Cat',
              bytes: bytes,
            ).layers)
              [layer.name, layer.timeframe],
          ];
          final expected = [
            ['B', LayerTimeframe.constant],
            ['A', LayerTimeframe.perFrame],
          ];
          expect(actual, equals(expected));
        });
        test('other stack attribute', () {
          final bytes = oraArchive(
            stack:
                '<image xmlns:paint="urn:info.skorka.chris.paint" w="1" h="1">'
                '<stack><stack name="A" paint:timeframe="other">'
                '<layer name="B" src="a.png"/>'
                '</stack></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final actual = [
            for (final layer in OraCodec.decode(
              name: 'Cat',
              bytes: bytes,
            ).layers)
              [layer.name, layer.timeframe],
          ];
          final expected = [
            ['B', LayerTimeframe.constant],
          ];
          expect(actual, equals(expected));
        });
        test('ignored elements', () {
          final bytes = oraArchive(
            stack:
                '<image w="1" h="1">'
                '<stack><text/><layer name="B" src="a.png"/></stack></image>',
            files: {
              'a.png': png([
                [blue],
              ]),
            },
          );
          final actual = [
            for (final layer in OraCodec.decode(
              name: 'Cat',
              bytes: bytes,
            ).layers)
              layer.name,
          ];
          final expected = ['B'];
          expect(actual, equals(expected));
        });
      });

      group('errors', () {
        test('not a zip', () {
          final bytes = ImageCodec.encodePng(
            layer: layerFromRows([
              [red],
            ]),
          );
          void event() => OraCodec.decode(name: 'Cat', bytes: bytes);
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('damaged zip', () {
          final bytes = OraCodec.encode(document: twoLayerDocument());
          final dataStart =
              String.fromCharCodes(bytes).indexOf('stack.xml') +
              'stack.xml'.length;
          final damaged = bytes.sublist(0);
          for (var offset = dataStart; offset < dataStart + 8; offset++) {
            damaged[offset] ^= 0xFF;
          }
          void event() => OraCodec.decode(name: 'Cat', bytes: damaged);
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('missing stack', () {
          void event() => OraCodec.decode(name: 'Cat', bytes: oraArchive());
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('invalid stack', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(stack: '<image'),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('missing size', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(stack: '<image><stack/></image>'),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('zero height', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(stack: '<image w="1" h="0"><stack/></image>'),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('too large', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(stack: '<image w="4097" h="1"><stack/></image>'),
          );
          expect(event, throwsA(equals(DocumentFormatException.tooLarge())));
        });
        test('no layers', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(stack: '<image w="1" h="1"><stack/></image>'),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('missing root stack', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(
              stack: '<image w="1" h="1"><layer src="a.png"/></image>',
              files: {
                'a.png': png([
                  [blue],
                ]),
              },
            ),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('missing source attribute', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(
              stack: '<image w="1" h="1"><stack><layer/></stack></image>',
            ),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('missing layer image', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(
              stack:
                  '<image w="1" h="1"><stack>'
                  '<layer src="a.png"/>'
                  '</stack></image>',
            ),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('undecodable layer image', () {
          void event() => OraCodec.decode(
            name: 'Cat',
            bytes: oraArchive(
              stack:
                  '<image w="1" h="1"><stack>'
                  '<layer src="a.png"/>'
                  '</stack></image>',
              files: {
                'a.png': [1, 2, 3],
              },
            ),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
      });
    });
  });
}
