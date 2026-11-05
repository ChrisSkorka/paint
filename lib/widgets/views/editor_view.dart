import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/canvas/pixel_color.dart';
import '../../editor/canvas/pixel_point.dart';
import '../../editor/editor_controller.dart';
import '../../editor/editor_shortcut.dart';
import '../../editor/files/document_library.dart';
import '../../editor/files/export_format.dart';
import '../../editor/files/file_access.dart';
import '../../editor/files/file_location.dart';
import '../../editor/files/frame_clipboard.dart';
import '../../editor/files/image_clipboard.dart';
import '../../editor/files/save_status.dart';
import '../../editor/canvas/layer.dart';
import '../../editor/history/history.dart';
import '../../editor/history/history_entry.dart';
import '../../editor/history/multi_frame_history_entry.dart';
import '../../editor/history/pixel_history_entry.dart';
import '../../editor/pointer_button.dart';
import '../../editor/selection/selection_clip.dart';
import '../../editor/tools/brush_tip.dart';
import '../../editor/tools/color_palettes.dart';
import '../../editor/tools/text_format.dart';
import '../../editor/tools/text_stamp.dart';
import '../../editor/tools/tool_kind.dart';
import '../../editor/tools/tool_size.dart';
import '../../editor/zoom.dart';
import '../components/canvas_margin.dart';
import '../components/canvas_scroll_controller.dart';
import '../components/color_dialog.dart';
import '../components/edge_shadow.dart';
import '../components/exponential_scale.dart';
import '../components/frame_list.dart';
import '../components/history_list.dart';
import '../components/horizontal_scroll_view.dart';
import '../components/layer_list.dart';
import '../components/pixel_canvas.dart';
import '../components/resize_dialog.dart';
import '../components/number_stepper.dart';
import '../components/numeric_value_range.dart';
import '../components/paint_bar.dart';
import '../components/paint_icon_button.dart';
import '../components/paint_scroll_behavior.dart';
import '../components/paint_split_button.dart';
import '../components/paint_status_button.dart';
import '../components/paint_style.dart';
import '../components/ribbon_section.dart';
import '../components/side_pane.dart';
import '../components/stable_text.dart';
import '../components/swatch_grid.dart';
import '../components/text_draft.dart';
import '../components/text_input_dialog.dart';
import '../components/timeline.dart';
import '../components/tool_icons.dart';
import '../components/tool_preset_list.dart';
import '../components/zero_intrinsic_width.dart';

class EditorView extends StatefulWidget {
  const EditorView({
    super.key,
    required this.document,
    required this.clipboard,
    required this.files,
    required this.library,
    this.frameClipboard,
    this.active = true,
    this.fitOnOpen = false,
    this.onUnsavedChanged,
    this.onRenamed,
  });

  final Document document;
  final ImageClipboard clipboard;
  final FileAccess files;
  final DocumentLibrary library;
  final FrameClipboard? frameClipboard;
  final bool active;
  final bool fitOnOpen;
  final ValueChanged<bool>? onUnsavedChanged;
  final VoidCallback? onRenamed;

