import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/history_entry.dart';
import 'package:paint/editor/history/layer_snapshot.dart';

void main() {
  group('class HistoryEntry', () {
    group('method undo', () {
      group('layers', () {
        test('first layer', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [Layer(width: 2, height: 1, rgba: Uint8List(8))],
            activeLayerIndex: 0,
          );
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          historyEntry.undo(document);
          final actual = document.layers.first.rgba;
          final expected = Uint8List.fromList([0, 0, 0, 0, 1, 2, 3, 4]);
          expect(actual, equals(expected));
        });
        test('second layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              Layer(width: 1, height: 1, rgba: Uint8List(4)),
              Layer(width: 1, height: 1, rgba: Uint8List(4)),
            ],
            activeLayerIndex: 0,
          );
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 1,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          historyEntry.undo(document);
          final actual = [for (final layer in document.layers) layer.rgba];
          final expected = [
            Uint8List(4),
            Uint8List.fromList([1, 2, 3, 4]),
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method redo', () {
      group('layers', () {
        test('first layer', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [Layer(width: 2, height: 1, rgba: Uint8List(8))],
            activeLayerIndex: 0,
          );
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          historyEntry.redo(document);
          final actual = document.layers.first.rgba;
          final expected = Uint8List.fromList([5, 6, 7, 8, 0, 0, 0, 0]);
          expect(actual, equals(expected));
        });
        test('second layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              Layer(width: 1, height: 1, rgba: Uint8List(4)),
              Layer(width: 1, height: 1, rgba: Uint8List(4)),
            ],
            activeLayerIndex: 0,
          );
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 1,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          historyEntry.redo(document);
          final actual = [for (final layer in document.layers) layer.rgba];
          final expected = [
            Uint8List(4),
            Uint8List.fromList([5, 6, 7, 8]),
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different name', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Eraser',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different layer', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Pen',
            layerIndex: 1,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different before', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([9, 9, 9, 9]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different thumbnail', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.black,
            ),
          );
          final actual = historyEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different after', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([9, 9, 9, 9]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different name', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final other = HistoryEntry(
            name: 'Eraser',
            layerIndex: 0,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([1, 2, 3, 4]),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              rgba: Uint8List.fromList([5, 6, 7, 8]),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('format', () {
        test('name and layer', () {
          final historyEntry = HistoryEntry(
            name: 'Pen',
            layerIndex: 2,
            before: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 0, height: 0),
              rgba: Uint8List(0),
            ),
            after: LayerSnapshot(
              area: const PixelRectangle(left: 0, top: 0, width: 0, height: 0),
              rgba: Uint8List(0),
            ),
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
          );
          final actual = historyEntry.toString();
          const expected = 'HistoryEntry(Pen, layer: 2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
