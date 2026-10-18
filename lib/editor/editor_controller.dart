import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'canvas/canvas_layer.dart';
import 'canvas/document.dart';
import 'canvas/document_layer.dart';
import 'canvas/layer.dart';
import 'canvas/layer_timeframe.dart';
import 'canvas/onion_skin.dart';
import 'canvas/pixel_color.dart';
import 'canvas/pixel_point.dart';
import 'canvas/pixel_rectangle.dart';
import 'files/save_status.dart';
import 'history/document_structure.dart';
import 'history/history.dart';
import 'history/layer_snapshot.dart';
import 'history/pixel_history_entry.dart';
import 'history/structure_history_entry.dart';
import 'pointer_button.dart';
import 'pointer_preview.dart';
import 'selection/selection.dart';
import 'tools/brush_tip.dart';
import 'tools/bucket_fill.dart';
import 'tools/eraser.dart';
import 'tools/pen.dart';
import 'tools/shape.dart';
import 'tools/shape_tool.dart';
import 'tools/text_format.dart';
import 'tools/text_orientation.dart';
import 'tools/text_stamp.dart';
import 'tools/tool.dart';
import 'tools/tool_kind.dart';
import 'tools/tool_preset.dart';
import 'tools/tool_presets.dart';
import 'tools/tool_size.dart';
import 'zoom.dart';

class EditorController extends ChangeNotifier {
  EditorController({
    required this.document,
    required this.pointerPreview,
    required this.history,
    required String savedName,
  }) : _savedName = savedName;

  factory EditorController.forDocument({required Document document}) {
    return EditorController(
      document: document,
      pointerPreview: PointerPreview.sized(
        width: document.width,
        height: document.height,
      ),
      history: History.forDocument(document: document),
      savedName: document.name,
    );
  }

  final Document document;
  final PointerPreview pointerPreview;
  final History history;

  var _toolKind = ToolKind.pen;
  var _drawingToolKind = ToolKind.pen;
  var _penSize = 1;
  var _penTip = BrushTip.square;
  var _zoom = Zoom.standard;
  var _primaryColor = PixelColor.black;
  var _secondaryColor = PixelColor.white;
  var _editingPrimary = true;
  PixelPoint? _strokeOrigin;
  PixelPoint? _strokePoint;
  var _strokeColor = PixelColor.black;
  var _strokeButton = PointerButton.primary;
  Layer? _strokeBefore;
  var _strokeName = '';
  var _selectionOrigin = const PixelPoint(x: 0, y: 0);
  PixelRectangle? _selectingArea;
  Selection? _selection;
  var _strokeArea = _noArea;
  late var _layerCount = document.layers.length;
  String _savedName;
  DocumentStructure? _structureBeforePreview;
  var _playing = false;
  var _onionSkin = const OnionSkin();
  var _colorPickerHeld = false;
  var _shapeConstrained = false;
  var _shapeCentered = false;
  var _shapeOutlined = true;
  var _shapeFilled = false;
  var _textFormat = const TextFormat();
  var _textOrientation = const TextOrientation();
  PixelPoint? _textOrigin;
  var _textButton = PointerButton.primary;
  var _text = '';
  _ToolSettings? _temporarySettings;
  var _temporarySelectionMade = false;
  final _strokeProgress = _StrokeProgress();
  late final layersChanged = Listenable.merge([this, _strokeProgress]);

  static const _noArea = PixelRectangle(left: 0, top: 0, width: 0, height: 0);
  static const _dragSizedToolKinds = {
    ToolKind.select,
    ToolKind.line,
    ToolKind.rectangle,
    ToolKind.circle,
    ToolKind.arrow,
  };
  static const minimumToolSize = ToolPreset.minimumSize;
  static const maximumToolSize = ToolPreset.maximumSize;

  @override
  void notifyListeners() {
    _revertFinishedSelection();
    super.notifyListeners();
  }

  @override
  void dispose() {
    pointerPreview.dispose();
    _strokeProgress.dispose();
    super.dispose();
  }

