import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/pointer_preview.dart';

import '../../support/layer_probes.dart';
import '../../support/stub_tool.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;

  group('class PointerPreview', () {
    group('factory sized', () {
      group('dimensions', () {
        test('blank', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 1);
          final actual = [
            pixelRows(pointerPreview.layer),
            pointerPreview.area,
            pointerPreview.cursor,
          ];
          const expected = [
            [
              [transparent, transparent],
            ],
            PixelRectangle(left: 0, top: 0, width: 0, height: 0),
            null,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method draw', () {
      group('tools', () {
        test('with tool', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 1);
          pointerPreview.draw(
            tool: StubTool(),
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final actual = [
            pixelRows(pointerPreview.layer),
            pointerPreview.area,
            pointerPreview.cursor,
          ];
          const expected = [
            [
              [transparent, black],
            ],
            PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            PixelPoint(x: 1, y: 0),
          ];
          expect(actual, equals(expected));
        });
        test('without tool', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 1);
          pointerPreview.draw(
            tool: null,
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final actual = [
            pixelRows(pointerPreview.layer),
            pointerPreview.area,
            pointerPreview.cursor,
          ];
          const expected = [
            [
              [transparent, transparent],
            ],
            PixelRectangle(left: 0, top: 0, width: 0, height: 0),
            PixelPoint(x: 1, y: 0),
          ];
          expect(actual, equals(expected));
        });
      });

      group('positions', () {
        test('outside layer', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 1);
          pointerPreview.draw(
            tool: null,
            point: const PixelPoint(x: 2, y: 0),
            color: PixelColor.black,
          );
          final actual = pointerPreview.cursor;
          const expected = null;
          expect(actual, equals(expected));
        });
      });

      group('previous preview', () {
        test('moved', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 1);
          pointerPreview.draw(
            tool: StubTool(),
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          pointerPreview.draw(
            tool: StubTool(),
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final actual = pixelRows(pointerPreview.layer);
          const expected = [
            [transparent, black],
          ];
          expect(actual, equals(expected));
        });
      });

      group('notifications', () {
        test('single draw', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 1);
          var notifications = 0;
          pointerPreview.addListener(() => notifications++);
          pointerPreview.draw(
            tool: null,
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          final actual = notifications;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
    });

    group('method clear', () {
      group('state', () {
        test('after draw', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 1);
          pointerPreview.draw(
            tool: StubTool(),
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          var notifications = 0;
          pointerPreview.addListener(() => notifications++);
          pointerPreview.clear();
          final actual = [
            pixelRows(pointerPreview.layer),
            pointerPreview.area,
            pointerPreview.cursor,
            notifications,
          ];
          const expected = [
            [
              [transparent, transparent],
            ],
            PixelRectangle(left: 0, top: 0, width: 0, height: 0),
            null,
            1,
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
