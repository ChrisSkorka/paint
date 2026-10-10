import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/history/document_structure.dart';

void main() {
  final stubBackground = DocumentLayer(
    name: 'Background',
    images: [Layer.filled(width: 1, height: 1, color: PixelColor.white)],
  );
  final stubSketch = DocumentLayer(
    name: 'Sketch',
    images: [Layer.filled(width: 1, height: 1, color: PixelColor.black)],
  );

  group('class DocumentStructure', () {
    group('factory capture', () {
      group('document', () {
        test('single frame', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
          );
          final actual = DocumentStructure.capture(document: document);
          final expected = DocumentStructure(
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          expect(actual, equals(expected));
        });
        test('multiple frames', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: [100, 200],
            activeFrameIndex: 1,
          );
          final actual = DocumentStructure.capture(document: document);
          final expected = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100, 200],
            activeFrameIndex: 1,
          );
          expect(actual, equals(expected));
        });
      });
      group('independence', () {
        test('later layer change', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
          );
          final documentStructure = DocumentStructure.capture(
            document: document,
          );
          document.layers.add(stubSketch);
          final actual = documentStructure.layers;
          final expected = [stubBackground];
          expect(actual, equals(expected));
        });
      });
    });

    group('method restore', () {
      group('fields', () {
        test('all', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
          );
          final documentStructure = DocumentStructure(
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
            frameDurations: const [100, 200],
            activeFrameIndex: 1,
          );
          documentStructure.restore(document);
          final actual = document;
          final expected = Document(
            width: 1,
            height: 1,
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
            frameDurations: [100, 200],
            activeFrameIndex: 1,
          );
          expect(actual, equals(expected));
        });
      });
      group('independence', () {
        test('later document change', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
          );
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          documentStructure.restore(document);
          document.layers.add(stubSketch);
          final actual = documentStructure.layers;
          final expected = [stubBackground];
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final other = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final actual = documentStructure == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different layers', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final other = DocumentStructure(
            layers: [stubSketch],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final actual = documentStructure == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different active layer', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final other = DocumentStructure(
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final actual = documentStructure == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different frame durations', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final other = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [200],
            activeFrameIndex: 0,
          );
          final actual = documentStructure == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different active frame', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100, 100],
            activeFrameIndex: 0,
          );
          final other = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100, 100],
            activeFrameIndex: 1,
          );
          final actual = documentStructure == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final Object other = stubBackground;
          final actual = documentStructure == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final other = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final actual = documentStructure.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different frame durations', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [100],
            activeFrameIndex: 0,
          );
          final other = DocumentStructure(
            layers: [stubBackground],
            activeLayerIndex: 0,
            frameDurations: const [200],
            activeFrameIndex: 0,
          );
          final actual = documentStructure.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('counts', () {
          final documentStructure = DocumentStructure(
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
            frameDurations: const [100, 200, 300],
            activeFrameIndex: 2,
          );
          final actual = documentStructure.toString();
          const expected =
              'DocumentStructure(layers: 2, active: 1, frames: 3, frame: 2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