  ToolKind get toolKind => _toolKind;
  int get penSize => _penSize;
  BrushTip get penTip => _penTip;
  Zoom get zoom => _zoom;
  PixelColor get primaryColor => _primaryColor;
  PixelColor get secondaryColor => _secondaryColor;
  bool get shapeOutlined => _shapeOutlined;
  bool get shapeFilled => _shapeFilled;
  TextFormat get textFormat => _textFormat;
  PixelPoint? get textOrigin => _textOrigin;
  TextOrientation get textOrientation => _textOrientation;
  PixelColor get textOutlineColor => switch (_textButton) {
    PointerButton.primary => _secondaryColor,
    PointerButton.secondary => _primaryColor,
  };
  PixelColor get textColor => switch (_textButton) {
    PointerButton.primary => _primaryColor,
    PointerButton.secondary => _secondaryColor,
  };
  bool get editingPrimary => _editingPrimary;
  Layer get pointerLayer => pointerPreview.layer;
  PixelPoint? get cursor => pointerPreview.cursor;
  List<ToolPreset> get toolPresets => document.toolPresets.all;
  ToolPreset? get toolPreset => _presetWith(
    kind: _toolKind,
    color: _primaryColor,
    secondaryColor: _secondaryColor,
  );
  PixelRectangle? get selectionArea => _selectingArea ?? _selection?.area;
  bool get hasSelection => _selection != null;
  PixelPoint? get dragOffset {
    final origin = _strokeOrigin;
    final point = _strokePoint;
    if (origin == null || point == null) return null;
    if (!_dragSizedToolKinds.contains(_toolKind) || _selection != null) {
      return null;
    }
    final (:from, :to) = switch (_tool) {
      final ShapeTool shapeTool => shapeTool.span(point: point),
      _ => (from: origin, to: point),
    };
    return PixelPoint(
      x: (to.x - from.x).abs() + 1,
      y: (to.y - from.y).abs() + 1,
    );
  }

  bool get canTransform => hasSelection || _textOrigin != null;
  Layer? get selectionContent => _selection?.content;
  bool get pointerOverSelection {
    final cursor = pointerPreview.cursor;
    final selection = _selection;
    return cursor != null &&
        selection != null &&
        selection.area.contains(cursor);
  }

  bool get canRemoveLayer => document.layers.length > 1;
  bool get canMoveLayerUp =>
      document.activeLayerIndex < document.layers.length - 1;
  bool get canMoveLayerDown => document.activeLayerIndex > 0;
  bool get canRemoveFrame => document.frameCount > 1;
  bool get canMoveFrameUp => document.activeFrameIndex > 0;
  bool get canMoveFrameDown =>
      document.activeFrameIndex < document.frameCount - 1;
  bool get playing => _playing;
  OnionSkin get onionSkin => _onionSkin;

  SaveStatus get saveStatus => switch (document.storeId) {
    null => SaveStatus.notSaved,
    _ when hasUnsavedChanges => SaveStatus.unsavedChanges,
    _ => SaveStatus.saved,
  };

  bool get hasUnsavedChanges =>
      !history.isAtSavedPoint || document.name != _savedName;

  void markSaved({required HistoryPoint point, required String name}) {
    history.markSaved(point);
    _savedName = name;
    notifyListeners();
  }

  void rename({required String name}) {
    document.name = name;
    notifyListeners();
  }

  PixelColor get editedColor =>
      _editingPrimary ? _primaryColor : _secondaryColor;

  List<CanvasLayer> get canvasLayers => [
    for (final layer in document.layers.where((layer) => layer.visible))
      CanvasLayer(
        image: layer.imageAt(document.activeFrameIndex),
        opacity: layer.opacity,
      ),
    for (var index = 0; index < document.layers.length; index++)
      ..._onionSkinLayers(index: index),
  ];

