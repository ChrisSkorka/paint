import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/files/export_format.dart';
import 'package:paint/editor/files/image_codec.dart';
import 'package:paint/editor/files/ora_codec.dart';

import '../../../support/layer_probes.dart';

void main() {
  const grey = 0xFF808080;
  const transparent = 0x00000000;

  Document greyDocument() => Document(
    name: 'Cat',
    width: 2,
    height: 1,
    layers: [
      DocumentLayer(
        name: 'Background',
        pixels: layerFromRows([
          [grey, transparent],
        ]),
      ),
      DocumentLayer(
        name: 'Hidden',
        pixels: layerFromRows([
          [transparent, grey],
        ]),
        visible: false,
      ),
    ],
    activeLayerIndex: 0,
  );

  group('enum ExportFormat', () {
    group('method fileName', () {
      group('formats', () {
        test('png', () {
          final actual = ExportFormat.png.fileName(document: greyDocument());
          const expected = 'Cat.png';
          expect(actual, equals(expected));
        });
        test('jpg', () {
          final actual = ExportFormat.jpg.fileName(document: greyDocument());
          const expected = 'Cat.jpg';
          expect(actual, equals(expected));
        });
        test('ora', () {
          final actual = ExportFormat.ora.fileName(document: greyDocument());
          const expected = 'Cat.ora';
          expect(actual, equals(expected));
        });
      });
    });

    group('method encode', () {
      group('formats', () {
        test('png', () {
          final actual = pixelRows(
            ImageCodec.decode(
              bytes: ExportFormat.png.encode(document: greyDocument()),
            )!,
          );
          final expected = [
            [grey, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('jpg', () {
          final actual = pixelRows(
            ImageCodec.decode(
              bytes: ExportFormat.jpg.encode(document: greyDocument()),
            )!,
          );
          final expected = [
            [grey, 0xFFFFFFFF],
          ];
          expect(actual, equals(expected));
        });
        test('ora', () {
          final actual = OraCodec.decode(
            name: 'Cat',
            bytes: ExportFormat.ora.encode(document: greyDocument()),
          );
          final expected = greyDocument();
          expect(actual, equals(expected));
        });
      });
    });
  });
}
