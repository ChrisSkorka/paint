import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/tools/text_format.dart';
import 'package:paint/editor/tools/text_stamp.dart';

import '../../../support/layer_probes.dart';

void main() {
  const red = 0xffff0000;
  const halfRed = 0x80ff0000;
  const transparent = 0x00000000;
  const blue = 0xff0000ff;
  const edgeBlue = 0x910000ff;

  group('class TextStamp', () {
    group('getter extent', () {
      group('text', () {
        test('multiple characters', () {
          final textStamp = TextStamp(
            text: 'ab',
            format: const TextFormat(size: 5),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = textStamp.extent;
          const expected = Size(10, 6);
          expect(actual, equals(expected));
        });
        test('outlined', () {
          final textStamp = TextStamp(
            text: 'ab',
            format: const TextFormat(size: 5, outlined: true, outlineWidth: 2),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = textStamp.extent;
          const expected = Size(14, 10);
          expect(actual, equals(expected));
        });
        test('empty', () {
          final textStamp = TextStamp(
            text: '',
            format: const TextFormat(size: 5),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = textStamp.extent;
          const expected = Size(1, 6);
          expect(actual, equals(expected));
        });
      });
    });

    group('method rasterize', () {
      group('text', () {
        test('single character', () async {
          final textStamp = TextStamp(
            text: 'a',
            format: const TextFormat(size: 5),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = pixelRows(await textStamp.rasterize());
          const expected = [
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [transparent, transparent, transparent, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('multiple characters', () async {
          final textStamp = TextStamp(
            text: 'ab',
            format: const TextFormat(size: 2),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = pixelRows(await textStamp.rasterize());
          const expected = [
            [red, red, red, red],
            [red, red, red, red],
          ];
          expect(actual, equals(expected));
        });
        test('multiple lines', () async {
          final textStamp = TextStamp(
            text: 'a\nb',
            format: const TextFormat(size: 5),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = pixelRows(await textStamp.rasterize());
          const expected = [
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [transparent, transparent, transparent, transparent, transparent],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [red, red, red, red, red],
            [transparent, transparent, transparent, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('empty', () async {
          final textStamp = TextStamp(
            text: '',
            format: const TextFormat(size: 5),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = pixelRows(await textStamp.rasterize());
          const expected = [
            [transparent],
            [transparent],
            [transparent],
            [transparent],
            [transparent],
            [transparent],
          ];
          expect(actual, equals(expected));
        });
      });
      group('outline', () {
        test('filled', () async {
          final textStamp = TextStamp(
            text: 'a',
            format: const TextFormat(size: 2, outlined: true),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = pixelRows(await textStamp.rasterize());
          const expected = [
            [edgeBlue, blue, blue, edgeBlue],
            [blue, red, red, blue],
            [blue, red, red, blue],
            [edgeBlue, blue, blue, edgeBlue],
          ];
          expect(actual, equals(expected));
        });
        test('hollow', () async {
          final textStamp = TextStamp(
            text: 'a',
            format: const TextFormat(size: 2, outlined: true, filled: false),
            color: const PixelColor(argb: red),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = pixelRows(await textStamp.rasterize());
          const expected = [
            [edgeBlue, blue, blue, edgeBlue],
            [blue, blue, blue, blue],
            [blue, blue, blue, blue],
            [edgeBlue, blue, blue, edgeBlue],
          ];
          expect(actual, equals(expected));
        });
      });
      group('color', () {
        test('translucent', () async {
          final textStamp = TextStamp(
            text: 'a',
            format: const TextFormat(size: 2),
            color: const PixelColor(argb: halfRed),
            outlineColor: const PixelColor(argb: blue),
          );
          final actual = pixelRows(await textStamp.rasterize());
          const expected = [
            [halfRed, halfRed],
            [halfRed, halfRed],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
