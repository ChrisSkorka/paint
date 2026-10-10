import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/history/document_structure.dart';
import 'package:paint/editor/history/structure_history_entry.dart';

void main() {
  final stubBackground = DocumentLayer(
    name: 'Background',
    images: [Layer.filled(width: 1, height: 1, color: PixelColor.white)],
  );
  final stubSketch = DocumentLayer(
    name: 'Sketch',
    images: [Layer.filled(width: 1, height: 1, color: PixelColor.black)],
  );
  final stubThumbnail = Layer.filled(
    width: 1,
    height: 1,
    color: PixelColor.transparent,
  );
  final stubBefore = DocumentStructure(
    layers: [stubBackground],
    activeLayerIndex: 0,
    frameHolds: const [1],
    fps: 10,
    activeFrameIndex: 0,
  );
  final stubAfter = DocumentStructure(
    layers: [stubBackground, stubSketch],
    activeLayerIndex: 1,
    frameHolds: const [1, 2],
    fps: 10,
    activeFrameIndex: 1,
  );

  group('class StructureHistoryEntry', () {
    group('method undo', () {
      group('document', () {
        test('restores before', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
            frameHolds: [1, 2],
            fps: 10,
            activeFrameIndex: 1,
          );
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          structureHistoryEntry.undo(document);
          final actual = document;
          final expected = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('method redo', () {
      group('document', () {
        test('restores after', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [stubBackground],
            activeLayerIndex: 0,
          );
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          structureHistoryEntry.redo(document);
          final actual = document;
          final expected = Document(
            width: 1,
            height: 1,
            layers: [stubBackground, stubSketch],
            activeLayerIndex: 1,
            frameHolds: [1, 2],
            fps: 10,
            activeFrameIndex: 1,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final other = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: Layer.copyOf(stubThumbnail),
          );
          final actual = structureHistoryEntry == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different name', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final other = StructureHistoryEntry(
            name: 'Add frame',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final actual = structureHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different before', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final other = StructureHistoryEntry(
            name: 'Add layer',
            before: stubAfter,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final actual = structureHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different after', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final other = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubBefore,
            thumbnail: stubThumbnail,
          );
          final actual = structureHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different thumbnail', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final other = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: Layer.filled(
              width: 1,
              height: 1,
              color: PixelColor.white,
            ),
          );
          final actual = structureHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final Object other = stubBefore;
          final actual = structureHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final other = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: Layer.copyOf(stubThumbnail),
          );
          final actual = structureHistoryEntry.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different name', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final other = StructureHistoryEntry(
            name: 'Add frame',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final actual = structureHistoryEntry.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('counts', () {
          final structureHistoryEntry = StructureHistoryEntry(
            name: 'Add layer',
            before: stubBefore,
            after: stubAfter,
            thumbnail: stubThumbnail,
          );
          final actual = structureHistoryEntry.toString();
          const expected =
              'StructureHistoryEntry(Add layer, layers: 1 → 2, frames: 1 → 2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
