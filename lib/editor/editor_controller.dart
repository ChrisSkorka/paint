import 'dart:math';

import 'package:flutter/foundation.dart';

import 'canvas/document.dart';
import 'canvas/document_layer.dart';
import 'canvas/layer.dart';
import 'canvas/pixel_color.dart';
import 'canvas/pixel_point.dart';
import 'canvas/pixel_rectangle.dart';
import 'history/history.dart';
import 'history/layer_snapshot.dart';
import 'history/layers_history_entry.dart';
import 'history/pixel_history_entry.dart';
import 'pointer_button.dart';
import 'selection/selection.dart';
import 'tools/brush_tip.dart';
import 'tools/bucket_fill.dart';
import 'tools/eraser.dart';
import 'tools/pen.dart';
import 'tools/shape.dart';
import 'tools/shape_tool.dart';
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
  var _shapeWidth = 1;
  var _zoom = 4;
  var _primaryColor = PixelColor.black;
  var _secondaryColor = PixelColor.white;
  var _editingPrimary = true;
  PixelPoint? _cursor;
  PixelPoint? _strokeOrigin;
  PixelPoint? _strokePoint;
  var _strokeColor = PixelColor.black;
  var _strokeButton = PointerButton.primary;
  var _pointerArea = _noArea;
  Layer? _strokeBefore;
  var _strokeName = '';
  var _selectionOrigin = const PixelPoint(x: 0, y: 0);
  PixelRectangle? _selectingArea;
  Selection? _selection;
  var _strokeArea = _noArea;
  var _recentColors = const <PixelColor>[];
  late var _layerCount = document.layers.length;
  List<DocumentLayer>? _layersBeforeOpacityPreview;

  static const _noArea = PixelRectangle(left: 0, top: 0, width: 0, height: 0);
  static const recentColorLimit = 5;

  ToolKind get toolKind => _toolKind;
  int get penSize => _penSize;
  BrushTip get penTip => _penTip;
  int get eraserSize => _eraserSize;
  int get shapeWidth => _shapeWidth;
  int get zoom => _zoom;
  PixelColor get primaryColor => _primaryColor;
  PixelColor get secondaryColor => _secondaryColor;
  bool get editingPrimary => _editingPrimary;
  PixelPoint? get cursor => _cursor;
  List<PixelColor> get recentColors => _recentColors;
  PixelRectangle? get selectionArea => _selectingArea ?? _selection?.area;
  bool get hasSelection => _selection != null;
  bool get pointerOverSelection {
    final cursor = _cursor;
    final selection = _selection;
    return cursor != null &&
        selection != null &&
        selection.area.contains(cursor);
  }

  bool get canRemoveLayer => document.layers.length > 1;
  bool get canMoveLayerUp =>
      document.activeLayerIndex < document.layers.length - 1;
  bool get canMoveLayerDown => document.activeLayerIndex > 0;

  PixelColor get editedColor =>
      _editingPrimary ? _primaryColor : _secondaryColor;

  List<DocumentLayer> get visibleLayers => [
    ...document.layers.where((layer) => layer.visible),
    DocumentLayer(name: 'Pointer', pixels: pointerLayer),
  ];

  Tool? get _tool => switch (_toolKind) {
    ToolKind.pen => Pen(size: _penSize, tip: _penTip),
    ToolKind.eraser => Eraser(size: _eraserSize),
    ToolKind.bucketFill => const BucketFill(),
    ToolKind.line => _shapeTool(Shape.line),
    ToolKind.rectangle => _shapeTool(Shape.rectangle),
    ToolKind.circle => _shapeTool(Shape.ellipse),
    ToolKind.arrow => _shapeTool(Shape.arrow),
    ToolKind.colorPicker || ToolKind.select => null,
  };

  ShapeTool _shapeTool(Shape shape) =>
      ShapeTool(shape: shape, width: _shapeWidth, origin: _strokeOrigin);

  void selectTool(ToolKind toolKind) {
    _selection = null;
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

  void setShapeWidth(int width) {
    _shapeWidth = width;
    notifyListeners();
  }

  void setLayerVisibility({required int index, required bool visible}) {
    _changeLayers(
      name: visible ? 'Show layer' : 'Hide layer',
      changedLayerIndex: index,
      change: () => document.layers[index] = document.layers[index].copyWith(
        visible: visible,
      ),
    );
  }

  void previewLayerOpacity({required int index, required int opacity}) {
    _layersBeforeOpacityPreview ??= List.of(document.layers);
    document.layers[index] = document.layers[index].copyWith(opacity: opacity);
    notifyListeners();
  }

  void setLayerOpacity({required int index, required int opacity}) {
    final layersBefore =
        _layersBeforeOpacityPreview ?? List.of(document.layers);
    _layersBeforeOpacityPreview = null;
    if (layersBefore[index].opacity == opacity) {
      document.layers
        ..clear()
        ..addAll(layersBefore);
      notifyListeners();
      return;
    }
    _changeLayers(
      name: 'Layer opacity',
      layersBefore: layersBefore,
      changedLayerIndex: index,
      change: () => document.layers[index] = document.layers[index].copyWith(
        opacity: opacity,
      ),
    );
  }

  void selectLayer(int index) {
    if (_strokePoint != null) return;
    _selection = null;
    document.activeLayerIndex = index;
    notifyListeners();
  }

  void addLayer() {
    _changeLayers(
      name: 'Add layer',
      change: () {
        _selection = null;
        _layerCount++;
        final index = document.activeLayerIndex + 1;
        document.layers.insert(
          index,
          DocumentLayer(
            name: 'Layer $_layerCount',
            pixels: Layer.filled(
              width: document.width,
              height: document.height,
              color: PixelColor.transparent,
            ),
          ),
        );
        document.activeLayerIndex = index;
      },
    );
  }

  void removeLayer() {
    if (!canRemoveLayer) return;
    _changeLayers(
      name: 'Remove layer',
      change: () {
        _selection = null;
        document.layers.removeAt(document.activeLayerIndex);
        document.activeLayerIndex = max(0, document.activeLayerIndex - 1);
      },
    );
  }

  void moveLayer({required bool up}) {
    if (!(up ? canMoveLayerUp : canMoveLayerDown)) return;
    _changeLayers(
      name: up ? 'Move layer up' : 'Move layer down',
      change: () {
        _selection = null;
        final target = document.activeLayerIndex + (up ? 1 : -1);
        final layer = document.layers.removeAt(document.activeLayerIndex);
        document.layers.insert(target, layer);
        document.activeLayerIndex = target;
      },
    );
  }

  void _changeLayers({
    required String name,
    required VoidCallback change,
    List<DocumentLayer>? layersBefore,
    int? changedLayerIndex,
  }) {
    if (_strokePoint != null) return;
    layersBefore ??= List.of(document.layers);
    final activeIndexBefore = document.activeLayerIndex;
    change();
    history.record(
      LayersHistoryEntry(
        name: name,
        layersBefore: layersBefore,
        activeIndexBefore: activeIndexBefore,
        layersAfter: List.of(document.layers),
        activeIndexAfter: document.activeLayerIndex,
        thumbnail: Layer.thumbnail(
          layer: document
              .layers[changedLayerIndex ?? document.activeLayerIndex]
              .pixels,
          maximumSize: History.thumbnailSize,
        ),
      ),
    );
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
    _selection = null;
    _layersBeforeOpacityPreview = null;
    history.jumpTo(position);
    notifyListeners();
  }

  void pointerDown({required PixelPoint point, required PointerButton button}) {
    _strokeColor = switch (button) {
      PointerButton.primary => _primaryColor,
      PointerButton.secondary => _secondaryColor,
    };
    _strokeButton = button;
    _strokeOrigin = point;
    _strokeName = _toolKind.label;
    if (_toolKind.usesColor) _rememberColor(_strokeColor);
    _sampleColor(point: point);
    if (_toolKind == ToolKind.select) _startSelecting(point);
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
    if (_toolKind == ToolKind.select) {
      _dragSelection(previous: strokePoint, point: point);
    }
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
    _strokeOrigin = null;
    _strokePoint = null;
    _finishSelecting();
    _redrawPointer(point: point, color: _strokeColor);
    _recordStroke();
    if (_toolKind == ToolKind.colorPicker) _toolKind = _drawingToolKind;
    notifyListeners();
  }

  void pointerExit() {
    _clearPointer();
    _cursor = null;
    notifyListeners();
  }

  void selectAll() {
    if (_strokePoint != null) return;
    _toolKind = ToolKind.select;
    _drawingToolKind = ToolKind.select;
    _selection = Selection.lift(
      layer: document.activeLayer,
      area: document.activeLayer.bounds,
    );
    notifyListeners();
  }

  void deleteSelection() {
    final selection = _selection;
    if (selection == null || _strokePoint != null) return;
    final before = Layer.copyOf(document.activeLayer);
    document.activeLayer.fillRectangle(
      rectangle: selection.area,
      color: PixelColor.transparent,
    );
    _selection = null;
    _record(name: 'Delete selection', before: before, area: selection.area);
    notifyListeners();
  }

  void rotateSelection({required bool clockwise}) {
    _transformSelection(
      name: clockwise ? 'Rotate right' : 'Rotate left',
      transform: (selection) =>
          selection.rotated(layer: document.activeLayer, clockwise: clockwise),
    );
  }

  void mirrorSelection({required bool horizontally}) {
    _transformSelection(
      name: horizontally ? 'Mirror horizontally' : 'Mirror vertically',
      transform: (selection) => selection.mirrored(
        layer: document.activeLayer,
        horizontally: horizontally,
      ),
    );
  }

  void _transformSelection({
    required String name,
    required Selection Function(Selection selection) transform,
  }) {
    final selection = _selection;
    if (selection == null || _strokePoint != null) return;
    final before = Layer.copyOf(document.activeLayer);
    final transformed = transform(selection);
    _selection = transformed;
    _record(
      name: name,
      before: before,
      area: selection.area.union(transformed.area),
    );
    notifyListeners();
  }

  void _startSelecting(PixelPoint point) {
    final selection = _selection;
    if (selection != null && selection.area.contains(point)) {
      _strokeName = 'Move selection';
      _strokeBefore = Layer.copyOf(document.activeLayer);
      _strokeArea = selection.area;
      return;
    }
    _selection = null;
    _selectionOrigin = point;
  }

  void _dragSelection({
    required PixelPoint previous,
    required PixelPoint point,
  }) {
    final selection = _selection;
    if (selection == null) {
      _selectingArea = PixelRectangle.spanning(
        from: _selectionOrigin,
        to: point,
      ).intersection(document.activeLayer.bounds);
      return;
    }
    final moved = selection.moved(
      layer: document.activeLayer,
      offsetX: point.x - previous.x,
      offsetY: point.y - previous.y,
    );
    _strokeArea = _strokeArea.union(moved.area);
    _selection = moved;
  }

  void _finishSelecting() {
    final selectingArea = _selectingArea;
    _selectingArea = null;
    if (selectingArea == null || selectingArea.isEmpty) return;
    _selection = Selection.lift(
      layer: document.activeLayer,
      area: selectingArea,
    );
  }

  void _recordStroke() {
    final strokeBefore = _strokeBefore;
    if (strokeBefore == null) return;
    _strokeBefore = null;
    _record(name: _strokeName, before: strokeBefore, area: _strokeArea);
  }

  void _record({
    required String name,
    required Layer before,
    required PixelRectangle area,
  }) {
    final entry = PixelHistoryEntry(
      name: name,
      layerIndex: document.activeLayerIndex,
      before: LayerSnapshot.capture(layer: before, area: area),
      after: LayerSnapshot.capture(layer: document.activeLayer, area: area),
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
    _redrawPointer(point: point, color: color);
    notifyListeners();
  }

  void _redrawPointer({required PixelPoint point, required PixelColor color}) {
    _clearPointer();
    _pointerArea =
        _tool?.drawPointer(layer: pointerLayer, point: point, color: color) ??
        _noArea;
    _cursor = document.activeLayer.contains(point) ? point : null;
  }

  void _clearPointer() {
    pointerLayer.fillRectangle(
      rectangle: _pointerArea,
      color: PixelColor.transparent,
    );
  }
}
