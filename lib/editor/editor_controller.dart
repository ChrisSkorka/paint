import 'package:flutter/foundation.dart';

import 'canvas/document.dart';
import 'canvas/layer.dart';
import 'canvas/pixel_color.dart';
import 'canvas/pixel_point.dart';
import 'canvas/pixel_rectangle.dart';
import 'pointer_button.dart';
import 'tools/brush_tip.dart';
import 'tools/eraser.dart';
import 'tools/pen.dart';
import 'tools/tool.dart';
import 'tools/tool_kind.dart';

class EditorController extends ChangeNotifier {
  EditorController({required this.document, required this.pointerLayer});

  factory EditorController.forDocument({required Document document}) {
    return EditorController(
      document: document,
      pointerLayer: Layer.filled(
        width: document.width,
        height: document.height,
        color: PixelColor.transparent,
      ),
    );
  }

  final Document document;
  final Layer pointerLayer;

  var _toolKind = ToolKind.pen;
  var _penSize = 1;
  var _penTip = BrushTip.square;
  var _eraserSize = 1;
  var _zoom = 4;
  var _primaryColor = PixelColor.black;
  var _secondaryColor = PixelColor.white;
  var _editingPrimary = true;
  PixelPoint? _cursor;
  PixelPoint? _strokePoint;
  var _strokeColor = PixelColor.black;
  var _pointerArea = _noArea;

  static const _noArea = PixelRectangle(left: 0, top: 0, width: 0, height: 0);

  ToolKind get toolKind => _toolKind;
  int get penSize => _penSize;
  BrushTip get penTip => _penTip;
  int get eraserSize => _eraserSize;
  int get zoom => _zoom;
  PixelColor get primaryColor => _primaryColor;
  PixelColor get secondaryColor => _secondaryColor;
  bool get editingPrimary => _editingPrimary;
  PixelPoint? get cursor => _cursor;

  List<Layer> get visibleLayers => [...document.layers, pointerLayer];

  Tool? get _tool => switch (_toolKind) {
    ToolKind.pen => Pen(size: _penSize, tip: _penTip),
    ToolKind.eraser => Eraser(size: _eraserSize),
    ToolKind.colorPicker => null,
  };

  void selectTool(ToolKind toolKind) {
    _toolKind = toolKind;
    notifyListeners();
  }

  void setPenSize(int size) {
    _penSize = size;
    notifyListeners();
  }

  void setPenTip(BrushTip tip) {
    _penTip = tip;
    notifyListeners();
  }

  void setEraserSize(int size) {
    _eraserSize = size;
    notifyListeners();
  }

  void setZoom(int zoom) {
    _zoom = zoom;
    notifyListeners();
  }

  void editPrimary({required bool primary}) {
    _editingPrimary = primary;
    notifyListeners();
  }

  void selectColor(PixelColor color) {
    if (_editingPrimary) {
      _primaryColor = color;
    } else {
      _secondaryColor = color;
    }
    notifyListeners();
  }

  void pointerDown({required PixelPoint point, required PointerButton button}) {
    _strokeColor = switch (button) {
      PointerButton.primary => _primaryColor,
      PointerButton.secondary => _secondaryColor,
    };
    _tool?.start(
      layer: document.activeLayer,
      point: point,
      color: _strokeColor,
    );
    _strokePoint = point;
    _movePointer(point: point, color: _strokeColor);
  }

  void pointerMove({required PixelPoint point}) {
    final strokePoint = _strokePoint;
    if (strokePoint == null) {
      _movePointer(point: point, color: _primaryColor);
      return;
    }
    _tool?.stroke(
      layer: document.activeLayer,
      previous: strokePoint,
      point: point,
      color: _strokeColor,
    );
    _strokePoint = point;
    _movePointer(point: point, color: _strokeColor);
  }

  void pointerUp({required PixelPoint point}) {
    if (_strokePoint == null) return;
    _tool?.end(layer: document.activeLayer, point: point, color: _strokeColor);
    _strokePoint = null;
    notifyListeners();
  }

  void pointerExit() {
    _clearPointer();
    _cursor = null;
    notifyListeners();
  }

  void _movePointer({required PixelPoint point, required PixelColor color}) {
    _clearPointer();
    _pointerArea =
        _tool?.drawPointer(layer: pointerLayer, point: point, color: color) ??
        _noArea;
    _cursor = document.activeLayer.contains(point) ? point : null;
    notifyListeners();
  }

  void _clearPointer() {
    pointerLayer.fillRectangle(
      rectangle: _pointerArea,
      color: PixelColor.transparent,
    );
  }
}
