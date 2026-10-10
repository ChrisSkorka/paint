import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/history/layers_history_entry.dart';

void main() {
  final stubBackground = DocumentLayer(
    name: 'Background',
    pixels: Layer.filled(width: 1, height: 1, color: PixelColor.white),
  );
  final stubSketch = DocumentLayer(
    name: 'Sketch',
    pixels: Layer.filled(width: 1, height: 1, color: PixelColor.black),
  );
  final stubThumbnail = Layer.filled(
    width: 1,
    height: 1,
    color: PixelColor.transparent,
  );

  group('class LayersHistoryEntry', () {
    group('method undo', () {
      group('changes', () {
        test('added layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
          );
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          layersHistoryEntry.undo(document);
          final actual = [document.layers, document.activeLayerIndex];
          final expected = [
            [stubBackground],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('removed layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
          );
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Remove layer',
            layersBefore: [stubBackground, stubSketch],
            activeIndexBefore: 1,
            layersAfter: [stubBackground],
            activeIndexAfter: 0,
            thumbnail: stubThumbnail,
          );
          layersHistoryEntry.undo(document);
          final actual = [document.layers, document.activeLayerIndex];
          final expected = [
            [stubBackground, stubSketch],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('moved layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubSketch, stubBackground],
            activeLayerIndex: 1,
          );
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Move layer up',
            layersBefore: [stubBackground, stubSketch],
            activeIndexBefore: 0,
            layersAfter: [stubSketch, stubBackground],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          layersHistoryEntry.undo(document);
          final actual = [document.layers, document.activeLayerIndex];
          final expected = [
            [stubBackground, stubSketch],
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method redo', () {
      group('changes', () {
        test('added layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
          );
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          layersHistoryEntry.redo(document);
          final actual = [document.layers, document.activeLayerIndex];
          final expected = [
            [stubBackground, stubSketch],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('removed layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
          );
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Remove layer',
            layersBefore: [stubBackground, stubSketch],
            activeIndexBefore: 1,
            layersAfter: [stubBackground],
            activeIndexAfter: 0,
            thumbnail: stubThumbnail,
          );
          layersHistoryEntry.redo(document);
          final actual = [document.layers, document.activeLayerIndex];
          final expected = [
            [stubBackground],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('moved layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 0,
          );
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Move layer up',
            layersBefore: [stubBackground, stubSketch],
            activeIndexBefore: 0,
            layersAfter: [stubSketch, stubBackground],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          layersHistoryEntry.redo(document);
          final actual = [document.layers, document.activeLayerIndex];
          final expected = [
            [stubSketch, stubBackground],
            1,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different name', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Remove layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different layers before', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubSketch],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different active index before', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 1,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different layers after', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubSketch, stubBackground],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different active index after', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 0,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different thumbnail', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.white,
            ),
          );
          final actual = layersHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final Object other = stubThumbnail;
          final actual = layersHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different layers after', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final other = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubSketch, stubBackground],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('changes', () {
        test('added layer', () {
          final layersHistoryEntry = LayersHistoryEntry(
            name: 'Add layer',
            layersBefore: [stubBackground],
            activeIndexBefore: 0,
            layersAfter: [stubBackground, stubSketch],
            activeIndexAfter: 1,
            thumbnail: stubThumbnail,
          );
          final actual = layersHistoryEntry.toString();
          const expected = 'LayersHistoryEntry(Add layer, layers: 1 → 2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