  static const canvasEdge = 15.0;
  static const canvasVisible = 48.0;
  static const penSizeWidth = 56.0;
  static const scaleZoomThreshold = 0.03;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late final controller = EditorController.forDocument(
    document: widget.document,
  );
  late final frameClipboard = widget.frameClipboard ?? FrameClipboard();
  var exportFormat = ExportFormat.png;
  Timer? playback;
  final focusNode = FocusNode(debugLabel: 'Editor');
  final verticalScroll = CanvasScrollController(
    restingPosition: EditorView.canvasEdge,
  );
  final horizontalScroll = CanvasScrollController(
    restingPosition: EditorView.canvasEdge,
  );
  final canvasAreaKey = GlobalKey();
  final pixelCanvasKey = GlobalKey();
  Offset? canvasAreaPointer;
  var unsaved = false;
  var textDrag = Offset.zero;
  var scaleZoomProgress = 0.0;
  late var awaitingFit = widget.fitOnOpen;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_reclaimFocus);
    controller.addListener(_reportUnsaved);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusWhenActive());
    if (awaitingFit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitOnOpen());
    }
  }

  @override
  void didUpdateWidget(EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active) _focusWhenActive();
  }

  @override
  void reassemble() {
    super.reassemble();
    _focusWhenActive();
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_reclaimFocus);
    focusNode.dispose();
    verticalScroll.dispose();
    horizontalScroll.dispose();
    playback?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _reportUnsaved() {
    if (controller.hasUnsavedChanges == unsaved) return;
    unsaved = controller.hasUnsavedChanges;
    widget.onUnsavedChanged?.call(unsaved);
  }

  void _focusWhenActive() {
    if (mounted && widget.active) focusNode.requestFocus();
  }

  void _reclaimFocus() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null && focusNode.ancestors.contains(primaryFocus)) {
      _focusWhenActive();
    }
  }

  void _togglePlayback() {
    if (controller.playing) {
      _stopPlayback();
      return;
    }
    controller.setPlaying(true);
    _scheduleNextFrame();
  }

  void _scheduleNextFrame() {
    playback = Timer(
      widget.document.frameDuration(frame: widget.document.activeFrameIndex),
      () {
        controller.stepFrame(forward: true);
        _scheduleNextFrame();
      },
    );
  }

  void _stopPlayback() {
    playback?.cancel();
    playback = null;
    controller.setPlaying(false);
  }

  void _pointerDown({
    required PixelPoint point,
    required PointerButton button,
  }) {
    if (controller.playing) _stopPlayback();
    controller.pointerDown(point: point, button: button);
  }

  void _selectColor(Color color) =>
      controller.selectColor(PixelColor(argb: color.toARGB32()));

  VoidCallback _temporarily(VoidCallback change) =>
      () => controller.changeTemporarily(change);

  ValueChanged<T> _temporarilyWith<T>(ValueChanged<T> change) =>
      (value) => controller.changeTemporarily(() => change(value));

  Future<void> _editColor() async {
    final color = await showColorDialog(
      context: context,
      initialColor: controller.editedColor,
    );
    if (color != null) controller.selectColor(color);
  }

  List<List<Color>> _toColors(List<List<PixelColor>> palette) => [
    for (final row in palette) [for (final color in row) Color(color.argb)],
  ];

  Widget _tipButton({required BrushTip tip, required String tooltip}) {
    return PaintIconButton(
      icon: tipIcon(tip: tip),
      tooltip: tooltip,
      selected: controller.penTip == tip,
      onPressed: controller.toolKind.hasTip
          ? () => controller.setPenTip(tip)
          : null,
      onRightClick: _temporarily(() => controller.setPenTip(tip)),
    );
  }

  Widget _shapeButton({
    required ToolKind toolKind,
    required EditorShortcut shortcut,
  }) {
    return PaintIconButton(
      icon: toolIcon(kind: toolKind),
      tooltip: toolKind.label,
      shortcut: shortcut.keys,
      color: PaintStyle.shapeColor,
      selected: controller.toolKind == toolKind,
      onPressed: () => controller.selectTool(toolKind),
      onRightClick: _temporarily(() => controller.selectTool(toolKind)),
    );
  }

  VoidCallback? _whenSelected(VoidCallback action) =>
      controller.hasSelection ? action : null;

  VoidCallback? _whenTransformable(VoidCallback action) =>
      controller.canTransform ? action : null;

  MouseCursor _canvasCursor() {
    if (controller.pointerOverSelection) return SystemMouseCursors.move;
    if (controller.toolKind == ToolKind.text) return SystemMouseCursors.text;
    return SystemMouseCursors.basic;
  }

  String _cursorText() {
    final cursor = controller.cursor;
    return cursor == null ? '-' : '${cursor.x}, ${cursor.y}';
  }

  String _sizeText() {
    final offset = controller.dragOffset;
    if (offset == null) {
      return '${widget.document.width} × ${widget.document.height}';
    }
    return '${offset.x} × ${offset.y}';
  }

  List<HistoryListItem> _historyItems() => [
    HistoryListItem(
      name: 'Start',
      thumbnail: controller.history.startThumbnail,
      outline: null,
    ),
    for (final entry in controller.history.entries)
      HistoryListItem(
        name: entry.name,
        thumbnail: entry.thumbnail,
        outline: _thumbnailOutline(entry),
      ),
  ];

  List<LayerListItem> _layerItems() => [
    for (final layer in widget.document.layers)
      LayerListItem(
        name: layer.name,
        thumbnail: Layer.thumbnail(
          layer: layer.imageAt(widget.document.activeFrameIndex),
          maximumSize: History.thumbnailSize,
        ),
        visible: layer.visible,
        opacity: layer.opacity,
        timeframe: layer.timeframe,
      ),
  ];

  Rect? _thumbnailOutline(HistoryEntry entry) {
    final outline = switch (entry) {
      PixelHistoryEntry() => entry.outline,
      MultiFrameHistoryEntry() => entry.outline,
      _ => null,
    };
    if (outline == null) return null;
    final width = entry.thumbnail.width;
    final height = entry.thumbnail.height;
    return Rect.fromLTRB(
      outline.left * width,
      outline.top * height,
      outline.right * width,
      outline.bottom * height,
    );
  }

  Future<void> _resizeImage() async {
    unawaited(controller.commitText());
    final resize = await showResizeDialog(
      context: context,
      image: widget.document.flatten(
        background: PixelColor.transparent,
        frame: widget.document.activeFrameIndex,
      ),
    );
    if (resize == null) return;
    controller.resizeImage(
      width: resize.width,
      height: resize.height,
      offset: resize.offset,
    );
  }

  Future<void> _renameDocument() async {
    final name = await showTextInputDialog(
      context: context,
      title: 'Rename document',
      label: 'Name',
      initialText: widget.document.name,
    );
    if (name == null) return;
    controller.rename(name: name);
    widget.onRenamed?.call();
  }

  Future<void> _renameLayer() async {
    final name = await showTextInputDialog(
      context: context,
      title: 'Rename layer',
      label: 'Name',
      initialText:
          widget.document.layers[widget.document.activeLayerIndex].name,
    );
    if (name == null) return;
    controller.renameLayer(name: name);
  }

  Future<void> _copySelection() async {
    final clip = controller.selectionClip;
    if (clip != null) await _writeClip(clip);
  }

  Future<void> _cutSelection() async {
    final clip = controller.selectionClip;
    controller.cutSelection();
    if (clip != null) await _writeClip(clip);
  }

  Future<void> _writeClip(SelectionClip clip) =>
      frameClipboard.write(system: widget.clipboard, clip: clip);

  Future<void> _paste() async {
    final clip = await frameClipboard.read(system: widget.clipboard);
    if (clip != null && mounted) {
      controller.paste(clip: clip, center: _pasteCenter());
    }
  }

  PixelPoint _pasteCenter() {
    final area = _canvasAreaBox();
    final canvas =
        pixelCanvasKey.currentContext!.findRenderObject()! as RenderBox;
    final viewportCenter = Offset(
      (area.size.width - PaintScrollBehavior.scrollbarTrack) / 2,
      (area.size.height - PaintScrollBehavior.scrollbarTrack) / 2,
    );
    final position =
        canvas.globalToLocal(
          canvasAreaPointer ?? area.localToGlobal(viewportCenter),
        ) /
        controller.zoom.scale;
    return PixelPoint(x: position.dx.floor(), y: position.dy.floor());
  }

  Future<void> _save() async {
    final point = controller.history.point;
    final name = widget.document.name;
    final saved = await _attempt(
      failure: 'Could not save',
      action: () => widget.library.save(document: widget.document),
    );
    if (saved && mounted) controller.markSaved(point: point, name: name);
  }

  String? get _exportPath => switch (widget.document.filePath) {
    final path? when exportFormat.matches(path: path) => path,
    _ => null,
  };

  Future<void> _exportAgain() async {
    final path = _exportPath;
    if (path == null) return _exportAs(exportFormat);
    await _attempt(
      failure: 'Could not export',
      action: () => widget.files.overwrite(
        path: path,
        format: exportFormat,
        bytes: exportFormat.encode(document: widget.document),
      ),
    );
  }

  Future<void> _exportAs(ExportFormat format) async {
    setState(() => exportFormat = format);
    final directory = switch (widget.document.filePath) {
      final path? => directoryOf(path: path),
      null => widget.library.recentDirectory,
    };
    await _attempt(
      failure: 'Could not export',
      action: () async {
        final path = await widget.files.saveAs(
          fileName: format.fileName(document: widget.document),
          directory: directory,
          format: format,
          bytes: format.encode(document: widget.document),
        );
        if (path != null && mounted) {
          setState(() => widget.document.filePath = path);
        }
      },
    );
  }

  Future<bool> _attempt({
    required String failure,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
      return true;
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure)));
      }
      return false;
    }
  }

  void _toggleOnionSkin() => controller.setOnionSkin(
    controller.onionSkin.copyWith(enabled: !controller.onionSkin.enabled),
  );

  void _stepHolds({required bool more}) {
    final frame = widget.document.activeFrameIndex;
    controller.setFrameHolds(
      index: frame,
      holds: widget.document.frameHolds[frame] + (more ? 1 : -1),
    );
  }

  late final _shortcutActions = <EditorShortcut, VoidCallback>{
    EditorShortcut.save: _save,
    EditorShortcut.export: _exportAgain,
    EditorShortcut.undo: controller.undo,
    EditorShortcut.redo: controller.redo,
    EditorShortcut.copy: _copySelection,
    EditorShortcut.cut: _cutSelection,
    EditorShortcut.paste: _paste,
    EditorShortcut.selectAll: controller.selectAll,
    EditorShortcut.deleteSelection: controller.deleteSelection,
    EditorShortcut.deselect: controller.deselect,
    EditorShortcut.pen: () => controller.selectTool(ToolKind.pen),
    EditorShortcut.eraser: () => controller.selectTool(ToolKind.eraser),
    EditorShortcut.fill: () => controller.selectTool(ToolKind.bucketFill),
    EditorShortcut.colorPicker: () =>
        controller.selectTool(ToolKind.colorPicker),
    EditorShortcut.select: () => controller.selectTool(ToolKind.select),
    EditorShortcut.text: () => controller.selectTool(ToolKind.text),
    EditorShortcut.line: () => controller.selectTool(ToolKind.line),
    EditorShortcut.rectangle: () => controller.selectTool(ToolKind.rectangle),
    EditorShortcut.circle: () => controller.selectTool(ToolKind.circle),
    EditorShortcut.arrow: () => controller.selectTool(ToolKind.arrow),
    EditorShortcut.nextToolPreset: () =>
        controller.stepToolPreset(forward: true),
    EditorShortcut.previousToolPreset: () =>
        controller.stepToolPreset(forward: false),
    EditorShortcut.smallerSize: () => controller.stepToolSize(larger: false),
    EditorShortcut.largerSize: () => controller.stepToolSize(larger: true),
    EditorShortcut.swapColors: controller.swapColors,
    EditorShortcut.zoomIn: () => _stepZoom(larger: true),
    EditorShortcut.zoomOut: () => _stepZoom(larger: false),
    EditorShortcut.resetZoom: _zoomToFit,
    EditorShortcut.previousFrame: () => controller.stepFrame(forward: false),
    EditorShortcut.nextFrame: () => controller.stepFrame(forward: true),
    EditorShortcut.firstFrame: controller.selectFirstFrame,
    EditorShortcut.lastFrame: controller.selectLastFrame,
    EditorShortcut.playPause: _togglePlayback,
    EditorShortcut.onionSkinning: _toggleOnionSkin,
    EditorShortcut.addFrame: controller.addFrame,
    EditorShortcut.copyFrame: controller.copyFrame,
    EditorShortcut.removeFrame: controller.removeFrame,
    EditorShortcut.moveFrameUp: () => controller.moveFrame(up: true),
    EditorShortcut.moveFrameDown: () => controller.moveFrame(up: false),
    EditorShortcut.fewerHolds: () => _stepHolds(more: false),
    EditorShortcut.moreHolds: () => _stepHolds(more: true),
    EditorShortcut.addLayer: controller.addLayer,
    EditorShortcut.copyLayer: controller.copyLayer,
    EditorShortcut.mergeLayerDown: controller.mergeLayerDown,
    EditorShortcut.renameLayer: _renameLayer,
    EditorShortcut.removeLayer: controller.removeLayer,
    EditorShortcut.layerAbove: () => controller.stepLayer(up: true),
    EditorShortcut.layerBelow: () => controller.stepLayer(up: false),
    EditorShortcut.moveLayerUp: () => controller.moveLayer(up: true),
    EditorShortcut.moveLayerDown: () => controller.moveLayer(up: false),
  };

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!widget.active || _editingText()) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.altLeft ||
        event.logicalKey == LogicalKeyboardKey.altRight) {
      if (event is! KeyRepeatEvent) {
        controller.holdColorPicker(held: event is KeyDownEvent);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      controller.holdShapeConstraint(held: event is! KeyUpEvent);
    }
    if (EditorShortcut.primaryModifierKeys.contains(event.logicalKey)) {
      controller.holdShapeCentered(held: event is! KeyUpEvent);
    }
    final shortcut = EditorShortcut.matching(event);
    if (shortcut == null || shortcut.group == ShortcutGroup.tabs) {
      return KeyEventResult.ignored;
    }
    switch (shortcut) {
      case EditorShortcut.toolPreset:
        controller.applyLockedToolPreset(index: shortcut.activatorIndex(event));
      case EditorShortcut.moveSelection:
        _moveSelection(index: shortcut.activatorIndex(event), distance: 1);
      case EditorShortcut.moveSelectionFar:
        _moveSelection(index: shortcut.activatorIndex(event), distance: 10);
      default:
        _shortcutActions[shortcut]!();
    }
    return KeyEventResult.handled;
  }

  static const _arrowDirections = [
    PixelPoint(x: -1, y: 0),
    PixelPoint(x: 1, y: 0),
    PixelPoint(x: 0, y: -1),
    PixelPoint(x: 0, y: 1),
  ];

  void _moveSelection({required int index, required int distance}) {
    final direction = _arrowDirections[index];
    controller.moveSelection(
      offsetX: direction.x * distance,
      offsetY: direction.y * distance,
    );
  }

  bool _editingText() =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: _handleKey,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => _buildEditor(),
      ),
    );
  }

  void _scrollCanvas(PointerSignalEvent event) {
    if (event is PointerScaleEvent) {
      GestureBinding.instance.pointerSignalResolver.register(
        event,
        (_) => _scaleZoom(scale: event.scale, position: event.position),
      );
      return;
    }
    if (event is! PointerScrollEvent || event.scrollDelta.dy == 0) return;
    final forward = event.scrollDelta.dy > 0;
    if (EditorShortcut.primaryModifierPressed) {
      GestureBinding.instance.pointerSignalResolver.register(
        event,
        (_) => _stepZoom(
          larger: !forward,
          focus: _canvasAreaBox().globalToLocal(event.position),
        ),
      );
    } else if (HardwareKeyboard.instance.isAltPressed) {
      GestureBinding.instance.pointerSignalResolver.register(
        event,
        (_) => controller.stepFrame(forward: forward),
      );
    }
  }

  void _scaleZoom({required double scale, required Offset position}) {
    scaleZoomProgress += log(scale);
    if (scaleZoomProgress.abs() < EditorView.scaleZoomThreshold) return;
    final larger = scaleZoomProgress > 0;
    scaleZoomProgress = 0;
    _stepZoom(larger: larger, focus: _canvasAreaBox().globalToLocal(position));
  }

  RenderBox _canvasAreaBox() =>
      canvasAreaKey.currentContext!.findRenderObject()! as RenderBox;

  void _stepZoom({required bool larger, Offset? focus}) =>
      _zoomTo(controller.zoom.stepped(larger: larger), focus: focus);

  void _zoomTo(Zoom zoom, {Offset? focus}) {
    if (zoom.scale == controller.zoom.scale) {
      controller.setZoom(zoom);
      return;
    }
    final area = _canvasAreaBox().size;
    final focusPoint = focus ?? area.center(Offset.zero);
    verticalScroll.pendingOffset = zoomedCanvasOffset(
      available: area.height,
      length: widget.document.height,
      visible: EditorView.canvasVisible,
      scrollbar: PaintScrollBehavior.scrollbarTrack,
      offset: verticalScroll.pendingOffset ?? verticalScroll.offset,
      focus: focusPoint.dy,
      oldScale: controller.zoom.scale,
      newScale: zoom.scale,
    );
    horizontalScroll.pendingOffset = zoomedCanvasOffset(
      available: area.width,
      length: widget.document.width,
      visible: EditorView.canvasVisible,
      scrollbar: PaintScrollBehavior.scrollbarTrack,
      offset: horizontalScroll.pendingOffset ?? horizontalScroll.offset,
      focus: focusPoint.dx,
      oldScale: controller.zoom.scale,
      newScale: zoom.scale,
    );
    controller.setZoom(zoom);
  }

  void _fitOnOpen() {
    _zoomToFit();
    setState(() => awaitingFit = false);
  }

  void _zoomToFit() {
    final area = _canvasAreaBox().size;
    final zoom = Zoom.fitting(
      scale: min(
        fittingScale(
          available: area.width,
          length: widget.document.width,
          edge: EditorView.canvasEdge,
          scrollbar: PaintScrollBehavior.scrollbarTrack,
        ),
        fittingScale(
          available: area.height,
          length: widget.document.height,
          edge: EditorView.canvasEdge,
          scrollbar: PaintScrollBehavior.scrollbarTrack,
        ),
      ),
    );
    final verticalOffset = centeredCanvasOffset(
      available: area.height,
      length: widget.document.height,
      visible: EditorView.canvasVisible,
      scrollbar: PaintScrollBehavior.scrollbarTrack,
      scale: zoom.scale,
    );
    final horizontalOffset = centeredCanvasOffset(
      available: area.width,
      length: widget.document.width,
      visible: EditorView.canvasVisible,
      scrollbar: PaintScrollBehavior.scrollbarTrack,
      scale: zoom.scale,
    );
    if (zoom.scale == controller.zoom.scale) {
      verticalScroll.jumpTo(verticalOffset);
      horizontalScroll.jumpTo(horizontalOffset);
      return;
    }
    verticalScroll.pendingOffset = verticalOffset;
    horizontalScroll.pendingOffset = horizontalOffset;
    controller.setZoom(zoom);
  }

  Widget _buildCanvasArea() {
    return Container(
      color: PaintStyle.canvasAreaBackground,
      child: CustomPaint(
        foregroundPainter: const EdgeShadowPainter(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: awaitingFit ? 0 : 1,
              child: MouseRegion(
                opaque: false,
                onHover: (event) => canvasAreaPointer = event.position,
                onExit: (_) => canvasAreaPointer = null,
                child: LayoutBuilder(
                  key: canvasAreaKey,
                  builder: (context, constraints) {
                    final vertical = canvasMargin(
                      available: constraints.maxHeight,
                      extent: widget.document.height * controller.zoom.scale,
                      visible: EditorView.canvasVisible,
                      scrollbar: PaintScrollBehavior.scrollbarTrack,
                    );
                    final horizontal = canvasMargin(
                      available: constraints.maxWidth,
                      extent: widget.document.width * controller.zoom.scale,
                      visible: EditorView.canvasVisible,
                      scrollbar: PaintScrollBehavior.scrollbarTrack,
                    );
                    verticalScroll.leading = vertical.leading;
                    horizontalScroll.leading = horizontal.leading;
                    return _buildCanvasScrollbars(
                      child: SingleChildScrollView(
                        controller: verticalScroll,
                        child: SingleChildScrollView(
                          controller: horizontalScroll,
                          scrollDirection: Axis.horizontal,
                          child: Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerSignal: _scrollCanvas,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontal.leading,
                                vertical.leading,
                                horizontal.trailing,
                                vertical.trailing,
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: PaintStyle.faintShadow,
                                ),
                                child: Stack(
                                  children: [
                                    ListenableBuilder(
                                      listenable: controller.pointerPreview,
                                      builder: (context, _) => PixelCanvas(
                                        key: pixelCanvasKey,
                                        width: widget.document.width,
                                        height: widget.document.height,
                                        zoom: controller.zoom.scale,
                                        layers: controller.canvasLayers,
                                        pointerPreview:
                                            controller.pointerPreview,
                                        layersChanged: controller.layersChanged,
                                        onPointerDown: _pointerDown,
                                        onPointerMove: controller.pointerMove,
                                        onPointerUp: controller.pointerUp,
                                        onPointerExit: controller.pointerExit,
                                        selection: controller.selectionArea,
                                        cursor: _canvasCursor(),
                                      ),
                                    ),
                                    ?_buildTextDraft(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (awaitingFit)
              const Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(color: PaintStyle.titleColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTextDraft() {
    final origin = controller.textOrigin;
    if (origin == null) return null;
    final scale = controller.zoom.scale;
    final format = controller.textFormat;
    return Positioned(
      left: origin.x * scale - TextDraft.handleWidth,
      top: origin.y * scale - TextDraft.handleWidth,
      child: TextDraft(
        style: format.style(
          scale: scale,
          color: format.filled ? controller.textColor : PixelColor.transparent,
        ),
        outlineStyle: format.outlined
            ? format.outlineStyle(
                scale: scale,
                color: controller.textOutlineColor,
              )
            : null,
        cursorColor: Color(controller.textColor.argb),
        padding: format.padding * scale,
        orientation: controller.textOrientation,
        extentOf: (text) =>
            TextStamp(
              text: text,
              format: format,
              color: controller.textColor,
              outlineColor: controller.textOutlineColor,
            ).extent *
            scale,
        onChanged: controller.editText,
        onMoved: _moveText,
      ),
    );
  }

  void _moveText(Offset delta) {
    textDrag += delta;
    final scale = controller.zoom.scale;
    final offsetX = textDrag.dx ~/ scale;
    final offsetY = textDrag.dy ~/ scale;
    textDrag -= Offset(offsetX * scale, offsetY * scale);
    controller.moveText(offsetX: offsetX, offsetY: offsetY);
  }

  void _setTextFormat({
    int? size,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? filled,
    bool? outlined,
    int? outlineWidth,
  }) => controller.setTextFormat(
    controller.textFormat.copyWith(
      size: size,
      bold: bold,
      italic: italic,
      underline: underline,
      strikethrough: strikethrough,
      filled: filled,
      outlined: outlined,
      outlineWidth: outlineWidth,
    ),
  );

  Widget _buildAllFramesOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          PaintIconButton(
            icon: FontAwesomeIcons.backward,
            tooltip: 'Include previous frames',
            selected: controller.selectingPreviousFrames,
            onPressed: () => controller.setSelectingPreviousFrames(
              !controller.selectingPreviousFrames,
            ),
          ),
          PaintIconButton(
            icon: FontAwesomeIcons.forward,
            tooltip: 'Include next frames',
            selected: controller.selectingNextFrames,
            onPressed: () => controller.setSelectingNextFrames(
              !controller.selectingNextFrames,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextOptions() {
    final format = controller.textFormat;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberStepper(
              value: format.size,
              minimum: TextFormat.minimumSize,
              maximum: TextFormat.maximumSize,
              decreaseTooltip: 'Decrease text size',
              increaseTooltip: 'Increase text size',
              valueWidth: EditorView.penSizeWidth,
              decrement: smallerToolSize,
              increment: largerToolSize,
              onChanged: (size) => _setTextFormat(size: size),
              onRightClickChanged: _temporarilyWith(
                (size) => _setTextFormat(size: size),
              ),
            ),
            ZeroIntrinsicWidth(
              child: SliderTheme(
                data: PaintStyle.sliderTheme,
                child: Slider(
                  value: exponentialPosition(
                    value: format.size,
                    minimum: TextFormat.minimumSize,
                    maximum: TextFormat.maximumSize,
                  ),
                  onChanged: (position) => _setTextFormat(
                    size: roundToolSize(
                      exponentialValue(
                        position: position,
                        minimum: TextFormat.minimumSize,
                        maximum: TextFormat.maximumSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PaintIconButton(
                  icon: FontAwesomeIcons.bold,
                  tooltip: 'Bold',
                  selected: format.bold,
                  onPressed: () => _setTextFormat(bold: !format.bold),
                  onRightClick: _temporarily(
                    () => _setTextFormat(bold: !format.bold),
                  ),
                ),
                PaintIconButton(
                  icon: FontAwesomeIcons.italic,
                  tooltip: 'Italic',
                  selected: format.italic,
                  onPressed: () => _setTextFormat(italic: !format.italic),
                  onRightClick: _temporarily(
                    () => _setTextFormat(italic: !format.italic),
                  ),
                ),
                PaintIconButton(
                  icon: FontAwesomeIcons.underline,
                  tooltip: 'Underline',
                  selected: format.underline,
                  onPressed: () => _setTextFormat(underline: !format.underline),
                  onRightClick: _temporarily(
                    () => _setTextFormat(underline: !format.underline),
                  ),
                ),
                PaintIconButton(
                  icon: FontAwesomeIcons.strikethrough,
                  tooltip: 'Strikethrough',
                  selected: format.strikethrough,
                  onPressed: () =>
                      _setTextFormat(strikethrough: !format.strikethrough),
                  onRightClick: _temporarily(
                    () => _setTextFormat(strikethrough: !format.strikethrough),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PaintIconButton(
                  icon: FontAwesomeIcons.solidSquare,
                  tooltip: 'Fill text',
                  selected: format.filled,
                  onPressed: () => _setTextFormat(filled: !format.filled),
                  onRightClick: _temporarily(
                    () => _setTextFormat(filled: !format.filled),
                  ),
                ),
                PaintIconButton(
                  icon: FontAwesomeIcons.square,
                  tooltip: 'Outline text',
                  selected: format.outlined,
                  onPressed: () => _setTextFormat(outlined: !format.outlined),
                  onRightClick: _temporarily(
                    () => _setTextFormat(outlined: !format.outlined),
                  ),
                ),
                NumberStepper(
                  value: format.outlineWidth,
                  minimum: TextFormat.minimumOutlineWidth,
                  maximum: TextFormat.maximumOutlineWidth,
                  decreaseTooltip: 'Decrease outline width',
                  increaseTooltip: 'Increase outline width',
                  enabled: format.outlined,
                  onChanged: (outlineWidth) =>
                      _setTextFormat(outlineWidth: outlineWidth),
                  onRightClickChanged: _temporarilyWith(
                    (outlineWidth) =>
                        _setTextFormat(outlineWidth: outlineWidth),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasScrollbars({required Widget child}) {
    return ScrollbarTheme(
      data: ScrollbarTheme.of(
        context,
      ).copyWith(crossAxisMargin: PaintScrollBehavior.scrollbarMargin),
      child: Scrollbar(
        controller: verticalScroll,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        thickness: PaintScrollBehavior.scrollbarThickness,
        child: Scrollbar(
          controller: horizontalScroll,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          thickness: PaintScrollBehavior.scrollbarThickness,
          notificationPredicate: (notification) => notification.depth == 1,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              dragDevices: {PointerDeviceKind.trackpad},
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildLayersPane() {
    return Column(
      children: [
        Expanded(
          child: LayerList(
            items: _layerItems(),
            activeIndex: widget.document.activeLayerIndex,
            onSelect: controller.selectLayer,
            onVisibilityChanged: controller.setLayerVisibility,
            onOpacityChanged: controller.previewLayerOpacity,
            onOpacityChangeEnd: controller.setLayerOpacity,
            onTimeframeChanged: controller.setLayerTimeframe,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PaintIconButton(
              icon: FontAwesomeIcons.plus,
              tooltip: 'Add layer',
              shortcut: EditorShortcut.addLayer.keys,
              onPressed: controller.addLayer,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.copy,
              tooltip: 'Copy layer',
              shortcut: EditorShortcut.copyLayer.keys,
              onPressed: controller.copyLayer,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.arrowUp,
              tooltip: 'Move layer up',
              shortcut: EditorShortcut.moveLayerUp.keys,
              onPressed: controller.canMoveLayerUp
                  ? () => controller.moveLayer(up: true)
                  : null,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.arrowDown,
              tooltip: 'Move layer down',
              shortcut: EditorShortcut.moveLayerDown.keys,
              onPressed: controller.canMoveLayerDown
                  ? () => controller.moveLayer(up: false)
                  : null,
            ),
            _buildLayerOptions(),
          ],
        ),
      ],
    );
  }

  Widget _buildLayerOptions() {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      menuChildren: [
        Tooltip(
          message: shortcutTooltip(
            tooltip: 'Merge layer down',
            shortcut: EditorShortcut.mergeLayerDown.keys,
          ),
          waitDuration: const Duration(milliseconds: 500),
          child: MenuItemButton(
            leadingIcon: const FaIcon(
              FontAwesomeIcons.arrowsDownToLine,
              size: 16,
            ),
            onPressed: controller.canMergeLayerDown
                ? controller.mergeLayerDown
                : null,
            child: const Text('Merge layer down'),
          ),
        ),
        Tooltip(
          message: shortcutTooltip(
            tooltip: 'Rename layer',
            shortcut: EditorShortcut.renameLayer.keys,
          ),
          waitDuration: const Duration(milliseconds: 500),
          child: MenuItemButton(
            leadingIcon: const FaIcon(FontAwesomeIcons.pen, size: 16),
            onPressed: _renameLayer,
            child: const Text('Rename layer'),
          ),
        ),
        Tooltip(
          message: shortcutTooltip(
            tooltip: 'Remove layer',
            shortcut: EditorShortcut.removeLayer.keys,
          ),
          waitDuration: const Duration(milliseconds: 500),
          child: MenuItemButton(
            leadingIcon: const FaIcon(FontAwesomeIcons.trashCan, size: 16),
            onPressed: controller.canRemoveLayer
                ? controller.removeLayer
                : null,
            child: const Text('Remove layer'),
          ),
        ),
      ],
      builder: (context, menu, child) => PaintIconButton(
        icon: FontAwesomeIcons.ellipsis,
        tooltip: 'More layer options',
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }

  List<FrameListItem> _frameItems() => [
    for (var frame = 0; frame < widget.document.frameCount; frame++)
      FrameListItem(
        thumbnail: widget.document.frameThumbnail(
          frame: frame,
          maximumSize: History.thumbnailSize,
        ),
        holds: widget.document.frameHolds[frame],
      ),
  ];

  Widget _buildFramesPane() {
    return Column(
      children: [
        Expanded(
          child: FrameList(
            items: _frameItems(),
            activeIndex: widget.document.activeFrameIndex,
            onSelect: controller.selectFrame,
            onHoldsChanged: controller.setFrameHolds,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PaintIconButton(
              icon: FontAwesomeIcons.plus,
              tooltip: 'Add frame',
              shortcut: EditorShortcut.addFrame.keys,
              onPressed: controller.addFrame,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.copy,
              tooltip: 'Copy frame',
              shortcut: EditorShortcut.copyFrame.keys,
              onPressed: controller.copyFrame,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.trashCan,
              tooltip: 'Remove frame',
              shortcut: EditorShortcut.removeFrame.keys,
              onPressed: controller.canRemoveFrame
                  ? controller.removeFrame
                  : null,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.arrowUp,
              tooltip: 'Move frame up',
              shortcut: EditorShortcut.moveFrameUp.keys,
              onPressed: controller.canMoveFrameUp
                  ? () => controller.moveFrame(up: true)
                  : null,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.arrowDown,
              tooltip: 'Move frame down',
              shortcut: EditorShortcut.moveFrameDown.keys,
              onPressed: controller.canMoveFrameDown
                  ? () => controller.moveFrame(up: false)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return PaintBar(
      shadow: false,
      border: const Border(
        bottom: BorderSide(color: PaintStyle.separatorColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => HorizontalScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Center(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: PaintStyle.separatorColor),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RibbonSection(
                      title: 'File',
                      columns: [
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.floppyDisk,
                              tooltip: 'Save',
                              shortcut: EditorShortcut.save.keys,
                              color: PaintStyle.saveColor,
                              onPressed: _save,
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.rotateLeft,
                              tooltip: 'Undo',
                              shortcut: EditorShortcut.undo.keys,
                              onPressed: controller.history.canUndo
                                  ? controller.undo
                                  : null,
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintSplitButton(
                              icon: FontAwesomeIcons.download,
                              tooltip: switch (_exportPath) {
                                final path? =>
                                  'Export to ${fileNameOf(path: path)}',
                                null => 'Export as ${exportFormat.label}',
                              },
                              shortcut: EditorShortcut.export.keys,
                              secondaryTooltip: 'Export formats',
                              onPressed: _exportAgain,
                              dropdown: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final format in ExportFormat.values)
                                    MenuItemButton(
                                      onPressed: () => _exportAs(format),
                                      child: Text('Export as ${format.label}'),
                                    ),
                                ],
                              ),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.rotateRight,
                              tooltip: 'Redo',
                              shortcut: EditorShortcut.redo.keys,
                              onPressed: controller.history.canRedo
                                  ? controller.redo
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    RibbonSection(
                      title: 'Selection',
                      columns: [
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.copy,
                              tooltip: 'Copy',
                              shortcut: EditorShortcut.copy.keys,
                              onPressed: _whenSelected(_copySelection),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.scissors,
                              tooltip: 'Cut',
                              shortcut: EditorShortcut.cut.keys,
                              onPressed: _whenSelected(_cutSelection),
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.paste,
                              tooltip: 'Paste',
                              shortcut: EditorShortcut.paste.keys,
                              onPressed: _paste,
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.expand,
                              tooltip: 'Select all',
                              shortcut: EditorShortcut.selectAll.keys,
                              onPressed: controller.selectAll,
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.arrowRotateLeft,
                              tooltip: 'Rotate left',
                              onPressed: _whenTransformable(
                                () => controller.rotateSelection(
                                  clockwise: false,
                                ),
                              ),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.arrowsLeftRight,
                              tooltip: 'Mirror horizontally',
                              onPressed: _whenTransformable(
                                () => controller.mirrorSelection(
                                  horizontally: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.arrowRotateRight,
                              tooltip: 'Rotate right',
                              onPressed: _whenTransformable(
                                () =>
                                    controller.rotateSelection(clockwise: true),
                              ),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.arrowsUpDown,
                              tooltip: 'Mirror vertically',
                              onPressed: _whenTransformable(
                                () => controller.mirrorSelection(
                                  horizontally: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.cropSimple,
                              tooltip: 'Crop to selection',
                              onPressed: _whenSelected(
                                controller.cropToSelection,
                              ),
                            ),
                            PaintSplitButton(
                              icon: FontAwesomeIcons.film,
                              tooltip: 'All frames',
                              secondaryTooltip: 'All frames options',
                              selected: controller.selectingAllFrames,
                              onPressed: controller.allFramesSelectable
                                  ? () => controller.setSelectingAllFrames(
                                      !controller.selectingAllFrames,
                                    )
                                  : null,
                              dropdown: _buildAllFramesOptions(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    RibbonSection(
                      title: 'Pen',
                      columns: [
                        IntrinsicWidth(
                          child: RibbonColumn(
                            children: [
                              NumberStepper(
                                value: controller.penSize,
                                minimum: EditorController.minimumToolSize,
                                maximum: EditorController.maximumToolSize,
                                decreaseTooltip: 'Decrease size',
                                increaseTooltip: 'Increase size',
                                enabled: controller.toolKind.hasSize,
                                valueWidth: EditorView.penSizeWidth,
                                decrement: smallerToolSize,
                                increment: largerToolSize,
                                onChanged: controller.setPenSize,
                                onRightClickChanged: _temporarilyWith(
                                  controller.setPenSize,
                                ),
                              ),
                              ZeroIntrinsicWidth(
                                child: SliderTheme(
                                  data: PaintStyle.sliderTheme,
                                  child: Slider(
                                    value: exponentialPosition(
                                      value: controller.penSize,
                                      minimum: EditorController.minimumToolSize,
                                      maximum: EditorController.maximumToolSize,
                                    ),
                                    onChanged: controller.toolKind.hasSize
                                        ? (position) => controller.setPenSize(
                                            roundToolSize(
                                              exponentialValue(
                                                position: position,
                                                minimum: EditorController
                                                    .minimumToolSize,
                                                maximum: EditorController
                                                    .maximumToolSize,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        RibbonColumn(
                          children: [
                            _tipButton(
                              tip: BrushTip.square,
                              tooltip: 'Square tip',
                            ),
                            _tipButton(
                              tip: BrushTip.circle,
                              tooltip: 'Circle tip',
                            ),
                          ],
                        ),
                      ],
                    ),
                    RibbonSection(
                      title: 'Tools',
                      columns: [
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: toolIcon(kind: ToolKind.pen),
                              tooltip: 'Pen',
                              shortcut: EditorShortcut.pen.keys,
                              color: PaintStyle.penColor,
                              selected: controller.toolKind == ToolKind.pen,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.pen),
                              onRightClick: _temporarily(
                                () => controller.selectTool(ToolKind.pen),
                              ),
                            ),
                            PaintIconButton(
                              icon: toolIcon(kind: ToolKind.eraser),
                              tooltip: 'Eraser',
                              shortcut: EditorShortcut.eraser.keys,
                              color: PaintStyle.eraserColor,
                              selected: controller.toolKind == ToolKind.eraser,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.eraser),
                              onRightClick: _temporarily(
                                () => controller.selectTool(ToolKind.eraser),
                              ),
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: toolIcon(kind: ToolKind.bucketFill),
                              tooltip: 'Fill',
                              shortcut: EditorShortcut.fill.keys,
                              color: PaintStyle.fillColor,
                              selected:
                                  controller.toolKind == ToolKind.bucketFill,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.bucketFill),
                              onRightClick: _temporarily(
                                () =>
                                    controller.selectTool(ToolKind.bucketFill),
                              ),
                            ),
                            PaintIconButton(
                              icon: toolIcon(kind: ToolKind.colorPicker),
                              tooltip: 'Color picker',
                              shortcut: EditorShortcut.colorPicker.keys,
                              color: PaintStyle.colorPickerColor,
                              selected:
                                  controller.toolKind == ToolKind.colorPicker,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.colorPicker),
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintSplitButton(
                              icon: toolIcon(kind: ToolKind.text),
                              tooltip: 'Text',
                              shortcut: EditorShortcut.text.keys,
                              secondaryTooltip: 'Text options',
                              color: PaintStyle.textColor,
                              selected: controller.toolKind == ToolKind.text,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.text),
                              onRightClick: _temporarily(
                                () => controller.selectTool(ToolKind.text),
                              ),
                              dropdown: _buildTextOptions(),
                            ),
                            PaintIconButton(
                              icon: toolIcon(kind: ToolKind.select),
                              tooltip: 'Select',
                              shortcut: EditorShortcut.select.keys,
                              selected: controller.toolKind == ToolKind.select,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.select),
                              onRightClick: _temporarily(
                                () => controller.selectTool(ToolKind.select),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    RibbonSection(
                      title: 'Shapes',
                      columns: [
                        RibbonColumn(
                          children: [
                            _shapeButton(
                              toolKind: ToolKind.line,
                              shortcut: EditorShortcut.line,
                            ),
                            _shapeButton(
                              toolKind: ToolKind.arrow,
                              shortcut: EditorShortcut.arrow,
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            _shapeButton(
                              toolKind: ToolKind.circle,
                              shortcut: EditorShortcut.circle,
                            ),
                            _shapeButton(
                              toolKind: ToolKind.rectangle,
                              shortcut: EditorShortcut.rectangle,
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.square,
                              tooltip: 'Outline',
                              selected: controller.shapeOutlined,
                              onPressed: controller.toolKind.hasFill
                                  ? () => controller.setShapeOutlined(
                                      !controller.shapeOutlined,
                                    )
                                  : null,
                              onRightClick: _temporarily(
                                () => controller.setShapeOutlined(
                                  !controller.shapeOutlined,
                                ),
                              ),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.solidSquare,
                              tooltip: 'Fill shape',
                              selected: controller.shapeFilled,
                              onPressed: controller.toolKind.hasFill
                                  ? () => controller.setShapeFilled(
                                      !controller.shapeFilled,
                                    )
                                  : null,
                              onRightClick: _temporarily(
                                () => controller.setShapeFilled(
                                  !controller.shapeFilled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    RibbonSection(
                      title: 'Colors',
                      columns: [
                        RibbonColumn(
                          children: [
                            ColorWell(
                              color: Color(controller.primaryColor.argb),
                              tooltip: 'Primary color',
                              selected: controller.editingPrimary,
                              onPressed: () =>
                                  controller.editPrimary(primary: true),
                            ),
                            ColorWell(
                              color: Color(controller.secondaryColor.argb),
                              tooltip: 'Secondary color',
                              selected: !controller.editingPrimary,
                              onPressed: () =>
                                  controller.editPrimary(primary: false),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Center(
                          child: SwatchGrid(
                            colors: _toColors(greyPalette),
                            onSelect: _selectColor,
                            onRightClickSelect: _temporarilyWith(_selectColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Center(
                          child: SwatchGrid(
                            colors: _toColors(huePalette),
                            onSelect: _selectColor,
                            onRightClickSelect: _temporarilyWith(_selectColor),
                          ),
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.palette,
                              tooltip: 'Edit colors',
                              onPressed: _editColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    RibbonSection(
                      title: 'Animation',
                      columns: [
                        Timeline(
                          frame: widget.document.activeFrameIndex,
                          shownFrames: widget.document.shownFrames,
                          fps: widget.document.fps,
                          playing: controller.playing,
                          onionSkin: controller.onionSkin,
                          onPlayPause: _togglePlayback,
                          onStep: controller.stepFrame,
                          onSelectFrame: controller.selectFrame,
                          onFpsChanged: controller.setFps,
                          onOnionSkinChanged: controller.setOnionSkin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection({
    required FaIconData icon,
    required Widget child,
  }) {
    return PaintBarSection(
      child: _buildStatusContent(icon: icon, child: child),
    );
  }

  Widget _buildStatusContent({
    required FaIconData icon,
    required Widget child,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [FaIcon(icon, size: 14), child],
    );
  }

  Widget _buildEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCanvasArea()),
              SidePane(
                panels: [
                  (title: 'Layers', child: _buildLayersPane()),
                  (title: 'Frames', child: _buildFramesPane()),
                  (
                    title: 'History',
                    child: HistoryList(
                      items: _historyItems(),
                      position: controller.history.position,
                      onSelect: controller.jumpToHistory,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PaintBar(
          child: Row(
            children: [
              _buildStatusSection(
                icon: FontAwesomeIcons.arrowPointer,
                child: ListenableBuilder(
                  listenable: controller.pointerPreview,
                  builder: (context, _) => StableText(
                    text: _cursorText(),
                    alternatives: [
                      '${widget.document.width - 1}, ${widget.document.height - 1}',
                    ],
                  ),
                ),
              ),
              PaintBarSection(
                padding: PaintStatusButton.sectionPadding,
                child: PaintStatusButton(
                  tooltip: 'Resize image',
                  onPressed: _resizeImage,
                  child: _buildStatusContent(
                    icon: FontAwesomeIcons.upRightAndDownLeftFromCenter,
                    child: ListenableBuilder(
                      listenable: controller.pointerPreview,
                      builder: (context, _) => StableText(
                        text: _sizeText(),
                        alternatives: [
                          '${widget.document.width} × ${widget.document.height}',
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PaintBarSection(
                padding: PaintStatusButton.sectionPadding,
                child: PaintStatusButton(
                  tooltip: 'Rename document',
                  onPressed: _renameDocument,
                  child: _buildStatusContent(
                    icon: FontAwesomeIcons.file,
                    child: Text(widget.document.name),
                  ),
                ),
              ),
              _buildStatusSection(
                icon: FontAwesomeIcons.floppyDisk,
                child: StableText(
                  text: controller.saveStatus.label,
                  alternatives: [
                    for (final saveStatus in SaveStatus.values)
                      saveStatus.label,
                  ],
                ),
              ),
              Expanded(
                child: HorizontalScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ToolPresetList(
                    presets: controller.toolPresets,
                    lockedCount: widget.document.toolPresets.locked.length,
                    selected: controller.toolPreset,
                    onApply: (index) =>
                        controller.applyToolPreset(index: index),
                    onLockChanged: controller.setToolPresetLocked,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: NumericValueRange(
                  label: 'Zoom:',
                  value: controller.zoom.factor,
                  minimum: Zoom.minimum.factor,
                  maximum: Zoom.maximum.factor,
                  rangeMinimum: -4,
                  rangeMaximum: 4,
                  valueToRange: (factor) =>
                      log(Zoom(factor: factor).scale) / ln2,
                  rangeToValue: (range) =>
                      Zoom.nearest(scale: pow(2, range).toDouble()).factor,
                  decrement: (factor) =>
                      Zoom(factor: factor).stepped(larger: false).factor,
                  increment: (factor) =>
                      Zoom(factor: factor).stepped(larger: true).factor,
                  valueToText: (factor) => Zoom(factor: factor).label,
                  textToValue: (text) => Zoom.tryParse(text)?.factor,
                  allowedCharacters: '[0-9/-]',
                  onChanged: (factor) => _zoomTo(Zoom(factor: factor)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
