import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/history/composite_history_entry.dart';

import '../../../support/document_probes.dart';
import '../../../support/history_entries.dart';

void main() {
  const transparent = 0x00000000;

  group('class CompositeHistoryEntry', () {
    group('method undo', () {
      group('order', () {
        test('entries in reverse', () {
          final document = filmDocument(
            frames: [
              [
                [transparent],
              ],
            ],
            activeFrameIndex: 0,
          );
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [
              pixelEntry(name: 'Pen', x: 0, before: 1, after: 2),
              pixelEntry(name: 'Pen', x: 0, before: 2, after: 3),
            ],
          );
          compositeHistoryEntry.undo(document);
          final actual = framePixelRows(document);
          const expected = [
            [
              [0x01010101],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method redo', () {
      group('order', () {
        test('entries in order', () {
          final document = filmDocument(
            frames: [
              [
                [transparent],
              ],
            ],
            activeFrameIndex: 0,
          );
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [
              pixelEntry(name: 'Pen', x: 0, before: 1, after: 2),
              pixelEntry(name: 'Pen', x: 0, before: 2, after: 3),
            ],
          );
          compositeHistoryEntry.redo(document);
          final actual = framePixelRows(document);
          const expected = [
            [
              [0x03030303],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final other = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final actual = compositeHistoryEntry == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });

      group('not equals', () {
        test('different name', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final other = CompositeHistoryEntry(
            name: 'Revert',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final actual = compositeHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different thumbnail', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final other = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.black,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final actual = compositeHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different entries', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final other = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 2)],
          );
          final actual = compositeHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final Object other = pixelEntry(
            name: 'Pen',
            x: 0,
            before: 0,
            after: 1,
          );
          final actual = compositeHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final other = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final actual = compositeHistoryEntry.hashCode;
          final expected = other.hashCode;
          expect(actual, equals(expected));
        });
      });

      group('not equals', () {
        test('different entries', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 1)],
          );
          final other = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [pixelEntry(name: 'Pen', x: 0, before: 0, after: 2)],
          );
          final actual = compositeHistoryEntry.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('format', () {
        test('name and entries', () {
          final compositeHistoryEntry = CompositeHistoryEntry(
            name: 'Layerize',
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.transparent,
            ),
            entries: [
              pixelEntry(name: 'Pen', x: 0, before: 0, after: 1),
              pixelEntry(name: 'Pen', x: 0, before: 1, after: 2),
            ],
          );
          final actual = compositeHistoryEntry.toString();
          const expected = 'CompositeHistoryEntry(Layerize, entries: 2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
