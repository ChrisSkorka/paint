import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/composite_history_entry.dart';
import 'package:paint/editor/history/document_structure.dart';
import 'package:paint/editor/history/history.dart';
import 'package:paint/editor/history/image_edit.dart';
import 'package:paint/editor/history/layer_snapshot.dart';
import 'package:paint/editor/history/multi_frame_history_entry.dart';
import 'package:paint/editor/history/structure_history_entry.dart';

import '../../../support/document_probes.dart';
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.undo();
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.redo();
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.jumpTo(0);
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.jumpTo(2);
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
              ),
            ],
            activeLayerIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Eraser', x: 1, before: 0, after: 2));
          history.jumpTo(-1);
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
          final actual = [
            history.position,
            document.layers.first.images.first.rgba,
          ];
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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
                images: [
                  Layer(
                    width: 2,
                    height: 1,
                    rgba: Uint8List.fromList([1, 1, 1, 1, 2, 2, 2, 2]),
                  ),
                ],
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

    group('getter imageEdits', () {
      group('entries', () {
        test('none', () {
          final history = History.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = history.imageEdits;
          const expected = <ImageEdit>[];
          expect(actual, equals(expected));
        });
        test('pixel', () {
          final document = Document.blank(width: 2, height: 1);
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 1, before: 0, after: 1));
          final actual = history.imageEdits;
          final expected = [
            ImageEdit(
              entryIndex: 0,
              image: document.layers[0].images[0],
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 1,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 1,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([1, 1, 1, 1]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('multi-frame', () {
          final document = filmDocument(
            frames: [
              [
                [0],
              ],
              [
                [0],
              ],
            ],
            activeFrameIndex: 0,
          );
          final history = History.forDocument(document: document)
            ..record(
              MultiFrameHistoryEntry(
                entries: [
                  pixelEntry(name: 'Paste', x: 0, before: 0, after: 1),
                  pixelEntry(
                    name: 'Paste',
                    x: 0,
                    before: 0,
                    after: 2,
                    frameIndex: 1,
                  ),
                ],
              ),
            );
          final actual = history.imageEdits;
          final expected = [
            ImageEdit(
              entryIndex: 0,
              image: document.layers[0].images[0],
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([1, 1, 1, 1]),
              ),
            ),
            ImageEdit(
              entryIndex: 0,
              image: document.layers[0].images[1],
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([2, 2, 2, 2]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('composite', () {
          final document = Document.blank(width: 2, height: 1);
          final image = document.layers[0].images[0];
          final before = DocumentStructure.capture(document: document);
          document.layers.insert(
            0,
            DocumentLayer(
              name: 'Below',
              images: [
                Layer.filled(width: 2, height: 1, color: PixelColor.black),
              ],
            ),
          );
          final history = History.forDocument(document: document)
            ..record(
              CompositeHistoryEntry(
                name: 'Layerize',
                thumbnail: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.transparent,
                ),
                entries: [
                  StructureHistoryEntry(
                    name: 'Add layer',
                    before: before,
                    after: DocumentStructure.capture(document: document),
                    thumbnail: Layer.filled(
                      width: 1,
                      height: 1,
                      color: PixelColor.transparent,
                    ),
                  ),
                  pixelEntry(
                    name: 'Pen',
                    x: 0,
                    before: 0,
                    after: 1,
                    layerIndex: 1,
                  ),
                ],
              ),
            );
          final actual = history.imageEdits;
          final expected = [
            ImageEdit(
              entryIndex: 0,
              image: image,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([1, 1, 1, 1]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
      });

      group('position', () {
        test('undone entry', () {
          final document = Document.blank(width: 2, height: 1);
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1))
            ..record(pixelEntry(name: 'Pen', x: 1, before: 0, after: 2))
            ..undo();
          final actual = history.imageEdits;
          final expected = [
            ImageEdit(
              entryIndex: 0,
              image: document.layers[0].images[0],
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([1, 1, 1, 1]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
      });

      group('structure', () {
        test('layer moved after edit', () {
          final document = layeredDocument(
            names: ['A', 'B'],
            activeLayerIndex: 0,
          );
          final image = document.layers[0].images[0];
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          final before = DocumentStructure.capture(document: document);
          document.layers.insert(1, document.layers.removeAt(0));
          history.record(
            StructureHistoryEntry(
              name: 'Move layer up',
              before: before,
              after: DocumentStructure.capture(document: document),
              thumbnail: Layer.filled(
                width: 1,
                height: 1,
                color: PixelColor.transparent,
              ),
            ),
          );
          final actual = history.imageEdits;
          final expected = [
            ImageEdit(
              entryIndex: 0,
              image: image,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([1, 1, 1, 1]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('layer removed after edit', () {
          final document = layeredDocument(
            names: ['A', 'B'],
            activeLayerIndex: 0,
          );
          final image = document.layers[0].images[0];
          final history = History.forDocument(document: document)
            ..record(pixelEntry(name: 'Pen', x: 0, before: 0, after: 1));
          final before = DocumentStructure.capture(document: document);
          document.layers.removeAt(0);
          history.record(
            StructureHistoryEntry(
              name: 'Remove layer',
              before: before,
              after: DocumentStructure.capture(document: document),
              thumbnail: Layer.filled(
                width: 1,
                height: 1,
                color: PixelColor.transparent,
              ),
            ),
          );
          final actual = history.imageEdits;
          final expected = [
            ImageEdit(
              entryIndex: 0,
              image: image,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([1, 1, 1, 1]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('layer added before edit', () {
          final document = layeredDocument(names: ['A'], activeLayerIndex: 0);
          final image = document.layers[0].images[0];
          final before = DocumentStructure.capture(document: document);
          document.layers.insert(
            0,
            DocumentLayer(
              name: 'B',
              images: [
                Layer.filled(width: 2, height: 1, color: PixelColor.black),
              ],
            ),
          );
          final history = History.forDocument(document: document)
            ..record(
              StructureHistoryEntry(
                name: 'Add layer',
                before: before,
                after: DocumentStructure.capture(document: document),
                thumbnail: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.transparent,
                ),
              ),
            )
            ..record(
              pixelEntry(name: 'Pen', x: 0, before: 0, after: 1, layerIndex: 1),
            );
          final actual = history.imageEdits;
          final expected = [
            ImageEdit(
              entryIndex: 1,
              image: image,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([1, 1, 1, 1]),
              ),
            ),
          ];
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
