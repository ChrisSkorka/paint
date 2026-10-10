import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/canvas_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';

void main() {
  final stubImage = Layer.filled(
    width: 1,
    height: 1,
    color: PixelColor.transparent,
  );
  final stubOtherImage = Layer.filled(
    width: 1,
    height: 1,
    color: PixelColor.white,
  );

  group('class CanvasLayer', () {
    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final canvasLayer = CanvasLayer(
            image: stubImage,
            opacity: 50,
            tint: PixelColor.black,
          );
          final other = CanvasLayer(
            image: Layer.copyOf(stubImage),
            opacity: 50,
            tint: PixelColor.black,
          );
          final actual = canvasLayer == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different image', () {
          final canvasLayer = CanvasLayer(image: stubImage);
          final other = CanvasLayer(image: stubOtherImage);
          final actual = canvasLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different opacity', () {
          final canvasLayer = CanvasLayer(image: stubImage);
          final other = CanvasLayer(image: stubImage, opacity: 50);
          final actual = canvasLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different tint', () {
          final canvasLayer = CanvasLayer(image: stubImage);
          final other = CanvasLayer(image: stubImage, tint: PixelColor.black);
          final actual = canvasLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          final canvasLayer = CanvasLayer(image: stubImage);
          final Object other = stubImage;
          final actual = canvasLayer == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final canvasLayer = CanvasLayer(image: stubImage, opacity: 50);
          final other = CanvasLayer(
            image: Layer.copyOf(stubImage),
            opacity: 50,
          );
          final actual = canvasLayer.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different tint', () {
          final canvasLayer = CanvasLayer(image: stubImage);
          final other = CanvasLayer(image: stubImage, tint: PixelColor.black);
          final actual = canvasLayer.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('defaults', () {
          final canvasLayer = CanvasLayer(image: stubImage);
          final actual = canvasLayer.toString();
          const expected = 'CanvasLayer(Layer(1, 1), opacity: 100, tint: null)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