  List<CanvasLayer> _onionSkinLayers({required int index}) {
    final layer = document.layers[index];
    if (!_onionSkin.enabled ||
        _playing ||
        !layer.visible ||
        layer.timeframe == LayerTimeframe.constant ||
        (_onionSkin.activeLayerOnly && index != document.activeLayerIndex)) {
      return const [];
    }
    final active = document.activeFrameIndex;
    final shown = document.shownFrames;
    final previous = _onionSkin.previous
        ? shown.where((frame) => frame < active).toList().reversed.toList()
        : const <int>[];
    final next = _onionSkin.next
        ? shown.where((frame) => frame > active).toList()
        : const <int>[];
    CanvasLayer ghost({
      required int frame,
      required int distance,
      required PixelColor tint,
    }) => CanvasLayer(
      image: layer.imageAt(frame),
      opacity: (layer.opacity / (1 << distance)).round(),
      tint: tint,
    );
    return [
      for (var distance = _onionSkin.frameCount; distance > 0; distance--) ...[
        if (distance <= previous.length)
          ghost(
            frame: previous[distance - 1],
            distance: distance,
            tint: OnionSkin.previousTint,
          ),
        if (distance <= next.length)
          ghost(
            frame: next[distance - 1],
            distance: distance,
            tint: OnionSkin.nextTint,
          ),
      ],
    ];
  }

  Tool? get _tool => switch (_toolKind) {
    ToolKind.pen => Pen(size: _penSize, tip: _penTip),
    ToolKind.eraser => Eraser(size: _penSize, tip: _penTip),
    ToolKind.bucketFill => const BucketFill(),
    ToolKind.line => _shapeTool(Shape.line),
    ToolKind.rectangle => _shapeTool(Shape.rectangle),
    ToolKind.circle => _shapeTool(Shape.ellipse),
    ToolKind.arrow => _shapeTool(Shape.arrow),
    ToolKind.text || ToolKind.colorPicker || ToolKind.select => null,
  };

  ShapeTool _shapeTool(Shape shape) => ShapeTool(
    shape: shape,
    width: _penSize,
    tip: _toolKind.hasTip ? _penTip : BrushTip.circle,
    origin: _strokeOrigin,
    constrained: _shapeConstrained,
    centered: _shapeCentered,
    outlined: !_toolKind.hasFill || _shapeOutlined,
    fillColor: _toolKind.hasFill && _shapeFilled ? _fillColor : null,
  );

  PixelColor get _fillColor => switch (_strokeButton) {
    PointerButton.primary => _secondaryColor,
    PointerButton.secondary => _primaryColor,
  };

  ToolPreset? _presetWith({
    required ToolKind kind,
    required PixelColor color,
    required PixelColor secondaryColor,
  }) {
    if (!kind.presettable) return null;
    return ToolPreset.configured(
      kind: kind,
      color: color,
      secondaryColor: secondaryColor,
      shapeOutlined: _shapeOutlined,
      shapeFilled: _shapeFilled,
      size: _penSize,
      tip: _penTip,
      textFormat: _textFormat,
    );
  }

  void _usePreset(ToolPreset? preset) {
    if (preset != null) document.toolPresets = document.toolPresets.use(preset);
  }

  void applyToolPreset({required int index}) {
    final presets = toolPresets;
    if (index >= presets.length || _strokePoint != null) return;
    final preset = presets[index];
    unawaited(commitText());
    if (preset.color case final color?) _primaryColor = color;
    if (preset.secondaryColor case final color?) _secondaryColor = color;
    if (preset.tip case final tip?) _penTip = tip;
    if (preset.size case final size?) _penSize = size;
    if (preset.textFormat case final format?) _textFormat = format;
    if (preset.kind.hasFill) {
      _shapeOutlined = preset.color != null;
      _shapeFilled = preset.secondaryColor != null;
    }
    selectTool(preset.kind);
  }

  void applyLockedToolPreset({required int index}) {
    if (document.toolPresets.isLocked(index: index)) {
      applyToolPreset(index: index);
    }
  }

  void stepToolPreset({required bool forward}) {
    final ToolPresets(:locked, :recent) = document.toolPresets;
    if (recent.isEmpty) return;
    final current = recent.indexWhere((preset) => preset == toolPreset);
    final index = switch (current) {
      < 0 => forward ? 0 : -1,
      _ => current + (forward ? 1 : -1),
    };
    applyToolPreset(index: locked.length + index % recent.length);
  }

