import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/history/history.dart';

import '../../../support/history_entries.dart';

void main() {
  group('class History', () {
    group('factory forDocument', () {
      group('start thumbnail', () {
        test('small document', () {
          final history = History.forDocument(
            document: Document.blank(
              width: 2,
              height: 1,
              background: PixelColor.black,
            ),
          );
          final actual = [history.startThumbnail, history.position];
          final expected = [
            Layer.filled(width: 2, height: 1, color: PixelColor.black),
            0,
          ];
          expect(actual, equals(expected));
        });
        test('large document', () {
          final history = History.forDocument(
            document: Document.blank(
              width: 48,
              height: 24,
              background: PixelColor.black,
            ),
          );
          final actual = [history.startThumbnail, history.position];
          final expected = [
            Layer.filled(width: 24, height: 12, color: PixelColor.black),
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method record', () {
      group('entries', () {
        test('none', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = [history.position, history.entries];
          const expected = [0, []];
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          final actual = [history.position, history.entries];
          final expected = [
            2,
            [
              pixelEntry(name: 'Pen', x: 0, before: 0, after: 1),
              pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2),
            ],
          ];
          expect(actual, equals(expected));
        });
        test('after undo', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..undo()
            ..record(pixelEntry(name: 'Pen', x: 1, before: 0, after: 3));
          final actual = [history.position, history.entries];
          final expected = [
            2,
            [
              pixelEntry(name: 'Pen', x: 0, before: 0, after: 1),
              pixelEntry(name: 'Pen', x: 1, before: 0, after: 3),
            ],
          ];
          expect(actual, equals(expected));
        });
        test('after jump to start', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..jumpTo(0)
            ..record(pixelEntry(name: 'Pen', x: 1, before: 0, after: 3));
          final actual = [history.position, history.entries];
          final expected = [
            1,
            [pixelEntry(name: 'Pen', x: 1, before: 0, after: 3)],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method undo', () {
      group('positions', () {
        test('from end', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.undo();
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            1,
            Uint8List.fromList([1, 1, 1, 1, 0, 0, 0, 0]),
          ];
          expect(actual, equals(expected));
        });
        test('twice', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..undo()
            ..undo();
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            0,
            Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          ];
          expect(actual, equals(expected));
        });
        test('at start', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..jumpTo(0)
            ..undo();
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            0,
            Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method redo', () {
      group('positions', () {
        test('at end', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.redo();
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            2,
            Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
          ];
          expect(actual, equals(expected));
        });
        test('after undo', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..undo()
            ..redo();
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            2,
            Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
          ];
          expect(actual, equals(expected));
        });
        test('from start', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..jumpTo(0)
            ..redo();
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            1,
            Uint8List.fromList([1, 1, 1, 1, 0, 0, 0, 0]),
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method jumpTo', () {
      group('targets', () {
        test('start', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.jumpTo(0);
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            0,
            Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          ];
          expect(actual, equals(expected));
        });
        test('same', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.jumpTo(2);
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            2,
            Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
          ];
          expect(actual, equals(expected));
        });
        test('forward', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..jumpTo(0)
            ..jumpTo(2);
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            2,
            Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
          ];
          expect(actual, equals(expected));
        });
        test('before start', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.jumpTo(-1);
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            0,
            Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
          ];
          expect(actual, equals(expected));
        });
        test('beyond end', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history
            ..jumpTo(0)
            ..jumpTo(5);
          final actual = [history.position, document.layers.first.pixels.rgba];
          final expected = [
            2,
            Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter canUndo', () {
      group('positions', () {
        test('empty', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = history.canUndo;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('end', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          final actual = history.canUndo;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('start', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.jumpTo(0);
          final actual = history.canUndo;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter canRedo', () {
      group('positions', () {
        test('empty', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = history.canRedo;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('end', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          final actual = history.canRedo;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('middle', () {
          final document = Document(
            width: 2,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer(
                  width: 2,
                  height: 1,
                  rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.undo();
          final actual = history.canRedo;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter point', () {
      group('position', () {
        test('start', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = history.point;
          const HistoryPoint expected = (position: 0, entry: null);
          expect(actual, equals(expected));
        });
        test('after entry', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          history.record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          final actual = history.point;
          final HistoryPoint expected = (
            position: 1,
            entry: pixelEntry(name: 'Pen', x: 0, before: 0, after: 1),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('getter isAtSavedPoint', () {
      group('never marked', () {
        test('start', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = history.isAtSavedPoint;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('after entry', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          history.record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          final actual = history.isAtSavedPoint;
          const expected = false;
          expect(actual, equals(expected));
        });
      });

      group('marked', () {
        test('at point', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          history.record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          history.markSaved(history.point);
          final actual = history.isAtSavedPoint;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('entry after point', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          history.markSaved(history.point);
          history.record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          final actual = history.isAtSavedPoint;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('undo to point', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          history.record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          history.markSaved(history.point);
          history.record(pixelEntry(name: 'Pen', x: 1, before: 0, after: 1));
          history.undo();
          final actual = history.isAtSavedPoint;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('replaced entry at point', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          history.record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          history.markSaved(history.point);
          history.undo();
          history.record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          final actual = history.isAtSavedPoint;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
