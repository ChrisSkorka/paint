import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/document_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/editor_controller.dart';
import 'package:paint/editor/history/layer_snapshot.dart';
import 'package:paint/editor/history/pixel_history_entry.dart';
import 'package:paint/editor/pointer_button.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/tool_kind.dart';

import '../../support/document_probes.dart';
import '../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;
  const white = 0xFFFFFFFF;
  const red = 0xFFFF0000;
  const grey = 0x88888888;

  group('class EditorController', () {
    group('factory forDocument', () {
      group('layers', () {
        test('blank pointer layer', () {
          final document = Document.blank(width: 3, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          final actual = [
            editorController.document,
            editorController.pointerLayer,
          ];
          final expected = [
            Document.blank(width: 3, height: 2),
            Layer.filled(width: 3, height: 2, color: PixelColor.transparent),
          ];
          expect(actual, equals(expected));
        });
      });
      group('history', () {
        test('empty', () {
          final document = Document.blank(width: 3, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          final actual = [
            identical(editorController.history.document, document),
            editorController.history.entries,
            editorController.history.position,
          ];
          const expected = [true, [], 0];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter visibleLayers', () {
      group('layers', () {
        test('document then pointer', () {
          final document = Document.blank(width: 3, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          final actual = editorController.visibleLayers;
          final expected = [
            DocumentLayer(name: 'Background', pixels: document.activeLayer),
            DocumentLayer(
              name: 'Pointer',
              pixels: editorController.pointerLayer,
            ),
          ];
          expect(actual, equals(expected));
        });
      });
      group('visibility', () {
        test('hidden layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.white,
                ),
                visible: false,
              ),
              DocumentLayer(
                name: 'Sketch',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          final actual = [
            for (final layer in editorController.visibleLayers) layer.name,
          ];
          const expected = ['Sketch', 'Pointer'];
          expect(actual, equals(expected));
        });
        test('translucent layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.white,
                ),
                opacity: 0,
              ),
            ],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          final actual = [
            for (final layer in editorController.visibleLayers) layer.name,
          ];
          const expected = ['Background', 'Pointer'];
          expect(actual, equals(expected));
        });
      });
    });

    group('method selectTool', () {
      group('tools', () {
        test('eraser', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.selectTool(ToolKind.eraser);
          final actual = [editorController.toolKind, notifications];
          const expected = [ToolKind.eraser, 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('method setPenSize', () {
      group('sizes', () {
        test('larger', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setPenSize(3);
          final actual = [editorController.penSize, notifications];
          const expected = [3, 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('method setPenTip', () {
      group('tips', () {
        test('circle', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setPenTip(BrushTip.circle);
          final actual = [editorController.penTip, notifications];
          const expected = [BrushTip.circle, 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('method setEraserSize', () {
      group('sizes', () {
        test('larger', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setEraserSize(5);
          final actual = [editorController.eraserSize, notifications];
          const expected = [5, 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('method setShapeWidth', () {
      group('widths', () {
        test('larger', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setShapeWidth(3);
          final actual = [editorController.shapeWidth, notifications];
          const expected = [3, 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('method setLayerVisibility', () {
      group('visibility', () {
        test('hide', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setLayerVisibility(index: 0, visible: false);
          final actual = [document.layers.first.visible, notifications];
          const expected = [false, 1];
          expect(actual, equals(expected));
        });
        test('show', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerVisibility(index: 0, visible: false);
          editorController.setLayerVisibility(index: 0, visible: true);
          final actual = document.layers.first.visible;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('index', () {
        test('second layer', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.white,
                ),
              ),
              DocumentLayer(
                name: 'Sketch',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerVisibility(index: 1, visible: false);
          final actual = [for (final layer in document.layers) layer.visible];
          const expected = [true, false];
          expect(actual, equals(expected));
        });
      });
      group('history', () {
        test('recorded', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerVisibility(index: 0, visible: false);
          editorController.setLayerVisibility(index: 0, visible: true);
          final actual = editorController.history.entries.map(
            (entry) => entry.name,
          );
          const expected = ['Hide layer', 'Show layer'];
          expect(actual, equals(expected));
        });
        test('undo', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerVisibility(index: 0, visible: false);
          editorController.undo();
          final actual = document.layers.first.visible;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('redo', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerVisibility(index: 0, visible: false);
          editorController.undo();
          editorController.redo();
          final actual = document.layers.first.visible;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
      group('thumbnail', () {
        test('changed layer not active', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.white,
                ),
              ),
              DocumentLayer(
                name: 'Sketch',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerVisibility(index: 1, visible: false);
          final actual = editorController.history.entries.single.thumbnail;
          final expected = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          expect(actual, equals(expected));
        });
      });
      group('selection', () {
        test('kept', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectAll();
          editorController.setLayerVisibility(index: 0, visible: false);
          final actual = editorController.selectionArea;
          const expected = PixelRectangle(left: 0, top: 0, width: 2, height: 1);
          expect(actual, equals(expected));
        });
      });
      group('stroke', () {
        test('during stroke', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.setLayerVisibility(index: 0, visible: false);
          final actual = [
            document.layers.first.visible,
            editorController.history.entries.length,
          ];
          const expected = [true, 0];
          expect(actual, equals(expected));
        });
      });
    });

    group('method previewLayerOpacity', () {
      group('opacity', () {
        test('partial', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.previewLayerOpacity(index: 0, opacity: 40);
          final actual = [
            document.layers.first.opacity,
            editorController.history.entries.length,
            notifications,
          ];
          const expected = [40, 0, 1];
          expect(actual, equals(expected));
        });
        test('repeated', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.previewLayerOpacity(index: 0, opacity: 40);
          editorController.previewLayerOpacity(index: 0, opacity: 20);
          final actual = [
            document.layers.first.opacity,
            editorController.history.entries.length,
          ];
          const expected = [20, 0];
          expect(actual, equals(expected));
        });
      });
      group('index', () {
        test('second layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.previewLayerOpacity(index: 1, opacity: 25);
          final actual = [for (final layer in document.layers) layer.opacity];
          const expected = [100, 25];
          expect(actual, equals(expected));
        });
      });
    });

    group('method setLayerOpacity', () {
      group('opacity', () {
        test('without preview', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setLayerOpacity(index: 0, opacity: 40);
          final actual = [
            document.layers.first.opacity,
            editorController.history.entries.map((entry) => entry.name),
            notifications,
          ];
          const expected = [
            40,
            ['Layer opacity'],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('after preview', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.previewLayerOpacity(index: 0, opacity: 60);
          editorController.previewLayerOpacity(index: 0, opacity: 40);
          editorController.setLayerOpacity(index: 0, opacity: 40);
          final actual = [
            document.layers.first.opacity,
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            40,
            ['Layer opacity'],
          ];
          expect(actual, equals(expected));
        });
        test('unchanged', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setLayerOpacity(index: 0, opacity: 100);
          final actual = [
            document.layers.first.opacity,
            editorController.history.entries.length,
            notifications,
          ];
          const expected = [100, 0, 1];
          expect(actual, equals(expected));
        });
        test('preview back to start', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.previewLayerOpacity(index: 0, opacity: 60);
          editorController.setLayerOpacity(index: 0, opacity: 100);
          final actual = [
            document.layers.first.opacity,
            editorController.history.entries.length,
          ];
          const expected = [100, 0];
          expect(actual, equals(expected));
        });
      });
      group('index', () {
        test('second layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerOpacity(index: 1, opacity: 25);
          final actual = [for (final layer in document.layers) layer.opacity];
          const expected = [100, 25];
          expect(actual, equals(expected));
        });
      });
      group('history', () {
        test('undo after preview', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.previewLayerOpacity(index: 0, opacity: 60);
          editorController.setLayerOpacity(index: 0, opacity: 30);
          editorController.undo();
          final actual = document.layers.first.opacity;
          const expected = 100;
          expect(actual, equals(expected));
        });
        test('redo', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerOpacity(index: 0, opacity: 30);
          editorController.undo();
          editorController.redo();
          final actual = document.layers.first.opacity;
          const expected = 30;
          expect(actual, equals(expected));
        });
        test('separate drags', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.previewLayerOpacity(index: 0, opacity: 60);
          editorController.setLayerOpacity(index: 0, opacity: 60);
          editorController.previewLayerOpacity(index: 0, opacity: 20);
          editorController.setLayerOpacity(index: 0, opacity: 20);
          editorController.undo();
          final actual = [
            document.layers.first.opacity,
            editorController.history.entries.length,
          ];
          const expected = [60, 2];
          expect(actual, equals(expected));
        });
        test('preview discarded by undo', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerOpacity(index: 0, opacity: 60);
          editorController.previewLayerOpacity(index: 0, opacity: 20);
          editorController.undo();
          editorController.setLayerOpacity(index: 0, opacity: 50);
          editorController.undo();
          final actual = document.layers.first.opacity;
          const expected = 100;
          expect(actual, equals(expected));
        });
      });
      group('thumbnail', () {
        test('changed layer not active', () {
          final document = Document(
            width: 1,
            height: 1,
            layers: [
              DocumentLayer(
                name: 'Background',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.white,
                ),
              ),
              DocumentLayer(
                name: 'Sketch',
                pixels: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
              ),
            ],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerOpacity(index: 1, opacity: 40);
          final actual = editorController.history.entries.single.thumbnail;
          final expected = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          expect(actual, equals(expected));
        });
      });
      group('pixels', () {
        test('drawing after opacity change', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setLayerOpacity(index: 0, opacity: 50);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = [
            document.layers.first.pixels.getPixel(const PixelPoint(x: 0, y: 0)),
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            PixelColor.black,
            ['Layer opacity', 'Pen'],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter canRemoveLayer', () {
      group('layer count', () {
        test('one', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background'],
              activeLayerIndex: 0,
            ),
          );
          final actual = editorController.canRemoveLayer;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('multiple', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background', 'Sketch'],
              activeLayerIndex: 0,
            ),
          );
          final actual = editorController.canRemoveLayer;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter canMoveLayerUp', () {
      group('active layer', () {
        test('only', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background'],
              activeLayerIndex: 0,
            ),
          );
          final actual = editorController.canMoveLayerUp;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('bottom', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background', 'Sketch'],
              activeLayerIndex: 0,
            ),
          );
          final actual = editorController.canMoveLayerUp;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('top', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background', 'Sketch'],
              activeLayerIndex: 1,
            ),
          );
          final actual = editorController.canMoveLayerUp;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter canMoveLayerDown', () {
      group('active layer', () {
        test('only', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background'],
              activeLayerIndex: 0,
            ),
          );
          final actual = editorController.canMoveLayerDown;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('bottom', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background', 'Sketch'],
              activeLayerIndex: 0,
            ),
          );
          final actual = editorController.canMoveLayerDown;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('top', () {
          final editorController = EditorController.forDocument(
            document: layeredDocument(
              names: ['Background', 'Sketch'],
              activeLayerIndex: 1,
            ),
          );
          final actual = editorController.canMoveLayerDown;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('method selectLayer', () {
      group('index', () {
        test('other layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.selectLayer(1);
          final actual = [
            layerStructure(document),
            editorController.history.entries.length,
            notifications,
          ];
          const expected = [
            [
              ['Background', 'Sketch'],
              1,
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
      });
      group('drawing', () {
        test('selected layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectLayer(0);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = [
            for (final layer in document.layers) pixelRows(layer.pixels),
          ];
          const expected = [
            [
              [black, transparent],
            ],
            [
              [transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
      group('selection', () {
        test('cleared', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectAll();
          editorController.selectLayer(1);
          final actual = editorController.selectionArea;
          const expected = null;
          expect(actual, equals(expected));
        });
      });
      group('stroke', () {
        test('during stroke', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.selectLayer(1);
          final actual = document.activeLayerIndex;
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
    });

    group('method addLayer', () {
      group('position', () {
        test('above only layer', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.addLayer();
          final actual = [
            layerStructure(document),
            pixelRows(document.activeLayer),
            notifications,
          ];
          const expected = [
            [
              ['Background', 'Layer 2'],
              1,
            ],
            [
              [transparent, transparent],
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('above middle layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch', 'Ink'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.addLayer();
          final actual = layerStructure(document);
          const expected = [
            ['Background', 'Sketch', 'Layer 4', 'Ink'],
            2,
          ];
          expect(actual, equals(expected));
        });
      });
      group('names', () {
        test('two additions', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.addLayer();
          editorController.addLayer();
          final actual = layerStructure(document);
          const expected = [
            ['Background', 'Layer 2', 'Layer 3'],
            2,
          ];
          expect(actual, equals(expected));
        });
        test('after removal', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.addLayer();
          editorController.removeLayer();
          editorController.addLayer();
          final actual = layerStructure(document);
          const expected = [
            ['Background', 'Layer 3'],
            1,
          ];
          expect(actual, equals(expected));
        });
      });
      group('history', () {
        test('recorded', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.addLayer();
          final actual = editorController.history.entries.map(
            (entry) => entry.name,
          );
          const expected = ['Add layer'];
          expect(actual, equals(expected));
        });
        test('undo', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.addLayer();
          editorController.undo();
          final actual = layerStructure(document);
          const expected = [
            ['Background'],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('redo', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.addLayer();
          editorController.undo();
          editorController.redo();
          final actual = layerStructure(document);
          const expected = [
            ['Background', 'Layer 2'],
            1,
          ];
          expect(actual, equals(expected));
        });
      });
      group('selection', () {
        test('cleared', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectAll();
          editorController.addLayer();
          final actual = editorController.selectionArea;
          const expected = null;
          expect(actual, equals(expected));
        });
      });
      group('stroke', () {
        test('during stroke', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.addLayer();
          final actual = [
            layerStructure(document),
            editorController.history.entries.length,
          ];
          const expected = [
            [
              ['Background'],
              0,
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method removeLayer', () {
      group('position', () {
        test('top layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.removeLayer();
          final actual = [layerStructure(document), notifications];
          const expected = [
            [
              ['Background'],
              0,
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('bottom layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.removeLayer();
          final actual = layerStructure(document);
          const expected = [
            ['Sketch'],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('middle layer', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch', 'Ink'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.removeLayer();
          final actual = layerStructure(document);
          const expected = [
            ['Background', 'Ink'],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('only layer', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.removeLayer();
          final actual = [
            layerStructure(document),
            editorController.history.entries.length,
            notifications,
          ];
          const expected = [
            [
              ['Background'],
              0,
            ],
            0,
            0,
          ];
          expect(actual, equals(expected));
        });
      });
      group('history', () {
        test('recorded', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.removeLayer();
          final actual = editorController.history.entries.map(
            (entry) => entry.name,
          );
          const expected = ['Remove layer'];
          expect(actual, equals(expected));
        });
        test('undo', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.removeLayer();
          editorController.undo();
          final actual = layerStructure(document);
          const expected = [
            ['Background', 'Sketch'],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('undo restores pixels', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          editorController.removeLayer();
          editorController.undo();
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method moveLayer', () {
      group('direction', () {
        test('up', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.moveLayer(up: true);
          final actual = [layerStructure(document), notifications];
          const expected = [
            [
              ['Sketch', 'Background'],
              1,
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('down', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.moveLayer(up: false);
          final actual = layerStructure(document);
          const expected = [
            ['Sketch', 'Background'],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('up from top', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.moveLayer(up: true);
          final actual = [
            layerStructure(document),
            editorController.history.entries.length,
          ];
          const expected = [
            [
              ['Background', 'Sketch'],
              1,
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('down from bottom', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.moveLayer(up: false);
          final actual = [
            layerStructure(document),
            editorController.history.entries.length,
          ];
          const expected = [
            [
              ['Background', 'Sketch'],
              0,
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
      });
      group('history', () {
        test('recorded', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch', 'Ink'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.moveLayer(up: true);
          editorController.moveLayer(up: false);
          final actual = editorController.history.entries.map(
            (entry) => entry.name,
          );
          const expected = ['Move layer up', 'Move layer down'];
          expect(actual, equals(expected));
        });
        test('undo', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 0,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.moveLayer(up: true);
          editorController.undo();
          final actual = layerStructure(document);
          const expected = [
            ['Background', 'Sketch'],
            0,
          ];
          expect(actual, equals(expected));
        });
        test('undo stroke after move', () {
          final document = layeredDocument(
            names: ['Background', 'Sketch'],
            activeLayerIndex: 1,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.moveLayer(up: false);
          editorController.jumpToHistory(0);
          final actual = [
            layerStructure(document),
            for (final layer in document.layers) pixelRows(layer.pixels),
          ];
          const expected = [
            [
              ['Background', 'Sketch'],
              1,
            ],
            [
              [transparent, transparent],
            ],
            [
              [transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method setZoom', () {
      group('levels', () {
        test('larger', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.setZoom(8);
          final actual = [editorController.zoom, notifications];
          const expected = [8, 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('method editPrimary', () {
      group('slots', () {
        test('secondary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.editPrimary(primary: false);
          final actual = [editorController.editingPrimary, notifications];
          const expected = [false, 1];
          expect(actual, equals(expected));
        });
        test('primary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          editorController.editPrimary(primary: false);
          editorController.editPrimary(primary: true);
          final actual = editorController.editingPrimary;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('method selectColor', () {
      group('slots', () {
        test('primary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.selectColor(const PixelColor(argb: red));
          final actual = [
            editorController.primaryColor,
            editorController.secondaryColor,
            notifications,
          ];
          const expected = [PixelColor(argb: red), PixelColor.white, 1];
          expect(actual, equals(expected));
        });
        test('secondary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          editorController.editPrimary(primary: false);
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.selectColor(const PixelColor(argb: red));
          final actual = [
            editorController.primaryColor,
            editorController.secondaryColor,
            notifications,
          ];
          const expected = [PixelColor.black, PixelColor(argb: red), 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter editedColor', () {
      group('slots', () {
        test('primary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 1, height: 1),
          );
          final actual = editorController.editedColor;
          const expected = PixelColor.black;
          expect(actual, equals(expected));
        });
        test('secondary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 1, height: 1),
          );
          editorController.editPrimary(primary: false);
          final actual = editorController.editedColor;
          const expected = PixelColor.white;
          expect(actual, equals(expected));
        });
      });
    });

    group('method undo', () {
      group('history', () {
        test('after stroke', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.undo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('after two strokes', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.undo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [black, transparent, transparent],
            ],
            1,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('empty', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.undo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('during stroke', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.undo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [black, black, transparent],
            ],
            1,
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method redo', () {
      group('history', () {
        test('after undo', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.undo();
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.redo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [black, transparent, transparent],
            ],
            1,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('at end', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.redo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [black, transparent, transparent],
            ],
            1,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('during stroke', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.undo();
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.redo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [transparent, black, transparent],
            ],
            0,
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method jumpToHistory', () {
      group('positions', () {
        test('start', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.jumpToHistory(0);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            0,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('end', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          editorController.jumpToHistory(0);
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.jumpToHistory(2);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [black, black, transparent],
            ],
            2,
            1,
          ];
          expect(actual, equals(expected));
        });
        test('during stroke', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.jumpToHistory(0);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.position,
            notifications,
          ];
          const expected = [
            [
              [black, black, transparent],
            ],
            1,
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method pointerDown', () {
      group('buttons', () {
        test('primary', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('secondary', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.secondary,
          );
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, white, transparent],
          ];
          expect(actual, equals(expected));
        });
      });

      group('tools', () {
        test('pen size', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setPenSize(2);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('pen tip', () {
          final document = Document.blank(width: 4, height: 4);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.setPenSize(4);
          editorController.setPenTip(BrushTip.circle);
          editorController.pointerDown(
            point: const PixelPoint(x: 2, y: 2),
            button: PointerButton.primary,
          );
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black, black, transparent],
            [black, black, black, black],
            [black, black, black, black],
            [transparent, black, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('eraser', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.eraser);
          editorController.setEraserSize(2);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent, black],
          ];
          expect(actual, equals(expected));
        });
        test('bucket fill', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.bucketFill);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black],
          ];
          expect(actual, equals(expected));
        });
        test('shape', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.line);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = [
            pixelRows(document.activeLayer),
            pixelRows(editorController.pointerLayer),
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            [
              [transparent, black, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('color picker', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = [
            pixelRows(document.activeLayer),
            pixelRows(editorController.pointerLayer),
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            [
              [transparent, transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('color picker', () {
        test('primary sample', () {
          final document = Document.blank(
            width: 2,
            height: 1,
            background: const PixelColor(argb: red),
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = [
            editorController.primaryColor,
            editorController.secondaryColor,
          ];
          const expected = [PixelColor(argb: red), PixelColor.white];
          expect(actual, equals(expected));
        });
        test('secondary sample', () {
          final document = Document.blank(
            width: 2,
            height: 1,
            background: const PixelColor(argb: red),
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.secondary,
          );
          final actual = [
            editorController.primaryColor,
            editorController.secondaryColor,
          ];
          const expected = [PixelColor.black, PixelColor(argb: red)];
          expect(actual, equals(expected));
        });
        test('transparent sample', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          final actual = [
            editorController.primaryColor,
            editorController.secondaryColor,
          ];
          const expected = [PixelColor.transparent, PixelColor.white];
          expect(actual, equals(expected));
        });
        test('outside layer', () {
          final document = Document.blank(
            width: 2,
            height: 1,
            background: const PixelColor(argb: red),
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 2, y: 0),
            button: PointerButton.primary,
          );
          final actual = [
            editorController.primaryColor,
            editorController.secondaryColor,
          ];
          const expected = [PixelColor.black, PixelColor.white];
          expect(actual, equals(expected));
        });
      });

      group('recent colors', () {
        test('none', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = editorController.recentColors;
          const expected = <PixelColor>[];
          expect(actual, equals(expected));
        });
        test('pen primary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          final actual = editorController.recentColors;
          const expected = [PixelColor.black];
          expect(actual, equals(expected));
        });
        test('pen secondary', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.secondary,
          );
          final actual = editorController.recentColors;
          const expected = [PixelColor.white];
          expect(actual, equals(expected));
        });
        test('newest first', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.secondary,
          );
          final actual = editorController.recentColors;
          const expected = [PixelColor.white, PixelColor.black];
          expect(actual, equals(expected));
        });
        test('repeated color', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.secondary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          final actual = editorController.recentColors;
          const expected = [PixelColor.black, PixelColor.white];
          expect(actual, equals(expected));
        });
        test('limit', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          for (var argb = 0xFF000001; argb <= 0xFF000006; argb++) {
            editorController.selectColor(PixelColor(argb: argb));
            editorController.pointerDown(
              point: const PixelPoint(x: 0, y: 0),
              button: PointerButton.primary,
            );
            editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          }
          final actual = editorController.recentColors;
          const expected = [
            PixelColor(argb: 0xFF000006),
            PixelColor(argb: 0xFF000005),
            PixelColor(argb: 0xFF000004),
            PixelColor(argb: 0xFF000003),
            PixelColor(argb: 0xFF000002),
          ];
          expect(actual, equals(expected));
        });
        test('eraser', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.eraser);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          final actual = editorController.recentColors;
          const expected = <PixelColor>[];
          expect(actual, equals(expected));
        });
        test('bucket fill', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.bucketFill);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          final actual = editorController.recentColors;
          const expected = [PixelColor.black];
          expect(actual, equals(expected));
        });
        test('shape', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.rectangle);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          final actual = editorController.recentColors;
          const expected = [PixelColor.black];
          expect(actual, equals(expected));
        });
        test('select', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          final actual = editorController.recentColors;
          const expected = <PixelColor>[];
          expect(actual, equals(expected));
        });
        test('color picker', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          final actual = editorController.recentColors;
          const expected = <PixelColor>[];
          expect(actual, equals(expected));
        });
      });

      group('pointer', () {
        test('stroke color', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.secondary,
          );
          final actual = [
            pixelRows(editorController.pointerLayer),
            editorController.cursor,
            notifications,
          ];
          const expected = [
            [
              [transparent, white, transparent],
            ],
            PixelPoint(x: 1, y: 0),
            1,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method pointerMove', () {
      group('hover', () {
        test('pointer drawn', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          final actual = [
            pixelRows(document.activeLayer),
            pixelRows(editorController.pointerLayer),
            editorController.cursor,
            notifications,
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            [
              [transparent, black, transparent],
            ],
            PixelPoint(x: 1, y: 0),
            1,
          ];
          expect(actual, equals(expected));
        });
        test('pointer moved', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.pointerMove(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          final actual = pixelRows(editorController.pointerLayer);
          const expected = [
            [transparent, transparent, black],
          ];
          expect(actual, equals(expected));
        });
        test('eraser pointer', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.selectTool(ToolKind.eraser);
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          final actual = pixelRows(editorController.pointerLayer);
          const expected = [
            [transparent, grey, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('bucket fill pointer', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.selectTool(ToolKind.bucketFill);
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          final actual = pixelRows(editorController.pointerLayer);
          const expected = [
            [transparent, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('color picker', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.pointerMove(point: const PixelPoint(x: 0, y: 0));
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          final actual = [
            pixelRows(editorController.pointerLayer),
            editorController.cursor,
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            PixelPoint(x: 1, y: 0),
          ];
          expect(actual, equals(expected));
        });
      });

      group('cursor', () {
        test('outside', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          editorController.pointerMove(point: const PixelPoint(x: 3, y: 0));
          final actual = editorController.cursor;
          const expected = null;
          expect(actual, equals(expected));
        });
      });

      group('stroke', () {
        test('primary line', () {
          final document = Document.blank(width: 4, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          final actual = [
            pixelRows(document.activeLayer),
            pixelRows(editorController.pointerLayer),
            notifications,
          ];
          const expected = [
            [
              [black, black, black, transparent],
            ],
            [
              [transparent, transparent, black, transparent],
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('secondary line', () {
          final document = Document.blank(width: 4, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.secondary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          final actual = [
            pixelRows(document.activeLayer),
            pixelRows(editorController.pointerLayer),
          ];
          const expected = [
            [
              [white, white, white, transparent],
            ],
            [
              [transparent, transparent, white, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('continued line', () {
          final document = Document.blank(width: 4, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 1));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black, transparent],
            [transparent, transparent, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('bucket fill drag', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.bucketFill);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 2, y: 0),
            color: PixelColor.transparent,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('shape preview', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.rectangle);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 2));
          final actual = [
            pixelRows(document.activeLayer),
            pixelRows(editorController.pointerLayer),
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
              [transparent, transparent, transparent],
              [transparent, transparent, transparent],
            ],
            [
              [black, black, black],
              [black, transparent, black],
              [black, black, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('shape preview shrinks', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 3),
          );
          editorController.selectTool(ToolKind.rectangle);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 2));
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          final actual = pixelRows(editorController.pointerLayer);
          const expected = [
            [black, black, transparent],
            [transparent, transparent, transparent],
            [transparent, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('color picker', () {
          final document = Document.blank(width: 4, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent, transparent, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('color picker drag', () {
          final layer = Layer.filled(
            width: 2,
            height: 1,
            color: const PixelColor(argb: red),
          );
          layer.setPixel(
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.white,
          );
          final editorController = EditorController.forDocument(
            document: Document(
              width: 2,
              height: 1,
              layers: [DocumentLayer(name: 'Background', pixels: layer)],
              activeLayerIndex: 0,
            ),
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.secondary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          final actual = [
            editorController.primaryColor,
            editorController.secondaryColor,
          ];
          const expected = [PixelColor.black, PixelColor.white];
          expect(actual, equals(expected));
        });
      });
    });

    group('method pointerUp', () {
      group('stroke', () {
        test('ends stroke', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          final actual = [pixelRows(document.activeLayer), notifications];
          const expected = [
            [
              [black, transparent, transparent],
            ],
            2,
          ];
          expect(actual, equals(expected));
        });
        test('line', () {
          final document = Document.blank(width: 3, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.line);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 1));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, transparent, transparent],
            [transparent, black, black],
          ];
          expect(actual, equals(expected));
        });
        test('rectangle', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.rectangle);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 2));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 2));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, black],
            [black, transparent, black],
            [black, black, black],
          ];
          expect(actual, equals(expected));
        });
        test('circle', () {
          final document = Document.blank(width: 5, height: 5);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.circle);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 4, y: 4));
          editorController.pointerUp(point: const PixelPoint(x: 4, y: 4));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, black, black, black, transparent],
            [black, transparent, transparent, transparent, black],
            [black, transparent, transparent, transparent, black],
            [black, transparent, transparent, transparent, black],
            [transparent, black, black, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('arrow', () {
          final document = Document.blank(width: 5, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.arrow);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 1),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 4, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 4, y: 1));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [transparent, transparent, transparent, black, transparent],
            [black, black, black, black, black],
            [transparent, transparent, transparent, black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('shape pointer', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.selectTool(ToolKind.line);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          final actual = pixelRows(editorController.pointerLayer);
          const expected = [
            [transparent, transparent, black],
          ];
          expect(actual, equals(expected));
        });
        test('color picker', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = [pixelRows(document.activeLayer), notifications];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
      });

      group('tool switch back', () {
        test('default pen', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = editorController.toolKind;
          const expected = ToolKind.pen;
          expect(actual, equals(expected));
        });
        test('eraser', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.eraser);
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = editorController.toolKind;
          const expected = ToolKind.eraser;
          expect(actual, equals(expected));
        });
        test('picker reselected', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.eraser);
          editorController.selectTool(ToolKind.colorPicker);
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = editorController.toolKind;
          const expected = ToolKind.eraser;
          expect(actual, equals(expected));
        });
        test('drawing tool', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.eraser);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = editorController.toolKind;
          const expected = ToolKind.eraser;
          expect(actual, equals(expected));
        });
      });

      group('history', () {
        test('pen click', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          final actual = editorController.history.entries;
          final expected = [
            PixelHistoryEntry(
              name: 'Pen',
              layerIndex: 0,
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
                rgba: Uint8List.fromList([0, 0, 0, 255]),
              ),
              thumbnail: Layer(
                width: 3,
                height: 1,
                rgba: Uint8List.fromList([
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  255,
                  0,
                  0,
                  0,
                  0,
                ]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('pen drag', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 4, height: 1),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          final actual = editorController.history.entries;
          final expected = [
            PixelHistoryEntry(
              name: 'Pen',
              layerIndex: 0,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 3,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 3,
                  height: 1,
                ),
                rgba: Uint8List.fromList([
                  0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, //
                ]),
              ),
              thumbnail: Layer(
                width: 4,
                height: 1,
                rgba: Uint8List.fromList([
                  0,
                  0,
                  0,
                  255,
                  0,
                  0,
                  0,
                  255,
                  0,
                  0,
                  0,
                  255,
                  0,
                  0,
                  0,
                  0,
                ]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('eraser', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(
              width: 3,
              height: 1,
              background: PixelColor.black,
            ),
          );
          editorController.selectTool(ToolKind.eraser);
          editorController.pointerDown(
            point: const PixelPoint(x: 2, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          final actual = editorController.history.entries;
          final expected = [
            PixelHistoryEntry(
              name: 'Eraser',
              layerIndex: 0,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 2,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 255]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 2,
                  top: 0,
                  width: 1,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0]),
              ),
              thumbnail: Layer(
                width: 3,
                height: 1,
                rgba: Uint8List.fromList([
                  0,
                  0,
                  0,
                  255,
                  0,
                  0,
                  0,
                  255,
                  0,
                  0,
                  0,
                  0,
                ]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('bucket fill', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.bucketFill);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.secondary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = editorController.history.entries;
          final expected = [
            PixelHistoryEntry(
              name: 'Fill',
              layerIndex: 0,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 2,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 2,
                  height: 1,
                ),
                rgba: Uint8List.fromList([
                  255,
                  255,
                  255,
                  255,
                  255,
                  255,
                  255,
                  255,
                ]),
              ),
              thumbnail: Layer(
                width: 2,
                height: 1,
                rgba: Uint8List.fromList([
                  255,
                  255,
                  255,
                  255,
                  255,
                  255,
                  255,
                  255,
                ]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('rectangle', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          editorController.selectTool(ToolKind.rectangle);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          final actual = editorController.history.entries;
          final expected = [
            PixelHistoryEntry(
              name: 'Rectangle',
              layerIndex: 0,
              before: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 2,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]),
              ),
              after: LayerSnapshot(
                area: const PixelRectangle(
                  left: 0,
                  top: 0,
                  width: 2,
                  height: 1,
                ),
                rgba: Uint8List.fromList([0, 0, 0, 255, 0, 0, 0, 255]),
              ),
              thumbnail: Layer(
                width: 2,
                height: 1,
                rgba: Uint8List.fromList([0, 0, 0, 255, 0, 0, 0, 255]),
              ),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('color picker', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          final actual = editorController.history.entries;
          const expected = [];
          expect(actual, equals(expected));
        });
        test('unchanged pixels', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(
              width: 3,
              height: 1,
              background: PixelColor.black,
            ),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 0));
          final actual = editorController.history.entries;
          const expected = [];
          expect(actual, equals(expected));
        });
        test('outside layer', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 5, y: 5),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 5, y: 5));
          final actual = editorController.history.entries;
          const expected = [];
          expect(actual, equals(expected));
        });
      });

      group('selection move', () {
        test('dragged contents', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          final actual = [
            pixelRows(document.activeLayer),
            editorController.selectionArea,
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            [
              [transparent, transparent, black],
            ],
            PixelRectangle(left: 2, top: 0, width: 1, height: 1),
            ['Move selection'],
          ];
          expect(actual, equals(expected));
        });
        test('undo', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          editorController.undo();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.selectionArea,
          ];
          const expected = [
            [
              [black, transparent, transparent],
            ],
            null,
          ];
          expect(actual, equals(expected));
        });
      });

      group('no stroke', () {
        test('without pointer down', () {
          final document = Document.blank(width: 3, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = [pixelRows(document.activeLayer), notifications];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            0,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter selectionArea', () {
      group('selecting', () {
        test('none', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          final actual = [
            editorController.selectionArea,
            editorController.hasSelection,
          ];
          const expected = [null, false];
          expect(actual, equals(expected));
        });
        test('while dragging', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          final actual = [
            editorController.selectionArea,
            editorController.hasSelection,
          ];
          const expected = [
            PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            false,
          ];
          expect(actual, equals(expected));
        });
        test('after release', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 1));
          final actual = [
            editorController.selectionArea,
            editorController.hasSelection,
            editorController.history.entries.length,
          ];
          const expected = [
            PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            true,
            0,
          ];
          expect(actual, equals(expected));
        });
        test('dragged past edge', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 1),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 5, y: 5));
          editorController.pointerUp(point: const PixelPoint(x: 5, y: 5));
          final actual = editorController.selectionArea;
          const expected = PixelRectangle(left: 1, top: 1, width: 2, height: 2);
          expect(actual, equals(expected));
        });
        test('outside layer', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 5, y: 5),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 6, y: 6));
          editorController.pointerUp(point: const PixelPoint(x: 6, y: 6));
          final actual = editorController.selectionArea;
          const expected = null;
          expect(actual, equals(expected));
        });
        test('click deselects', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerDown(
            point: const PixelPoint(x: 2, y: 2),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 2));
          final actual = editorController.selectionArea;
          const expected = null;
          expect(actual, equals(expected));
        });
        test('tool change deselects', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 1));
          editorController.selectTool(ToolKind.pen);
          final actual = editorController.selectionArea;
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter pointerOverSelection', () {
      group('pointer', () {
        test('inside', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          final actual = editorController.pointerOverSelection;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('outside', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 2));
          final actual = editorController.pointerOverSelection;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('exited', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerUp(point: const PixelPoint(x: 1, y: 1));
          editorController.pointerExit();
          final actual = editorController.pointerOverSelection;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('no selection', () {
          final document = Document.blank(width: 3, height: 3);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 1));
          final actual = editorController.pointerOverSelection;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method selectAll', () {
      group('state', () {
        test('idle', () {
          final document = Document.blank(width: 3, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.selectAll();
          final actual = [
            editorController.toolKind,
            editorController.selectionArea,
            notifications,
          ];
          const expected = [
            ToolKind.select,
            PixelRectangle(left: 0, top: 0, width: 3, height: 2),
            1,
          ];
          expect(actual, equals(expected));
        });
        test('during stroke', () {
          final document = Document.blank(width: 3, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.selectAll();
          final actual = [
            editorController.toolKind,
            editorController.selectionArea,
          ];
          const expected = [ToolKind.pen, null];
          expect(actual, equals(expected));
        });
        test('color picker returns', () {
          final document = Document.blank(width: 3, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectAll();
          editorController.selectTool(ToolKind.colorPicker);
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerUp(point: const PixelPoint(x: 0, y: 0));
          final actual = editorController.toolKind;
          const expected = ToolKind.select;
          expect(actual, equals(expected));
        });
      });
    });

    group('method deleteSelection', () {
      group('selection', () {
        test('selected area', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.deleteSelection();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.selectionArea,
            editorController.history.entries.map((entry) => entry.name),
            notifications,
          ];
          const expected = [
            [
              [black, transparent, transparent],
            ],
            null,
            ['Delete selection'],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('none', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.deleteSelection();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.entries,
          ];
          const expected = [
            [
              [black, black, black],
            ],
            [],
          ];
          expect(actual, equals(expected));
        });
        test('during stroke', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.deleteSelection();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.hasSelection,
          ];
          const expected = [
            [
              [black, black, black],
            ],
            true,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter selectionContent', () {
      group('selection', () {
        test('selected area', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectAll();
          final actual = pixelRows(editorController.selectionContent!);
          const expected = [
            [black, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('none', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 2, height: 1),
          );
          final actual = editorController.selectionContent;
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });

    group('method cutSelection', () {
      group('selection', () {
        test('selected area', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          editorController.cutSelection();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.selectionArea,
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            [
              [black, transparent, transparent],
            ],
            null,
            ['Cut'],
          ];
          expect(actual, equals(expected));
        });
        test('none', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.cutSelection();
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.entries,
          ];
          const expected = [
            [
              [black, black, black],
            ],
            [],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method paste', () {
      group('into selection', () {
        test('fits', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.paste(
            layerFromRows([
              [red],
            ]),
          );
          final actual = [
            pixelRows(document.activeLayer),
            document.layers.length,
            editorController.selectionArea,
            editorController.history.entries.map((entry) => entry.name),
            notifications,
          ];
          const expected = [
            [
              [black, red, black],
            ],
            1,
            PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            ['Paste'],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('same size', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectAll();
          editorController.paste(
            layerFromRows([
              [red, white],
            ]),
          );
          final actual = [
            pixelRows(document.activeLayer),
            document.layers.length,
          ];
          const expected = [
            [
              [red, white],
            ],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('move pasted', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectAll();
          editorController.paste(
            layerFromRows([
              [red],
            ]),
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 0));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 0));
          final actual = pixelRows(document.activeLayer);
          const expected = [
            [black, black, red],
          ];
          expect(actual, equals(expected));
        });
      });
      group('no selection', () {
        test('active layer', () {
          final document = Document.blank(
            width: 3,
            height: 1,
            background: PixelColor.black,
          );
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.paste(
            layerFromRows([
              [red],
            ]),
          );
          final actual = [
            layerStructure(document),
            pixelRows(document.activeLayer),
            editorController.selectionArea,
            editorController.toolKind,
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            [
              ['Background'],
              0,
            ],
            [
              [red, black, black],
            ],
            PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            ToolKind.select,
            ['Paste'],
          ];
          expect(actual, equals(expected));
        });
        test('larger than document', () {
          final document = Document.blank(width: 1, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.paste(
            layerFromRows([
              [red, white],
            ]),
          );
          final actual = [
            pixelRows(document.activeLayer),
            editorController.selectionArea,
          ];
          const expected = [
            [
              [red],
            ],
            PixelRectangle(left: 0, top: 0, width: 2, height: 1),
          ];
          expect(actual, equals(expected));
        });
      });
      group('as layer', () {
        test('wider than selection', () {
          final document = Document.blank(width: 2, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 1),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 2));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 2));
          editorController.paste(
            layerFromRows([
              [red, red],
            ]),
          );
          final actual = [
            document.layers.length,
            pixelRows(document.activeLayer),
          ];
          const expected = [
            2,
            [
              [red, red],
              [transparent, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('taller than selection', () {
          final document = Document.blank(width: 2, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 1),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 2));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 2));
          editorController.paste(
            layerFromRows([
              [red],
              [red],
            ]),
          );
          final actual = [
            document.layers.length,
            pixelRows(document.activeLayer),
          ];
          const expected = [
            2,
            [
              [red, transparent],
              [red, transparent],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('undo', () {
          final document = Document.blank(width: 2, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.selectTool(ToolKind.select);
          editorController.pointerDown(
            point: const PixelPoint(x: 1, y: 1),
            button: PointerButton.primary,
          );
          editorController.pointerMove(point: const PixelPoint(x: 2, y: 2));
          editorController.pointerUp(point: const PixelPoint(x: 2, y: 2));
          editorController.paste(
            layerFromRows([
              [red, red],
            ]),
          );
          final pasted = [
            layerStructure(document),
            editorController.history.entries.map((entry) => entry.name),
          ];
          editorController.undo();
          final actual = [
            pasted,
            layerStructure(document),
            editorController.selectionArea,
          ];
          const expected = [
            [
              [
                ['Background', 'Layer 2'],
                1,
              ],
              ['Paste as layer'],
            ],
            [
              ['Background'],
              0,
            ],
            null,
          ];
          expect(actual, equals(expected));
        });
      });
      group('stroke', () {
        test('ignored', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.paste(
            layerFromRows([
              [red],
            ]),
          );
          final actual = [
            document.layers.length,
            editorController.toolKind,
            editorController.hasSelection,
          ];
          const expected = [1, ToolKind.pen, false];
          expect(actual, equals(expected));
        });
      });
    });

    group('method rotateSelection', () {
      group('directions', () {
        test('clockwise', () {
          final document = Document.blank(width: 2, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectAll();
          editorController.rotateSelection(clockwise: true);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.selectionArea,
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            [
              [transparent, black],
              [transparent, transparent],
            ],
            PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            ['Rotate right'],
          ];
          expect(actual, equals(expected));
        });
        test('counterclockwise', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectAll();
          editorController.rotateSelection(clockwise: false);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            [
              [transparent, transparent],
            ],
            ['Rotate left'],
          ];
          expect(actual, equals(expected));
        });
      });

      group('ignored', () {
        test('no selection', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          editorController.rotateSelection(clockwise: true);
          final actual = editorController.history.entries;
          const expected = [];
          expect(actual, equals(expected));
        });
        test('during stroke', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectAll();
          editorController.pointerDown(
            point: const PixelPoint(x: 0, y: 0),
            button: PointerButton.primary,
          );
          editorController.rotateSelection(clockwise: true);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.entries,
          ];
          const expected = [
            [
              [black, transparent],
            ],
            [],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method mirrorSelection', () {
      group('directions', () {
        test('horizontally', () {
          final document = Document.blank(width: 2, height: 1);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectAll();
          editorController.mirrorSelection(horizontally: true);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            [
              [transparent, black],
            ],
            ['Mirror horizontally'],
          ];
          expect(actual, equals(expected));
        });
        test('vertically', () {
          final document = Document.blank(width: 1, height: 2);
          final editorController = EditorController.forDocument(
            document: document,
          );
          document.activeLayer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          editorController.selectAll();
          editorController.mirrorSelection(horizontally: false);
          final actual = [
            pixelRows(document.activeLayer),
            editorController.history.entries.map((entry) => entry.name),
          ];
          const expected = [
            [
              [transparent],
              [black],
            ],
            ['Mirror vertically'],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method pointerExit', () {
      group('pointer', () {
        test('after hover', () {
          final editorController = EditorController.forDocument(
            document: Document.blank(width: 3, height: 1),
          );
          editorController.pointerMove(point: const PixelPoint(x: 1, y: 0));
          var notifications = 0;
          editorController.addListener(() => notifications++);
          editorController.pointerExit();
          final actual = [
            pixelRows(editorController.pointerLayer),
            editorController.cursor,
            notifications,
          ];
          const expected = [
            [
              [transparent, transparent, transparent],
            ],
            null,
            1,
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
