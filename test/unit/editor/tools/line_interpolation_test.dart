import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/tools/line_interpolation.dart';

void main() {
  group('standalone', () {
    group('function interpolateLine', () {
      group('single point', () {
        test('same start and end', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 1, y: 1),
            end: const PixelPoint(x: 1, y: 1),
          ).toList();
          const expected = [PixelPoint(x: 1, y: 1)];
          expect(actual, equals(expected));
        });
      });

      group('straight lines', () {
        test('right', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 0, y: 0),
            end: const PixelPoint(x: 2, y: 0),
          ).toList();
          const expected = [
            PixelPoint(x: 0, y: 0),
            PixelPoint(x: 1, y: 0),
            PixelPoint(x: 2, y: 0),
          ];
          expect(actual, equals(expected));
        });
        test('left', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 2, y: 0),
            end: const PixelPoint(x: 0, y: 0),
          ).toList();
          const expected = [
            PixelPoint(x: 2, y: 0),
            PixelPoint(x: 1, y: 0),
            PixelPoint(x: 0, y: 0),
          ];
          expect(actual, equals(expected));
        });
        test('down', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 0, y: 0),
            end: const PixelPoint(x: 0, y: 2),
          ).toList();
          const expected = [
            PixelPoint(x: 0, y: 0),
            PixelPoint(x: 0, y: 1),
            PixelPoint(x: 0, y: 2),
          ];
          expect(actual, equals(expected));
        });
        test('up', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 0, y: 2),
            end: const PixelPoint(x: 0, y: 0),
          ).toList();
          const expected = [
            PixelPoint(x: 0, y: 2),
            PixelPoint(x: 0, y: 1),
            PixelPoint(x: 0, y: 0),
          ];
          expect(actual, equals(expected));
        });
      });

      group('diagonal lines', () {
        test('down right', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 0, y: 0),
            end: const PixelPoint(x: 2, y: 2),
          ).toList();
          const expected = [
            PixelPoint(x: 0, y: 0),
            PixelPoint(x: 1, y: 1),
            PixelPoint(x: 2, y: 2),
          ];
          expect(actual, equals(expected));
        });
        test('up left', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 2, y: 2),
            end: const PixelPoint(x: 0, y: 0),
          ).toList();
          const expected = [
            PixelPoint(x: 2, y: 2),
            PixelPoint(x: 1, y: 1),
            PixelPoint(x: 0, y: 0),
          ];
          expect(actual, equals(expected));
        });
      });

      group('sloped lines', () {
        test('shallow', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 0, y: 0),
            end: const PixelPoint(x: 3, y: 1),
          ).toList();
          const expected = [
            PixelPoint(x: 0, y: 0),
            PixelPoint(x: 1, y: 0),
            PixelPoint(x: 2, y: 1),
            PixelPoint(x: 3, y: 1),
          ];
          expect(actual, equals(expected));
        });
        test('steep', () {
          final actual = interpolateLine(
            start: const PixelPoint(x: 0, y: 0),
            end: const PixelPoint(x: 1, y: 3),
          ).toList();
          const expected = [
            PixelPoint(x: 0, y: 0),
            PixelPoint(x: 0, y: 1),
            PixelPoint(x: 1, y: 2),
            PixelPoint(x: 1, y: 3),
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