  void setToolPresetLocked({required int index, required bool locked}) {
    document.toolPresets = locked
        ? document.toolPresets.lock(index: index)
        : document.toolPresets.unlock(index: index);
    notifyListeners();
  }

  void changeTemporarily(VoidCallback change) {
    final settings = _temporarySettings ?? _captureSettings();
    change();
    _temporarySettings = settings;
  }

  _ToolSettings _captureSettings() => (
    toolKind: _toolKind,
    drawingToolKind: _drawingToolKind,
    primaryColor: _primaryColor,
    secondaryColor: _secondaryColor,
    penSize: _penSize,
    penTip: _penTip,
    shapeOutlined: _shapeOutlined,
    shapeFilled: _shapeFilled,
    textFormat: _textFormat,
  );

  void _revertTemporarySettings() {
    final settings = _temporarySettings;
    if (settings == null) return;
    _temporarySettings = null;
    _toolKind = settings.toolKind;
    _drawingToolKind = settings.drawingToolKind;
    _primaryColor = settings.primaryColor;
    _secondaryColor = settings.secondaryColor;
    _penSize = settings.penSize;
    _penTip = settings.penTip;
    _shapeOutlined = settings.shapeOutlined;
    _shapeFilled = settings.shapeFilled;
    _textFormat = settings.textFormat;
  }

  void _revertFinishedSelection() {
    if (_temporarySettings == null || _toolKind != ToolKind.select) {
      _temporarySelectionMade = false;
      return;
    }
    if (_strokePoint != null) return;
    if (_selection != null) {
      _temporarySelectionMade = true;
    } else if (_temporarySelectionMade) {
      _revertTemporarySettings();
    }
  }

