import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/widgets/components/resize_dialog.dart';

import '../../../support/layer_probes.dart';
import '../../../support/stub_canvas.dart';

void main() {
  const red = 0xFFFF0000;
  const green = 0xFF00FF00;

  group('class ResizePreviewPainter', () {
    group('method paint', () {
      group('areas', () {
        test('whole thumbnail', () {
          final canvas = StubCanvas();
          ResizePreviewPainter(
            thumbnail: layerFromRows([
              [red, green],
            ]),
            origin: const Offset(0, 0),
            scale: 2,
          ).paint(canvas, const Size(4, 2));
          final actual = [
            canvas.clippedRectangles,
            canvas.translations,
            canvas.scales,
            canvas.drawnRectangles,
            canvas.saveCount,
            canvas.restoreCount,
          ];
          const expected = [
            [Rect.fromLTWH(0, 0, 4, 2)],
            [Offset(0, 0)],
            [2.0],
            [
              (Rect.fromLTWH(0, 0, 1, 1), red),
              (Rect.fromLTWH(1, 0, 1, 1), green),
            ],
            1,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('clipped thumbnail', () {
          final canvas = StubCanvas();
          ResizePreviewPainter(
            thumbnail: layerFromRows([
              [red, green],
            ]),
            origin: const Offset(-2, 0),
            scale: 2,
          ).paint(canvas, const Size(2, 2));
          final actual = [canvas.translations, canvas.drawnRectangles];
          const expected = [
            [Offset(-2, 0)],
            [(Rect.fromLTWH(1, 0, 1, 1), green)],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('changes', () {
        test('same', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final resizePreviewPainter = ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: const Offset(1, 1),
            scale: 2,
          );
          final other = ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: const Offset(1, 1),
            scale: 2,
          );
          final actual = resizePreviewPainter.shouldRepaint(other);
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different thumbnail', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final resizePreviewPainter = ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: const Offset(1, 1),
            scale: 2,
          );
          final other = ResizePreviewPainter(
            thumbnail: Layer.copyOf(thumbnail),
            origin: const Offset(1, 1),
            scale: 2,
          );
          final actual = resizePreviewPainter.shouldRepaint(other);
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different origin', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final resizePreviewPainter = ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: const Offset(1, 1),
            scale: 2,
          );
          final other = ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: const Offset(0, 1),
            scale: 2,
          );
          final actual = resizePreviewPainter.shouldRepaint(other);
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different scale', () {
          final thumbnail = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final resizePreviewPainter = ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: const Offset(1, 1),
            scale: 2,
          );
          final other = ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: const Offset(1, 1),
            scale: 3,
          );
          final actual = resizePreviewPainter.shouldRepaint(other);
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
