import 'package:flutter/foundation.dart';

import 'canvas/document.dart';
import 'canvas/layer.dart';
import 'canvas/pixel_color.dart';
import 'canvas/pixel_point.dart';
import 'canvas/pixel_rectangle.dart';
import 'history/history.dart';
import 'history/history_entry.dart';
import 'history/layer_snapshot.dart';
import 'pointer_button.dart';
import 'tools/brush_tip.dart';
import 'tools/eraser.dart';
import 'tools/pen.dart';
import 'tools/tool.dart';
import 'tools/tool_kind.dart';

class EditorController extends ChangeNotifier {
  EditorController({
    required this.document,
    required this.pointerLayer,
    required this.history,
  });

  factory EditorController.forDocument({required Document document}) {
    return EditorController(
      document: document,
      pointerLayer: Layer.filled(
        width: document.width,
        height: document.height,
        color: PixelColor.transparent,
      ),
      history: History.forDocument(document: document),
    );
  }

  final Document document;
  final Layer pointerLayer;
  final History history;

  var _toolKind = ToolKind.pen;
  var _drawingToolKind = ToolKind.pen;
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
  var _strokeButton = PointerButton.primary;
  var _pointerArea = _noArea;
  Layer? _strokeBefore;
  var _strokeArea = _noArea;
  var _recentColors = const <PixelColor>[];

  static const _noArea = PixelRectangle(left: 0, top: 0, width: 0, height: 0);
  static const recentColorLimit = 5;

  ToolKind get toolKind => _toolKind;
  int get penSize => _penSize;
  BrushTip get penTip => _penTip;
  int get eraserSize => _eraserSize;
  int get zoom => _zoom;
  PixelColor get primaryColor => _primaryColor;
  PixelColor get secondaryColor => _secondaryColor;
  bool get editingPrimary => _editingPrimary;
  PixelPoint? get cursor => _cursor;
  List<PixelColor> get recentColors => _recentColors;
  PixelColor get editedColor =>
      _editingPrimary ? _primaryColor : _secondaryColor;

  List<Layer> get visibleLayers => [...document.layers, pointerLayer];

  Tool? get _tool => switch (_toolKind) {
    ToolKind.pen => Pen(size: _penSize, tip: _penTip),
    ToolKind.eraser => Eraser(size: _eraserSize),
    ToolKind.colorPicker => null,
  };

  void selectTool(ToolKind toolKind) {
    _toolKind = toolKind;
    if (toolKind != ToolKind.colorPicker) _drawingToolKind = toolKind;
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

  void undo() => jumpToHistory(history.position - 1);

  void redo() => jumpToHistory(history.position + 1);

  void jumpToHistory(int position) {
    if (_strokePoint != null) return;
    history.jumpTo(position);
    notifyListeners();
  }

  void pointerDown({required PixelPoint point, required PointerButton button}) {
    _strokeColor = switch (button) {
      PointerButton.primary => _primaryColor,
      PointerButton.secondary => _secondaryColor,
    };
    _strokeButton = button;
    if (_toolKind == ToolKind.pen) _rememberColor(_strokeColor);
    _sampleColor(point: point);
    final tool = _tool;
    if (tool != null) {
      _strokeBefore = Layer.copyOf(document.activeLayer);
      _strokeArea = tool.start(
        layer: document.activeLayer,
        point: point,
        color: _strokeColor,
      );
    }
    _strokePoint = point;
    _movePointer(point: point, color: _strokeColor);
  }

  void pointerMove({required PixelPoint point}) {
    final strokePoint = _strokePoint;
    if (strokePoint == null) {
      _movePointer(point: point, color: _primaryColor);
      return;
    }
    _sampleColor(point: point);
    final altered = _tool?.stroke(
      layer: document.activeLayer,
      previous: strokePoint,
      point: point,
      color: _strokeColor,
    );
    if (altered != null) _strokeArea = _strokeArea.union(altered);
    _strokePoint = point;
    _movePointer(point: point, color: _strokeColor);
  }

  void pointerUp({required PixelPoint point}) {
    if (_strokePoint == null) return;
    final altered = _tool?.end(
      layer: document.activeLayer,
      point: point,
      color: _strokeColor,
    );
    if (altered != null) _strokeArea = _strokeArea.union(altered);
    _strokePoint = null;
    _recordStroke();
    if (_toolKind == ToolKind.colorPicker) _toolKind = _drawingToolKind;
    notifyListeners();
  }

  void pointerExit() {
    _clearPointer();
    _cursor = null;
    notifyListeners();
  }

  void _recordStroke() {
    final strokeBefore = _strokeBefore;
    if (strokeBefore == null) return;
    _strokeBefore = null;
    final entry = HistoryEntry(
      name: _toolKind.label,
      layerIndex: document.activeLayerIndex,
      before: LayerSnapshot.capture(layer: strokeBefore, area: _strokeArea),
      after: LayerSnapshot.capture(
        layer: document.activeLayer,
        area: _strokeArea,
      ),
      thumbnail: Layer.thumbnail(
        layer: document.activeLayer,
        maximumSize: History.thumbnailSize,
      ),
    );
    if (entry.before != entry.after) history.record(entry);
  }

  void _rememberColor(PixelColor color) {
    _recentColors = [
      color,
      ..._recentColors.where((recent) => recent != color),
    ].take(recentColorLimit).toList();
  }

  void _sampleColor({required PixelPoint point}) {
    if (_toolKind != ToolKind.colorPicker) return;
    if (!document.activeLayer.contains(point)) return;
    final color = document.activeLayer.getPixel(point);
    switch (_strokeButton) {
      case PointerButton.primary:
        _primaryColor = color;
      case PointerButton.secondary:
        _secondaryColor = color;
    }
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
