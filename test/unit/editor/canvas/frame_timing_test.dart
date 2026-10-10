import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/frame_timing.dart';

void main() {
  group('class FrameTiming', () {
    group('factory fromDurations', () {
      group('durations', () {
        test('single', () {
          final actual = FrameTiming.fromDurations(centiseconds: [10]);
          const expected = FrameTiming(fps: 10, holds: [1]);
          expect(actual, equals(expected));
        });
        test('common unit', () {
          final actual = FrameTiming.fromDurations(centiseconds: [4, 8, 12]);
          const expected = FrameTiming(fps: 25, holds: [1, 2, 3]);
          expect(actual, equals(expected));
        });
        test('zero', () {
          final actual = FrameTiming.fromDurations(centiseconds: [0, 20]);
          const expected = FrameTiming(fps: 10, holds: [1, 2]);
          expect(actual, equals(expected));
        });
        test('fractional fps', () {
          final actual = FrameTiming.fromDurations(centiseconds: [3, 6]);
          const expected = FrameTiming(fps: 33, holds: [1, 2]);
          expect(actual, equals(expected));
        });
      });
      group('limits', () {
        test('slower than minimum fps', () {
          final actual = FrameTiming.fromDurations(centiseconds: [200]);
          const expected = FrameTiming(fps: 1, holds: [1]);
          expect(actual, equals(expected));
        });
        test('more than maximum holds', () {
          final actual = FrameTiming.fromDurations(centiseconds: [1, 500]);
          const expected = FrameTiming(fps: 100, holds: [1, 100]);
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          const frameTiming = FrameTiming(fps: 10, holds: [1, 2]);
          final other = FrameTiming(fps: 10, holds: [1, 2]);
          final actual = frameTiming == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different fps', () {
          const frameTiming = FrameTiming(fps: 10, holds: [1]);
          const other = FrameTiming(fps: 12, holds: [1]);
          final actual = frameTiming == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different holds', () {
          const frameTiming = FrameTiming(fps: 10, holds: [1]);
          const other = FrameTiming(fps: 10, holds: [2]);
          final actual = frameTiming == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          const frameTiming = FrameTiming(fps: 10, holds: [1]);
          const Object other = 10;
          final actual = frameTiming == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          const frameTiming = FrameTiming(fps: 10, holds: [1, 2]);
          final other = FrameTiming(fps: 10, holds: [1, 2]);
          final actual = frameTiming.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different holds', () {
          const frameTiming = FrameTiming(fps: 10, holds: [1]);
          const other = FrameTiming(fps: 10, holds: [2]);
          final actual = frameTiming.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('all', () {
          const frameTiming = FrameTiming(fps: 10, holds: [1, 2]);
          final actual = frameTiming.toString();
          const expected = 'FrameTiming(10 fps, holds: [1, 2])';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
