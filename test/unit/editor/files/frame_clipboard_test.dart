import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/files/frame_clipboard.dart';
import 'package:paint/editor/selection/selection_clip.dart';

import '../../../support/layer_probes.dart';
import '../../../support/selection_probes.dart';
import '../../../support/stub_image_clipboard.dart';

void main() {
  const red = 0xFFFF0000;
  const green = 0xFF00FF00;
  const blue = 0xFF0000FF;

  group('class FrameClipboard', () {
    group('method write', () {
      group('clips', () {
        test('single', () async {
          final stubClipboard = StubImageClipboard();
          final frameClipboard = FrameClipboard();
          await frameClipboard.write(
            system: stubClipboard,
            clip: SelectionClip(
              image: layerFromRows([
                [red],
              ]),
            ),
          );
          final actual = [
            for (final image in stubClipboard.written) pixelRows(image),
          ];
          const expected = [
            [
              [red],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('multi frame', () async {
          final stubClipboard = StubImageClipboard();
          final frameClipboard = FrameClipboard();
          await frameClipboard.write(
            system: stubClipboard,
            clip: SelectionClip(
              image: layerFromRows([
                [red],
              ]),
              frames: {
                0: layerFromRows([
                  [red],
                ]),
                1: layerFromRows([
                  [green],
                ]),
              },
            ),
          );
          final actual = [
            for (final image in stubClipboard.written) pixelRows(image),
          ];
          const expected = [
            [
              [red],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method read', () {
      group('empty', () {
        test('system clipboard empty', () async {
          final frameClipboard = FrameClipboard();
          final actual = await frameClipboard.read(
            system: StubImageClipboard(),
          );
          const expected = null;
          expect(actual, equals(expected));
        });
      });
      group('single', () {
        test('external image', () async {
          final frameClipboard = FrameClipboard();
          final clip = await frameClipboard.read(
            system: StubImageClipboard(
              image: layerFromRows([
                [blue],
              ]),
            ),
          );
          final actual = clipRows(clip);
          const expected = [
            [
              [blue],
            ],
            null,
          ];
          expect(actual, equals(expected));
        });
      });
      group('multi frame', () {
        test('matching image', () async {
          final stubClipboard = StubImageClipboard();
          final frameClipboard = FrameClipboard();
          await frameClipboard.write(
            system: stubClipboard,
            clip: SelectionClip(
              image: layerFromRows([
                [red],
              ]),
              frames: {
                0: layerFromRows([
                  [red],
                ]),
                1: layerFromRows([
                  [green],
                ]),
              },
            ),
          );
          final clip = await frameClipboard.read(system: stubClipboard);
          final actual = clipRows(clip);
          const expected = [
            [
              [red],
            ],
            {
              0: [
                [red],
              ],
              1: [
                [green],
              ],
            },
          ];
          expect(actual, equals(expected));
        });
        test('external override', () async {
          final stubClipboard = StubImageClipboard();
          final frameClipboard = FrameClipboard();
          await frameClipboard.write(
            system: stubClipboard,
            clip: SelectionClip(
              image: layerFromRows([
                [red],
              ]),
              frames: {
                0: layerFromRows([
                  [red],
                ]),
              },
            ),
          );
          stubClipboard.image = layerFromRows([
            [blue],
          ]);
          final clip = await frameClipboard.read(system: stubClipboard);
          final actual = clipRows(clip);
          const expected = [
            [
              [blue],
            ],
            null,
          ];
          expect(actual, equals(expected));
        });
        test('after override', () async {
          final stubClipboard = StubImageClipboard();
          final frameClipboard = FrameClipboard();
          await frameClipboard.write(
            system: stubClipboard,
            clip: SelectionClip(
              image: layerFromRows([
                [red],
              ]),
              frames: {
                0: layerFromRows([
                  [red],
                ]),
              },
            ),
          );
          stubClipboard.image = layerFromRows([
            [blue],
          ]);
          await frameClipboard.read(system: stubClipboard);
          stubClipboard.image = layerFromRows([
            [red],
          ]);
          final clip = await frameClipboard.read(system: stubClipboard);
          final actual = clipRows(clip);
          const expected = [
            [
              [red],
            ],
            null,
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
