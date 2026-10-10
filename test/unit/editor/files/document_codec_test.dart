import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/files/document_codec.dart';
import 'package:paint/editor/files/document_format_exception.dart';
import 'package:paint/editor/files/gif_codec.dart';
import 'package:paint/editor/files/image_codec.dart';
import 'package:paint/editor/files/ora_codec.dart';

import '../../../support/layer_probes.dart';

void main() {
  const red = 0xFFFF0000;

  group('class DocumentCodec', () {
    group('method decode', () {
      group('formats', () {
        test('png', () {
          final bytes = ImageCodec.encodePng(
            layer: layerFromRows([
              [red],
            ]),
          );
          final actual = DocumentCodec.decode(
            fileName: 'cat.png',
            bytes: bytes,
          );
          final expected = Document.fromImage(
            name: 'cat',
            image: layerFromRows([
              [red],
            ]),
          );
          expect(actual, equals(expected));
        });
        test('ora', () {
          final bytes = OraCodec.encode(
            document: Document.blank(
              width: 2,
              height: 1,
              background: PixelColor.white,
            ),
          );
          final actual = DocumentCodec.decode(
            fileName: 'cat.ora',
            bytes: bytes,
          );
          final expected = Document.blank(
            name: 'cat',
            width: 2,
            height: 1,
            background: PixelColor.white,
          );
          expect(actual, equals(expected));
        });
        test('gif', () {
          final bytes = GifCodec.encode(
            document: Document.fromImage(
              image: layerFromRows([
                [red],
              ]),
            ),
          );
          final actual = DocumentCodec.decode(
            fileName: 'cat.gif',
            bytes: bytes,
          );
          final expected = GifCodec.decode(name: 'cat', bytes: bytes);
          expect(actual, equals(expected));
        });
        test('ora with png extension', () {
          final bytes = OraCodec.encode(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = DocumentCodec.decode(
            fileName: 'cat.png',
            bytes: bytes,
          );
          final expected = Document.blank(name: 'cat', width: 2, height: 1);
          expect(actual, equals(expected));
        });
      });

      group('errors', () {
        test('empty', () {
          void event() =>
              DocumentCodec.decode(fileName: 'cat.png', bytes: Uint8List(0));
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('unsupported', () {
          void event() => DocumentCodec.decode(
            fileName: 'cat.png',
            bytes: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
          );
          expect(event, throwsA(equals(DocumentFormatException.unsupported())));
        });
        test('too large', () {
          final bytes = ImageCodec.encodePng(
            layer: Layer.filled(
              width: 4097,
              height: 1,
              color: PixelColor.white,
            ),
          );
          void event() =>
              DocumentCodec.decode(fileName: 'cat.png', bytes: bytes);
          expect(event, throwsA(equals(DocumentFormatException.tooLarge())));
        });
      });
    });

    group('method documentName', () {
      group('extensions', () {
        test('single', () {
          final actual = DocumentCodec.documentName(fileName: 'cat.png');
          const expected = 'cat';
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final actual = DocumentCodec.documentName(fileName: 'cat.v2.ora');
          const expected = 'cat.v2';
          expect(actual, equals(expected));
        });
        test('none', () {
          final actual = DocumentCodec.documentName(fileName: 'cat');
          const expected = 'cat';
          expect(actual, equals(expected));
        });
        test('hidden file', () {
          final actual = DocumentCodec.documentName(fileName: '.cat');
          const expected = '.cat';
          expect(actual, equals(expected));
        });
      });

      group('empty', () {
        test('empty file name', () {
          final actual = DocumentCodec.documentName(fileName: '');
          const expected = 'Untitled';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