  void selectTool(ToolKind toolKind) {
    if (_strokePoint != null) return;
    _temporarySettings = null;
    unawaited(commitText());
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

  void stepToolSize({required bool larger}) {
    if (!_toolKind.hasSize) return;
    setPenSize(larger ? largerToolSize(_penSize) : smallerToolSize(_penSize));
  }

  void holdColorPicker({required bool held}) {
    if (held == _colorPickerHeld) return;
    _colorPickerHeld = held;
    if (_strokePoint != null) return;
    _toolKind = held ? ToolKind.colorPicker : _drawingToolKind;
    notifyListeners();
  }

  void setShapeOutlined(bool outlined) {
    if (!outlined && !_shapeFilled) return;
    _shapeOutlined = outlined;
    notifyListeners();
  }

  void setShapeFilled(bool filled) {
    if (!filled && !_shapeOutlined) return;
    _shapeFilled = filled;
    notifyListeners();
  }

  void setTextFormat(TextFormat format) {
    if (!format.filled && !format.outlined) return;
    _textFormat = format;
    notifyListeners();
  }

  void moveText({required int offsetX, required int offsetY}) {
    final origin = _textOrigin;
    if (origin == null) return;
    _textOrigin = PixelPoint(x: origin.x + offsetX, y: origin.y + offsetY);
    notifyListeners();
  }

  void editText(String text) => _text = text;

  Future<void> commitText() async {
    final origin = _textOrigin;
    if (origin == null) return;
    final stamp = TextStamp(
      text: _text,
      format: _textFormat,
      color: textColor,
      outlineColor: textOutlineColor,
    );
    final preset = _presetWith(
      kind: ToolKind.text,
      color: textColor,
      secondaryColor: textOutlineColor,
    );
    _textOrigin = null;
    _text = '';
    if (stamp.text.isEmpty) {
      notifyListeners();
      return;
    }
    _usePreset(preset);
    _revertTemporarySettings();
    notifyListeners();
    final orientation = _textOrientation;
    final image = orientation.apply(await stamp.rasterize());
    final before = Layer.copyOf(document.activeLayer);
    document.activeLayer.composite(source: image, at: origin);
    _record(
      name: 'Text',
      before: before,
      area: PixelRectangle(
        left: origin.x,
        top: origin.y,
        width: image.width,
        height: image.height,
      ).intersection(document.activeLayer.bounds),
    );
    notifyListeners();
  }

  void _pressText({required PixelPoint point, required PointerButton button}) {
    if (_textOrigin != null) {
      unawaited(commitText());
      return;
    }
    _textOrigin = point;
    _textButton = button;
    _textOrientation = const TextOrientation();
    notifyListeners();
  }

  void holdShapeConstraint({required bool held}) {
    if (held == _shapeConstrained) return;
    _shapeConstrained = held;
    _redrawStroke();
  }

  void holdShapeCentered({required bool held}) {
    if (held == _shapeCentered) return;
    _shapeCentered = held;
    _redrawStroke();
  }

  void _redrawStroke() {
    final strokePoint = _strokePoint;
    if (strokePoint == null) return;
    _movePointer(point: strokePoint, color: _strokeColor);
  }

  void setLayerVisibility({required int index, required bool visible}) {
    _changeStructure(
      name: visible ? 'Show layer' : 'Hide layer',
      changedLayerIndex: index,
      change: () => document.layers[index] = document.layers[index].copyWith(
        visible: visible,
      ),
    );
  }

  void previewLayerOpacity({required int index, required int opacity}) {
    _structureBeforePreview ??= DocumentStructure.capture(document: document);
    document.layers[index] = document.layers[index].copyWith(opacity: opacity);
    notifyListeners();
  }

  void setLayerOpacity({required int index, required int opacity}) {
    final before = _endPreview();
    if (before.layers[index].opacity == opacity) {
      before.restore(document);
      notifyListeners();
      return;
    }
    _changeStructure(
      name: 'Layer opacity',
      before: before,
      changedLayerIndex: index,
      change: () => document.layers[index] = document.layers[index].copyWith(
        opacity: opacity,
      ),
    );
  }

  void setLayerTimeframe({
    required int index,
    required LayerTimeframe timeframe,
  }) {
    final layer = document.layers[index];
    if (layer.timeframe == timeframe) return;
    _changeStructure(
      name: timeframe.label,
      changedLayerIndex: index,
      change: () {
        _selection = null;
        document.layers[index] = layer.copyWith(
          timeframe: timeframe,
          images: switch (timeframe) {
            LayerTimeframe.constant => [
              layer.imageAt(document.activeFrameIndex),
            ],
            LayerTimeframe.perFrame => [
              for (var frame = 0; frame < document.frameCount; frame++)
                Layer.copyOf(layer.images.first),
            ],
          },
        );
      },
    );
  }

  void selectFrame(int index) {
    if (_strokePoint != null) return;
    _selection = null;
    document.activeFrameIndex = index;
    notifyListeners();
  }

  void stepFrame({required bool forward}) {
    final shown = document.shownFrames;
    final active = document.activeFrameIndex;
    selectFrame(
      forward
          ? shown.firstWhere(
              (frame) => frame > active,
              orElse: () => shown.first,
            )
          : shown.lastWhere(
              (frame) => frame < active,
              orElse: () => shown.last,
            ),
    );
  }

  void selectFirstFrame() => selectFrame(document.shownFrames.first);

  void selectLastFrame() => selectFrame(document.shownFrames.last);

  void addFrame() {
    _insertFrame(
      name: 'Add frame',
      holds: 1,
      image: (images) => Layer.filled(
        width: document.width,
        height: document.height,
        color: PixelColor.transparent,
      ),
    );
  }

  void copyFrame() {
    final source = document.activeFrameIndex;
    _insertFrame(
      name: 'Copy frame',
      holds: document.frameHolds[source],
      image: (images) => Layer.copyOf(images[source]),
    );
  }

  void _insertFrame({
    required String name,
    required int holds,
    required Layer Function(List<Layer> images) image,
  }) {
    _changeStructure(
      name: name,
      change: () {
        _selection = null;
        final index = document.activeFrameIndex + 1;
        _changePerFrameImages((images) => images.insert(index, image(images)));
        document.frameHolds = List.of(document.frameHolds)
          ..insert(index, holds);
        document.activeFrameIndex = index;
      },
    );
  }

  void removeFrame() {
    if (!canRemoveFrame) return;
    _changeStructure(
      name: 'Remove frame',
      change: () {
        _selection = null;
        final index = document.activeFrameIndex;
        _changePerFrameImages((images) => images.removeAt(index));
        _changeHolds((holds) => holds.removeAt(index));
        document.activeFrameIndex = max(0, index - 1);
      },
    );
  }

  void moveFrame({required bool up}) {
    if (!(up ? canMoveFrameUp : canMoveFrameDown)) return;
    _changeStructure(
      name: up ? 'Move frame up' : 'Move frame down',
      change: () {
        _selection = null;
        final index = document.activeFrameIndex;
        final target = index + (up ? -1 : 1);
        void move<T>(List<T> items) =>
            items.insert(target, items.removeAt(index));
        _changePerFrameImages(move);
        _changeHolds(move);
        document.activeFrameIndex = target;
      },
    );
  }

  void setFrameHolds({required int index, required int holds}) {
    final clamped = holds.clamp(
      Document.minimumHolds(frame: index),
      Document.maximumHolds,
    );
    if (document.frameHolds[index] == clamped) return;
    _changeStructure(
      name: 'Frame holds',
      change: () => _changeHolds((holds) => holds[index] = clamped),
    );
  }

  void setFps(int fps) {
    final clamped = fps.clamp(Document.minimumFps, Document.maximumFps);
    if (document.fps == clamped) return;
    _changeStructure(name: 'Frame rate', change: () => document.fps = clamped);
  }

  void setPlaying(bool playing) {
    _playing = playing;
    notifyListeners();
  }

  void setOnionSkin(OnionSkin onionSkin) {
    _onionSkin = onionSkin;
    notifyListeners();
  }

  void _changeHolds(void Function(List<int> holds) change) {
    final holds = List.of(document.frameHolds);
    change(holds);
    holds.first = max(holds.first, Document.minimumHolds(frame: 0));
    document.frameHolds = holds;
  }

  void _changePerFrameImages(void Function(List<Layer> images) change) {
    for (var index = 0; index < document.layers.length; index++) {
      final layer = document.layers[index];
      if (layer.timeframe == LayerTimeframe.constant) continue;
      final images = List.of(layer.images);
      change(images);
      document.layers[index] = layer.copyWith(images: images);
    }
  }

  DocumentStructure _endPreview() {
    final before =
        _structureBeforePreview ??
        DocumentStructure.capture(document: document);
    _structureBeforePreview = null;
    return before;
  }

  void selectLayer(int index) {
    if (_strokePoint != null) return;
    _selection = null;
    document.activeLayerIndex = index;
    notifyListeners();
  }

  void stepLayer({required bool up}) {
    if (!(up ? canMoveLayerUp : canMoveLayerDown)) return;
    selectLayer(document.activeLayerIndex + (up ? 1 : -1));
  }

  void addLayer() {
    _changeStructure(
      name: 'Add layer',
      change: () {
        _selection = null;
        _insertLayer();
      },
    );
  }

  void copyLayer() {
    _changeStructure(
      name: 'Copy layer',
      change: () {
        _selection = null;
        final source = document.layers[document.activeLayerIndex];
        final index = document.activeLayerIndex + 1;
        document.layers.insert(
          index,
          source.copyWith(
            name: '${source.name} copy',
            images: [for (final image in source.images) Layer.copyOf(image)],
          ),
        );
        document.activeLayerIndex = index;
      },
    );
  }

  Layer _insertLayer() {
    _layerCount++;
    final pixels = Layer.filled(
      width: document.width,
      height: document.height,
      color: PixelColor.transparent,
    );
    final index = document.activeLayerIndex + 1;
    document.layers.insert(
      index,
      DocumentLayer(name: 'Layer $_layerCount', images: [pixels]),
    );
    document.activeLayerIndex = index;
    return pixels;
  }

  void removeLayer() {
    if (!canRemoveLayer) return;
    _changeStructure(
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
    _changeStructure(
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

  void resizeImage({
    required int width,
    required int height,
    required PixelPoint offset,
  }) {
    if (width == document.width &&
        height == document.height &&
        offset == const PixelPoint(x: 0, y: 0)) {
      return;
    }
    _resize(name: 'Resize image', width: width, height: height, offset: offset);
  }

  void cropToSelection() {
    final area = _selection?.area.intersection(document.activeLayer.bounds);
    if (area == null || area.isEmpty) return;
    _resize(
      name: 'Crop',
      width: area.width,
      height: area.height,
      offset: PixelPoint(x: -area.left, y: -area.top),
    );
  }

  void _resize({
    required String name,
    required int width,
    required int height,
    required PixelPoint offset,
  }) {
    _changeStructure(
      name: name,
      change: () {
        _selection = null;
        for (var index = 0; index < document.layers.length; index++) {
          final layer = document.layers[index];
          document.layers[index] = layer.copyWith(
            images: [
              for (final image in layer.images)
                Layer.resized(
                  layer: image,
                  width: width,
                  height: height,
                  offset: offset,
                ),
            ],
          );
        }
        document.width = width;
        document.height = height;
      },
    );
    _fitPointerPreview();
  }

  void _fitPointerPreview() =>
      pointerPreview.resize(width: document.width, height: document.height);

  void _changeStructure({
    required String name,
    required VoidCallback change,
    DocumentStructure? before,
    int? changedLayerIndex,
  }) {
    if (_strokePoint != null) return;
    before ??= DocumentStructure.capture(document: document);
    change();
    history.record(
      StructureHistoryEntry(
        name: name,
        before: before,
        after: DocumentStructure.capture(document: document),
        thumbnail: Layer.thumbnail(
          layer: document.layers[changedLayerIndex ?? document.activeLayerIndex]
              .imageAt(document.activeFrameIndex),
          maximumSize: History.thumbnailSize,
        ),
      ),
    );
    notifyListeners();
  }

  void setZoom(Zoom zoom) {
    _zoom = zoom;
    notifyListeners();
  }

  void editPrimary({required bool primary}) {
    _editingPrimary = primary;
    notifyListeners();
  }

  void swapColors() {
    final primary = _primaryColor;
    _primaryColor = _secondaryColor;
    _secondaryColor = primary;
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
    _structureBeforePreview = null;
    history.jumpTo(position);
    _fitPointerPreview();
    notifyListeners();
  }

  void pointerDown({required PixelPoint point, required PointerButton button}) {
    if (_toolKind == ToolKind.text) {
      _pressText(point: point, button: button);
      return;
    }
    _strokeColor = switch (button) {
      PointerButton.primary => _primaryColor,
      PointerButton.secondary => _secondaryColor,
    };
    _strokeButton = button;
    _strokeOrigin = point;
    _strokeName = _toolKind.label;
    _usePreset(
      _presetWith(
        kind: _toolKind,
        color: _strokeColor,
        secondaryColor: _fillColor,
      ),
    );
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
      _redrawPointer(point: point, color: _primaryColor);
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
    _redrawPointer(point: point, color: _strokeColor);
    if (_toolKind == ToolKind.colorPicker) {
      notifyListeners();
    } else {
      _strokeProgress.advance();
    }
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
    if (_tool != null) _revertTemporarySettings();
    if (_toolKind == ToolKind.colorPicker && !_colorPickerHeld) {
      _toolKind = _drawingToolKind;
    }
    notifyListeners();
  }

  void pointerExit() => pointerPreview.clear();

  void selectAll() {
    if (_strokePoint != null) return;
    unawaited(commitText());
    _toolKind = ToolKind.select;
    _drawingToolKind = ToolKind.select;
    _selection = Selection.lift(
      layer: document.activeLayer,
      area: document.activeLayer.bounds,
    );
    notifyListeners();
  }

  void deselect() {
    if (_strokePoint != null) return;
    _selection = null;
    notifyListeners();
  }

  void deleteSelection() => _eraseSelection(name: 'Delete selection');

  void cutSelection() => _eraseSelection(name: 'Cut');

  void _eraseSelection({required String name}) {
    final selection = _selection;
    if (selection == null || _strokePoint != null) return;
    final before = Layer.copyOf(document.activeLayer);
    document.activeLayer.fillRectangle(
      rectangle: selection.area,
      color: PixelColor.transparent,
    );
    _selection = null;
    _record(name: name, before: before, area: selection.area);
    notifyListeners();
  }

  void paste({required Layer image, required PixelPoint center}) {
    if (_strokePoint != null) return;
    unawaited(commitText());
    _toolKind = ToolKind.select;
    _drawingToolKind = ToolKind.select;
    final area = _selection?.area;
    final placement = area == null
        ? PixelRectangle(
            left: center.x - image.width ~/ 2,
            top: center.y - image.height ~/ 2,
            width: image.width,
            height: image.height,
          )
        : PixelRectangle(
            left: area.left + (area.width - image.width) ~/ 2,
            top: area.top + (area.height - image.height) ~/ 2,
            width: image.width,
            height: image.height,
          );
    final clipped = area == null ? placement : placement.intersection(area);
    final before = Layer.copyOf(document.activeLayer);
    final pasted = Selection.pasted(
      layer: document.activeLayer,
      content: Layer.cropped(
        layer: image,
        area: PixelRectangle(
          left: clipped.left - placement.left,
          top: clipped.top - placement.top,
          width: clipped.width,
          height: clipped.height,
        ),
      ),
      at: PixelPoint(x: clipped.left, y: clipped.top),
    );
    _selection = pasted;
    _record(name: 'Paste', before: before, area: pasted.area);
    notifyListeners();
  }

  void rotateSelection({required bool clockwise}) {
    if (_textOrigin != null) {
      _orientText(_textOrientation.rotate(clockwise: clockwise));
      return;
    }
    _transformSelection(
      name: clockwise ? 'Rotate right' : 'Rotate left',
      transform: (selection) =>
          selection.rotated(layer: document.activeLayer, clockwise: clockwise),
    );
  }

  void mirrorSelection({required bool horizontally}) {
    if (_textOrigin != null) {
      _orientText(_textOrientation.mirror(horizontally: horizontally));
      return;
    }
    _transformSelection(
      name: horizontally ? 'Mirror horizontally' : 'Mirror vertically',
      transform: (selection) => selection.mirrored(
        layer: document.activeLayer,
        horizontally: horizontally,
      ),
    );
  }

  void moveSelection({required int offsetX, required int offsetY}) =>
      _transformSelection(
        name: 'Move selection',
        transform: (selection) => selection.moved(
          layer: document.activeLayer,
          offsetX: offsetX,
          offsetY: offsetY,
        ),
      );

  void _orientText(TextOrientation orientation) {
    _textOrientation = orientation;
    notifyListeners();
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
    final entry = PixelHistoryEntry.recorded(
      name: name,
      layerIndex: document.activeLayerIndex,
      frameIndex: document.activeFrameIndex,
      before: LayerSnapshot.capture(layer: before, area: area),
      after: LayerSnapshot.capture(layer: document.activeLayer, area: area),
      thumbnail: Layer.thumbnail(
        layer: document.activeLayer,
        maximumSize: History.thumbnailSize,
      ),
      canvasWidth: document.width,
      canvasHeight: document.height,
    );
    if (entry.before != entry.after) history.record(entry);
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
    pointerPreview.draw(tool: _tool, point: point, color: color);
  }
}

typedef _ToolSettings = ({
  ToolKind toolKind,
  ToolKind drawingToolKind,
  PixelColor primaryColor,
  PixelColor secondaryColor,
  int penSize,
  BrushTip penTip,
  bool shapeOutlined,
  bool shapeFilled,
  TextFormat textFormat,
});

class _StrokeProgress extends ChangeNotifier {
  void advance() => notifyListeners();
}
