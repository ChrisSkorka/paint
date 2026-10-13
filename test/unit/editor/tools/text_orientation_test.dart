import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/tools/text_orientation.dart';

import '../../../support/layer_probes.dart';

void main() {
  const red = 0xffff0000;
  const green = 0xff00ff00;
  const blue = 0xff0000ff;
  const cyan = 0xff00ffff;
  const magenta = 0xffff00ff;
  const yellow = 0xffffff00;

  Layer source() => layerFromRows([
    [red, green, blue],
    [cyan, magenta, yellow],
  ]);

  group('class TextOrientation', () {
    group('method rotate', () {
      group('directions', () {
        test('clockwise', () {
          const textOrientation = TextOrientation(quarterTurns: 1);
          final actual = textOrientation.rotate(clockwise: true);
          const expected = TextOrientation(quarterTurns: 2);
          expect(actual, equals(expected));
        });
        test('clockwise wraps', () {
          const textOrientation = TextOrientation(quarterTurns: 3);
          final actual = textOrientation.rotate(clockwise: true);
          const expected = TextOrientation();
          expect(actual, equals(expected));
        });
        test('counterclockwise wraps', () {
          const textOrientation = TextOrientation(mirrored: true);
          final actual = textOrientation.rotate(clockwise: false);
          const expected = TextOrientation(quarterTurns: 3, mirrored: true);
          expect(actual, equals(expected));
        });
      });
    });

    group('method mirror', () {
      group('axes', () {
        test('horizontally', () {
          const textOrientation = TextOrientation(quarterTurns: 1);
          final actual = textOrientation.mirror(horizontally: true);
          const expected = TextOrientation(quarterTurns: 3, mirrored: true);
          expect(actual, equals(expected));
        });
        test('vertically', () {
          const textOrientation = TextOrientation(quarterTurns: 1);
          final actual = textOrientation.mirror(horizontally: false);
          const expected = TextOrientation(quarterTurns: 1, mirrored: true);
          expect(actual, equals(expected));
        });
        test('twice', () {
          const textOrientation = TextOrientation(quarterTurns: 1);
          final actual = textOrientation
              .mirror(horizontally: true)
              .mirror(horizontally: true);
          const expected = TextOrientation(quarterTurns: 1);
          expect(actual, equals(expected));
        });
      });
    });

    group('method apply', () {
      group('orientations', () {
        test('upright', () {
          const textOrientation = TextOrientation();
          final actual = pixelRows(textOrientation.apply(source()));
          const expected = [
            [red, green, blue],
            [cyan, magenta, yellow],
          ];
          expect(actual, equals(expected));
        });
        test('rotated', () {
          const textOrientation = TextOrientation(quarterTurns: 1);
          final actual = pixelRows(textOrientation.apply(source()));
          const expected = [
            [cyan, red],
            [magenta, green],
            [yellow, blue],
          ];
          expect(actual, equals(expected));
        });
        test('mirrored', () {
          const textOrientation = TextOrientation(mirrored: true);
          final actual = pixelRows(textOrientation.apply(source()));
          const expected = [
            [blue, green, red],
            [yellow, magenta, cyan],
          ];
          expect(actual, equals(expected));
        });
        test('mirrored and rotated', () {
          const textOrientation = TextOrientation(
            quarterTurns: 2,
            mirrored: true,
          );
          final actual = pixelRows(textOrientation.apply(source()));
          const expected = [
            [cyan, magenta, yellow],
            [red, green, blue],
          ];
          expect(actual, equals(expected));
        });
      });
      group('composed', () {
        test('rotate then mirror horizontally', () {
          final textOrientation = const TextOrientation()
              .rotate(clockwise: true)
              .mirror(horizontally: true);
          final actual = pixelRows(textOrientation.apply(source()));
          final expected = pixelRows(
            Layer.mirrored(
              layer: Layer.rotated(layer: source(), clockwise: true),
              horizontally: true,
            ),
          );
          expect(actual, equals(expected));
        });
        test('mirror vertically then rotate', () {
          final textOrientation = const TextOrientation()
              .mirror(horizontally: false)
              .rotate(clockwise: false);
          final actual = pixelRows(textOrientation.apply(source()));
          final expected = pixelRows(
            Layer.rotated(
              layer: Layer.mirrored(layer: source(), horizontally: false),
              clockwise: false,
            ),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          const textOrientation = TextOrientation(quarterTurns: 2);
          const other = TextOrientation(quarterTurns: 2);
          final actual = textOrientation == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different quarter turns', () {
          const textOrientation = TextOrientation(quarterTurns: 2);
          const other = TextOrientation(quarterTurns: 1);
          final actual = textOrientation == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different mirrored', () {
          const textOrientation = TextOrientation();
          const other = TextOrientation(mirrored: true);
          final actual = textOrientation == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          const textOrientation = TextOrientation();
          const Object other = 'TextOrientation';
          final actual = textOrientation == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          const textOrientation = TextOrientation(mirrored: true);
          const other = TextOrientation(mirrored: true);
          final actual = textOrientation.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different fields', () {
          const textOrientation = TextOrientation();
          const other = TextOrientation(quarterTurns: 1);
          final actual = textOrientation.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('all', () {
          const textOrientation = TextOrientation(
            quarterTurns: 1,
            mirrored: true,
          );
          final actual = textOrientation.toString();
          const expected = 'TextOrientation(quarter turns: 1, mirrored: true)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
