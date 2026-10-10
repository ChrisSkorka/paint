import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/files/image_codec.dart';

import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const red = 0xFFFF0000;
  const translucentBlue = 0x800000FF;
  const white = 0xFFFFFFFF;

  group('class ImageCodec', () {
    group('method encodePng', () {
      group('round trip', () {
        test('pixels', () {
          final layer = layerFromRows([
            [red, transparent],
            [translucentBlue, white],
          ]);
          final decoded = ImageCodec.decode(
            bytes: ImageCodec.encodePng(layer: layer),
          )!;
          final actual = pixelRows(decoded);
          final expected = [
            [red, transparent],
            [translucentBlue, white],
          ];
          expect(actual, equals(expected));
        });
        test('offset view', () {
          final buffer = Uint8List.fromList([
            ...[0, 0, 0, 0],
            ...[0xFF, 0, 0, 0xFF],
          ]);
          final layer = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.sublistView(buffer, 4),
          );
          final decoded = ImageCodec.decode(
            bytes: ImageCodec.encodePng(layer: layer),
          )!;
          final actual = pixelRows(decoded);
          final expected = [
            [red],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method encodeJpg', () {
      group('round trip', () {
        test('grey pixels', () {
          final layer = layerFromRows([
            [0xFF808080, 0xFF000000],
          ]);
          final actual = pixelRows(
            ImageCodec.decode(bytes: ImageCodec.encodeJpg(layer: layer))!,
          );
          final expected = [
            [0xFF808080, 0xFF000000],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method decode', () {
      group('formats', () {
        test('rgb png', () {
          final source = image.Image(width: 2, height: 1)
            ..setPixelRgb(0, 0, 255, 0, 0)
            ..setPixelRgb(1, 0, 255, 255, 255);
          final decoded = ImageCodec.decode(bytes: image.encodePng(source))!;
          final actual = pixelRows(decoded);
          final expected = [
            [red, white],
          ];
          expect(actual, equals(expected));
        });
        test('palette png', () {
          final source = image.quantize(
            image.Image(width: 2, height: 1)
              ..setPixelRgb(0, 0, 255, 0, 0)
              ..setPixelRgb(1, 0, 255, 255, 255),
            numberOfColors: 2,
            method: image.QuantizeMethod.octree,
          );
          final decoded = ImageCodec.decode(bytes: image.encodePng(source))!;
          final actual = pixelRows(decoded);
          final expected = [
            [red, white],
          ];
          expect(actual, equals(expected));
        });
        test('jpeg size', () {
          final source = image.Image(width: 3, height: 2);
          final decoded = ImageCodec.decode(bytes: image.encodeJpg(source))!;
          final actual = [decoded.width, decoded.height];
          const expected = [3, 2];
          expect(actual, equals(expected));
        });
      });
      group('invalid', () {
        test('unknown bytes', () {
          final actual = ImageCodec.decode(bytes: Uint8List(64));
          const expected = null;
          expect(actual, equals(expected));
        });
        test('truncated bytes', () {
          final actual = ImageCodec.decode(
            bytes: Uint8List.fromList([1, 2, 3, 4]),
          );
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toLayer', () {
      group('formats', () {
        test('rgb image', () {
          final source = image.Image(width: 2, height: 1)
            ..setPixelRgb(0, 0, 255, 0, 0)
            ..setPixelRgb(1, 0, 255, 255, 255);
          final actual = pixelRows(ImageCodec.toLayer(decoded: source));
          final expected = [
            [red, white],
          ];
          expect(actual, equals(expected));
        });
        test('rgba image', () {
          final source = image.Image(width: 1, height: 1, numChannels: 4)
            ..setPixelRgba(0, 0, 255, 0, 0, 0x80);
          final actual = pixelRows(ImageCodec.toLayer(decoded: source));
          final expected = [
            [0x80FF0000],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method toImage', () {
      group('pixels', () {
        test('rgba', () {
          final converted = ImageCodec.toImage(
            layer: layerFromRows([
              [0x80FF0000, white],
            ]),
          );
          final actual = [
            for (final pixel in converted) [pixel.r, pixel.g, pixel.b, pixel.a],
          ];
          final expected = [
            [255, 0, 0, 0x80],
            [255, 255, 255, 255],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
