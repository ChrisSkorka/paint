import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/editor_controller.dart';
import 'package:paint/editor/pointer_button.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/tool_kind.dart';

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
            document.activeLayer,
            editorController.pointerLayer,
          ];
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
