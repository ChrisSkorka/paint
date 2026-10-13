import 'dart:async';
import 'dart:math';

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
import '../../editor/files/image_clipboard.dart';
import '../../editor/files/save_status.dart';
import '../../editor/canvas/layer.dart';
import '../../editor/history/history.dart';
import '../../editor/history/history_entry.dart';
import '../../editor/history/pixel_history_entry.dart';
import '../../editor/pointer_button.dart';
import '../../editor/tools/brush_tip.dart';
import '../../editor/tools/color_palettes.dart';
import '../../editor/tools/tool_kind.dart';
import '../../editor/tools/tool_size.dart';
import '../components/canvas_margin.dart';
import '../components/color_dialog.dart';
import '../components/edge_shadow.dart';
import '../components/exponential_scale.dart';
import '../components/frame_list.dart';
import '../components/history_list.dart';
import '../components/horizontal_scroll_view.dart';
import '../components/layer_list.dart';
import '../components/pixel_canvas.dart';
import '../components/number_stepper.dart';
import '../components/numeric_value_range.dart';
import '../components/paint_bar.dart';
import '../components/paint_icon_button.dart';
import '../components/paint_scroll_behavior.dart';
import '../components/paint_split_button.dart';
import '../components/paint_style.dart';
import '../components/ribbon_section.dart';
import '../components/side_pane.dart';
import '../components/stable_text.dart';
import '../components/swatch_grid.dart';
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
    this.active = true,
    this.onUnsavedChanged,
  });

  final Document document;
  final ImageClipboard clipboard;
  final FileAccess files;
  final DocumentLibrary library;
  final bool active;
  final ValueChanged<bool>? onUnsavedChanged;

  static const canvasEdge = 15.0;
  static const penSizeWidth = 56.0;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late final controller = EditorController.forDocument(
    document: widget.document,
  );
  var exportFormat = ExportFormat.png;
  Timer? playback;
  final focusNode = FocusNode(debugLabel: 'Editor');
  final verticalScroll = ScrollController();
  final horizontalScroll = ScrollController();
  var unsaved = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_reclaimFocus);
    controller.addListener(_reportUnsaved);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusWhenActive());
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
    );
  }

  VoidCallback? _whenSelected(VoidCallback action) =>
      controller.hasSelection ? action : null;

  MouseCursor _canvasCursor() {
    if (controller.pointerOverSelection) return SystemMouseCursors.move;
    if (controller.drawsPointer) return SystemMouseCursors.none;
    return SystemMouseCursors.precise;
  }

  String _cursorText() {
    final cursor = controller.cursor;
    return cursor == null ? '-' : '${cursor.x}, ${cursor.y}';
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
    if (entry is! PixelHistoryEntry) return null;
    final scaleX = entry.thumbnail.width / widget.document.width;
    final scaleY = entry.thumbnail.height / widget.document.height;
    final area = entry.after.area;
    return Rect.fromLTWH(
      area.left * scaleX,
      area.top * scaleY,
      area.width * scaleX,
      area.height * scaleY,
    );
  }

  Future<void> _copySelection() async {
    final content = controller.selectionContent;
    if (content != null) await widget.clipboard.write(content);
  }

  Future<void> _cutSelection() async {
    final content = controller.selectionContent;
    controller.cutSelection();
    if (content != null) await widget.clipboard.write(content);
  }

  Future<void> _paste() async {
    final image = await widget.clipboard.read();
    if (image != null && mounted) controller.paste(image);
  }

  Future<void> _save() async {
    final point = controller.history.point;
    final saved = await _attempt(
      failure: 'Could not save',
      action: () => widget.library.save(document: widget.document),
    );
    if (saved && mounted) controller.markSaved(point);
  }

  Future<void> _export(ExportFormat format) async {
    setState(() => exportFormat = format);
    await _attempt(
      failure: 'Could not export',
      action: () => widget.files.save(
        fileName: format.fileName(document: widget.document),
        format: format,
        bytes: format.encode(document: widget.document),
      ),
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
    EditorShortcut.export: () => _export(exportFormat),
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
    EditorShortcut.line: () => controller.selectTool(ToolKind.line),
    EditorShortcut.rectangle: () => controller.selectTool(ToolKind.rectangle),
    EditorShortcut.circle: () => controller.selectTool(ToolKind.circle),
    EditorShortcut.arrow: () => controller.selectTool(ToolKind.arrow),
    EditorShortcut.smallerSize: () => controller.stepToolSize(larger: false),
    EditorShortcut.largerSize: () => controller.stepToolSize(larger: true),
    EditorShortcut.swapColors: controller.swapColors,
    EditorShortcut.zoomIn: () => controller.stepZoom(larger: true),
    EditorShortcut.zoomOut: () => controller.stepZoom(larger: false),
    EditorShortcut.resetZoom: () =>
        controller.setZoom(EditorController.defaultZoom),
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
    final shortcut = EditorShortcut.matching(event);
    if (shortcut == null || shortcut.group == ShortcutGroup.tabs) {
      return KeyEventResult.ignored;
    }
    if (shortcut == EditorShortcut.toolPreset) {
      controller.applyToolPreset(index: shortcut.activatorIndex(event));
    } else {
      _shortcutActions[shortcut]!();
    }
    return KeyEventResult.handled;
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

  Widget _buildCanvasArea() {
    return Container(
      color: PaintStyle.canvasAreaBackground,
      child: CustomPaint(
        foregroundPainter: const EdgeShadowPainter(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final vertical = canvasMargin(
              available: constraints.maxHeight,
              extent: widget.document.height * controller.zoom.toDouble(),
              edge: EditorView.canvasEdge,
              scrollbar: PaintScrollBehavior.scrollbarTrack,
            );
            final horizontal = canvasMargin(
              available: constraints.maxWidth,
              extent: widget.document.width * controller.zoom.toDouble(),
              edge: EditorView.canvasEdge,
              scrollbar: PaintScrollBehavior.scrollbarTrack,
            );
            return _buildCanvasScrollbars(
              child: SingleChildScrollView(
                controller: verticalScroll,
                reverse: vertical.reverse,
                child: SingleChildScrollView(
                  controller: horizontalScroll,
                  scrollDirection: Axis.horizontal,
                  reverse: horizontal.reverse,
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
                    child: ListenableBuilder(
                      listenable: controller.pointerPreview,
                      builder: (context, _) => PixelCanvas(
                        width: widget.document.width,
                        height: widget.document.height,
                        zoom: controller.zoom,
                        layers: controller.canvasLayers,
                        pointerPreview: controller.pointerPreview,
                        layersChanged: controller.layersChanged,
                        onPointerDown: _pointerDown,
                        onPointerMove: controller.pointerMove,
                        onPointerUp: controller.pointerUp,
                        onPointerExit: controller.pointerExit,
                        selection: controller.selectionArea,
                        cursor: _canvasCursor(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
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
              icon: FontAwesomeIcons.trashCan,
              tooltip: 'Remove layer',
              shortcut: EditorShortcut.removeLayer.keys,
              onPressed: controller.canRemoveLayer
                  ? controller.removeLayer
                  : null,
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
          ],
        ),
      ],
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
                              tooltip: 'Export as ${exportFormat.label}',
                              shortcut: EditorShortcut.export.keys,
                              secondaryTooltip: 'Export formats',
                              onPressed: () => _export(exportFormat),
                              dropdown: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final format in ExportFormat.values)
                                    MenuItemButton(
                                      onPressed: () => _export(format),
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
                              onPressed: _whenSelected(
                                () => controller.rotateSelection(
                                  clockwise: false,
                                ),
                              ),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.arrowsLeftRight,
                              tooltip: 'Mirror horizontally',
                              onPressed: _whenSelected(
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
                              onPressed: _whenSelected(
                                () =>
                                    controller.rotateSelection(clockwise: true),
                              ),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.arrowsUpDown,
                              tooltip: 'Mirror vertically',
                              onPressed: _whenSelected(
                                () => controller.mirrorSelection(
                                  horizontally: false,
                                ),
                              ),
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
                            ),
                            PaintIconButton(
                              icon: toolIcon(kind: ToolKind.eraser),
                              tooltip: 'Eraser',
                              shortcut: EditorShortcut.eraser.keys,
                              color: PaintStyle.eraserColor,
                              selected: controller.toolKind == ToolKind.eraser,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.eraser),
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
                            PaintIconButton(
                              icon: toolIcon(kind: ToolKind.select),
                              tooltip: 'Select',
                              shortcut: EditorShortcut.select.keys,
                              selected: controller.toolKind == ToolKind.select,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.select),
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
                              toolKind: ToolKind.rectangle,
                              shortcut: EditorShortcut.rectangle,
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
                              toolKind: ToolKind.arrow,
                              shortcut: EditorShortcut.arrow,
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
                          ),
                        ),
                        const SizedBox(width: 8),
                        Center(
                          child: SwatchGrid(
                            colors: _toColors(huePalette),
                            onSelect: _selectColor,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [FaIcon(icon, size: 14), child],
      ),
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
              _buildStatusSection(
                icon: FontAwesomeIcons.upRightAndDownLeftFromCenter,
                child: Text(
                  '${widget.document.width} × ${widget.document.height}',
                ),
              ),
              _buildStatusSection(
                icon: FontAwesomeIcons.file,
                child: Text(widget.document.name),
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
                  value: controller.zoom,
                  minimum: EditorController.minimumZoom,
                  maximum: EditorController.maximumZoom,
                  rangeMinimum: 0,
                  rangeMaximum: 4,
                  valueToRange: (value) => log(value) / ln2,
                  rangeToValue: (range) => pow(2, range).round(),
                  decrement: (value) => value ~/ 2,
                  increment: (value) => value * 2,
                  onChanged: controller.setZoom,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
