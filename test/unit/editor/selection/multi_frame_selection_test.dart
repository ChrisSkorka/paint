import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/selection/multi_frame_selection.dart';

import '../../../support/document_probes.dart';
import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const red = 0xFFFF0000;
  const green = 0xFF00FF00;
  const blue = 0xFF0000FF;

  group('class MultiFrameSelection', () {
    group('factory lift', () {
      group('frames', () {
        test('one', () {
          final layer = filmLayer(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
          );
          final multiFrameSelection = MultiFrameSelection.lift(
            layer: layer,
            frames: [1],
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          );
          final actual = [
            multiFrameSelection.frames.keys,
            pixelRows(multiFrameSelection.frames[1]!.content),
          ];
          const expected = [
            [1],
            [
              [green],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final layer = filmLayer(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
          );
          final multiFrameSelection = MultiFrameSelection.lift(
            layer: layer,
            frames: [0, 1],
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          );
          final actual = [
            for (final selection in multiFrameSelection.frames.values)
              pixelRows(selection.content),
          ];
          const expected = [
            [
              [red],
            ],
            [
              [green],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('factory pasted', () {
      group('contents', () {
        test('one', () {
          final layer = filmLayer(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
          );
          MultiFrameSelection.pasted(
            layer: layer,
            contents: {
              1: layerFromRows([
                [blue],
              ]),
            },
            at: const PixelPoint(x: 1, y: 0),
          );
          final actual = [for (final image in layer.images) pixelRows(image)];
          const expected = [
            [
              [red, transparent],
            ],
            [
              [green, blue],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final layer = filmLayer(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
          );
          MultiFrameSelection.pasted(
            layer: layer,
            contents: {
              0: layerFromRows([
                [blue],
              ]),
              1: layerFromRows([
                [red],
              ]),
            },
            at: const PixelPoint(x: 1, y: 0),
          );
          final actual = [for (final image in layer.images) pixelRows(image)];
          const expected = [
            [
              [red, blue],
            ],
            [
              [green, red],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method transformed', () {
      group('frames', () {
        test('one', () {
          final layer = filmLayer(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
          );
          final multiFrameSelection = MultiFrameSelection.lift(
            layer: layer,
            frames: [0],
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          );
          multiFrameSelection.transformed(
            layer: layer,
            transform: (selection, image) =>
                selection.moved(layer: image, offsetX: 1, offsetY: 0),
          );
          final actual = [for (final image in layer.images) pixelRows(image)];
          const expected = [
            [
              [transparent, red],
            ],
            [
              [green, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final layer = filmLayer(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
          );
          final multiFrameSelection = MultiFrameSelection.lift(
            layer: layer,
            frames: [0, 1],
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          );
          multiFrameSelection.transformed(
            layer: layer,
            transform: (selection, image) =>
                selection.moved(layer: image, offsetX: 1, offsetY: 0),
          );
          final actual = [for (final image in layer.images) pixelRows(image)];
          const expected = [
            [
              [transparent, red],
            ],
            [
              [transparent, green],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter area', () {
      group('transformations', () {
        test('moved', () {
          final layer = filmLayer(
            frames: [
              [
                [red, transparent],
              ],
              [
                [green, transparent],
              ],
            ],
          );
          final multiFrameSelection = MultiFrameSelection.lift(
            layer: layer,
            frames: [0, 1],
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
          );
          final actual = multiFrameSelection
              .transformed(
                layer: layer,
                transform: (selection, image) =>
                    selection.moved(layer: image, offsetX: 1, offsetY: 0),
              )
              .area;
          const expected = PixelRectangle(left: 1, top: 0, width: 1, height: 1);
          expect(actual, equals(expected));
        });
      });
    });
  });
}
