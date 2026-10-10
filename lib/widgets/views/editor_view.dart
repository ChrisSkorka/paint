import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/canvas/pixel_color.dart';
import '../../editor/canvas/pixel_point.dart';
import '../../editor/editor_controller.dart';
import '../../editor/files/document_library.dart';
import '../../editor/files/export_format.dart';
import '../../editor/files/file_access.dart';
import '../../editor/files/image_clipboard.dart';
import '../../editor/canvas/layer.dart';
import '../../editor/history/history.dart';
import '../../editor/history/history_entry.dart';
import '../../editor/history/pixel_history_entry.dart';
import '../../editor/pointer_button.dart';
import '../../editor/tools/brush_tip.dart';
import '../../editor/tools/color_palettes.dart';
import '../../editor/tools/tool_kind.dart';
import '../components/color_dialog.dart';
import '../components/edge_shadow.dart';
import '../components/history_list.dart';
import '../components/layer_list.dart';
import '../components/pixel_canvas.dart';
import '../components/numeric_value_range.dart';
import '../components/paint_bar.dart';
import '../components/paint_icon_button.dart';
import '../components/paint_split_button.dart';
import '../components/paint_style.dart';
import '../components/ribbon_section.dart';
import '../components/side_panel.dart';
import '../components/swatch_grid.dart';
import '../components/timeline.dart';

class EditorView extends StatefulWidget {
  const EditorView({
    super.key,
    required this.document,
    required this.clipboard,
    required this.files,
    required this.library,
  });

  final Document document;
  final ImageClipboard clipboard;
  final FileAccess files;
  final DocumentLibrary library;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late final controller = EditorController.forDocument(
    document: widget.document,
  );
  var exportFormat = ExportFormat.png;
  Timer? playback;

  @override
  void dispose() {
    playback?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (playback != null) {
      _stopPlayback();
      return;
    }
    setState(_scheduleNextFrame);
  }

  void _scheduleNextFrame() {
    final document = widget.document;
    playback = Timer(
      Duration(
        milliseconds: document.frameDurations[document.activeFrameIndex],
      ),
      () {
        controller.selectFrame(
          (document.activeFrameIndex + 1) % document.frameCount,
        );
        _scheduleNextFrame();
      },
    );
  }

  void _stopPlayback() {
    setState(() {
      playback?.cancel();
      playback = null;
    });
  }

  void _pointerDown({
    required PixelPoint point,
    required PointerButton button,
  }) {
    if (playback != null) _stopPlayback();
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

  List<List<Color?>> _recentSwatches() => [
    for (var index = 0; index < EditorController.recentColorLimit; index++)
      [
        if (index < controller.recentColors.length)
          Color(controller.recentColors[index].argb)
        else
          null,
      ],
  ];

  List<List<Color>> _toColors(List<List<PixelColor>> palette) => [
    for (final row in palette) [for (final color in row) Color(color.argb)],
  ];

  Widget _sizeDropdown({
    String label = 'Size:',
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return NumericValueRange(
      label: label,
      value: value,
      minimum: 1,
      maximum: 64,
      onChanged: onChanged,
    );
  }

  Widget _penDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sizeDropdown(
          value: controller.penSize,
          onChanged: controller.setPenSize,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            spacing: 4,
            children: [
              const Text('Tip:'),
              PaintIconButton(
                icon: FontAwesomeIcons.square,
                tooltip: 'Square tip',
                selected: controller.penTip == BrushTip.square,
                onPressed: () => controller.setPenTip(BrushTip.square),
              ),
              PaintIconButton(
                icon: FontAwesomeIcons.circle,
                tooltip: 'Circle tip',
                selected: controller.penTip == BrushTip.circle,
                onPressed: () => controller.setPenTip(BrushTip.circle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shapeButton({required FaIconData icon, required ToolKind toolKind}) {
    return PaintSplitButton(
      icon: icon,
      tooltip: toolKind.label,
      color: PaintStyle.shapeColor,
      selected: controller.toolKind == toolKind,
      onPressed: () => controller.selectTool(toolKind),
      dropdown: _sizeDropdown(
        label: 'Width:',
        value: controller.shapeWidth,
        onChanged: controller.setShapeWidth,
      ),
    );
  }

  VoidCallback? _whenSelected(VoidCallback action) =>
      controller.hasSelection ? action : null;

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

  late final _keyActions = <SingleActivator, VoidCallback>{
    const SingleActivator(
      LogicalKeyboardKey.keyS,
      control: true,
      includeRepeats: false,
    ): _save,
    const SingleActivator(LogicalKeyboardKey.delete, includeRepeats: false):
        controller.deleteSelection,
    const SingleActivator(LogicalKeyboardKey.backspace, includeRepeats: false):
        controller.deleteSelection,
    const SingleActivator(
      LogicalKeyboardKey.keyC,
      control: true,
      includeRepeats: false,
    ): _copySelection,
    const SingleActivator(
      LogicalKeyboardKey.keyX,
      control: true,
      includeRepeats: false,
    ): _cutSelection,
    const SingleActivator(
      LogicalKeyboardKey.keyV,
      control: true,
      includeRepeats: false,
    ): _paste,
  };

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (_editingText()) return KeyEventResult.ignored;
    final action = _keyActions.entries
        .firstWhereOrNull(
          (entry) => entry.key.accepts(event, HardwareKeyboard.instance),
        )
        ?.value;
    if (action == null) return KeyEventResult.ignored;
    action();
    return KeyEventResult.handled;
  }

  bool _editingText() =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            controller.undo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            controller.redo,
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleKey,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => _buildEditor(),
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      color: PaintStyle.canvasAreaBackground,
      child: CustomPaint(
        foregroundPainter: const EdgeShadowPainter(),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: PaintStyle.faintShadow,
              ),
              child: PixelCanvas(
                width: widget.document.width,
                height: widget.document.height,
                zoom: controller.zoom,
                layers: controller.visibleLayers,
                frame: widget.document.activeFrameIndex,
                onPointerDown: _pointerDown,
                onPointerMove: controller.pointerMove,
                onPointerUp: controller.pointerUp,
                onPointerExit: controller.pointerExit,
                selection: controller.selectionArea,
                cursor: controller.pointerOverSelection
                    ? SystemMouseCursors.move
                    : SystemMouseCursors.precise,
              ),
            ),
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
              onPressed: controller.addLayer,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.trashCan,
              tooltip: 'Remove layer',
              onPressed: controller.canRemoveLayer
                  ? controller.removeLayer
                  : null,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.arrowUp,
              tooltip: 'Move layer up',
              onPressed: controller.canMoveLayerUp
                  ? () => controller.moveLayer(up: true)
                  : null,
            ),
            PaintIconButton(
              icon: FontAwesomeIcons.arrowDown,
              tooltip: 'Move layer down',
              onPressed: controller.canMoveLayerDown
                  ? () => controller.moveLayer(up: false)
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
      border: const Border(right: BorderSide(color: PaintStyle.separatorColor)),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                              color: PaintStyle.saveColor,
                              onPressed: _save,
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.rotateLeft,
                              tooltip: 'Undo',
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
                              dropdownTooltip: 'Export formats',
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
                              onPressed: _whenSelected(_copySelection),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.scissors,
                              tooltip: 'Cut',
                              onPressed: _whenSelected(_cutSelection),
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.paste,
                              tooltip: 'Paste',
                              onPressed: _paste,
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.expand,
                              tooltip: 'Select all',
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
                      title: 'Tools',
                      columns: [
                        RibbonColumn(
                          children: [
                            PaintSplitButton(
                              icon: FontAwesomeIcons.pencil,
                              tooltip: 'Pen',
                              color: PaintStyle.penColor,
                              selected: controller.toolKind == ToolKind.pen,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.pen),
                              dropdown: _penDropdown(),
                            ),
                            PaintSplitButton(
                              icon: FontAwesomeIcons.eraser,
                              tooltip: 'Eraser',
                              color: PaintStyle.eraserColor,
                              selected: controller.toolKind == ToolKind.eraser,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.eraser),
                              dropdown: _sizeDropdown(
                                value: controller.eraserSize,
                                onChanged: controller.setEraserSize,
                              ),
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            PaintIconButton(
                              icon: FontAwesomeIcons.fill,
                              tooltip: 'Fill',
                              color: PaintStyle.fillColor,
                              selected:
                                  controller.toolKind == ToolKind.bucketFill,
                              onPressed: () =>
                                  controller.selectTool(ToolKind.bucketFill),
                            ),
                            PaintIconButton(
                              icon: FontAwesomeIcons.eyeDropper,
                              tooltip: 'Color picker',
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
                              icon: FontAwesomeIcons.borderTopLeft,
                              tooltip: 'Select',
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
                              icon: FontAwesomeIcons.slash,
                              toolKind: ToolKind.line,
                            ),
                            _shapeButton(
                              icon: FontAwesomeIcons.square,
                              toolKind: ToolKind.rectangle,
                            ),
                          ],
                        ),
                        RibbonColumn(
                          children: [
                            _shapeButton(
                              icon: FontAwesomeIcons.circle,
                              toolKind: ToolKind.circle,
                            ),
                            _shapeButton(
                              icon: FontAwesomeIcons.arrowRight,
                              toolKind: ToolKind.arrow,
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
                        const SizedBox(width: 8),
                        Center(
                          child: SwatchGrid(
                            colors: _recentSwatches(),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),
                    Expanded(child: _buildCanvasArea()),
                  ],
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: SidePanel(
                      title: 'Layers',
                      border: const Border(
                        bottom: BorderSide(color: PaintStyle.separatorColor),
                      ),
                      child: _buildLayersPane(),
                    ),
                  ),
                  Expanded(
                    child: SidePanel(
                      title: 'History',
                      child: HistoryList(
                        items: _historyItems(),
                        position: controller.history.position,
                        onSelect: controller.jumpToHistory,
                      ),
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
              PaintBarSection(
                child: Row(
                  spacing: 6,
                  children: [
                    const FaIcon(FontAwesomeIcons.arrowPointer, size: 14),
                    Text(_cursorText()),
                  ],
                ),
              ),
              PaintBarSection(
                child: Row(
                  spacing: 6,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.upRightAndDownLeftFromCenter,
                      size: 14,
                    ),
                    Text(
                      '${widget.document.width} × ${widget.document.height}',
                    ),
                  ],
                ),
              ),
              PaintBarSection(
                child: Row(
                  spacing: 6,
                  children: [
                    const FaIcon(FontAwesomeIcons.file, size: 14),
                    Text(widget.document.name),
                  ],
                ),
              ),
              PaintBarSection(
                child: Row(
                  spacing: 6,
                  children: [
                    const FaIcon(FontAwesomeIcons.floppyDisk, size: 14),
                    Text(controller.saveStatus.label),
                  ],
                ),
              ),
              Expanded(
                child: PaintBarSection(
                  child: Timeline(
                    frame: widget.document.activeFrameIndex,
                    frameCount: widget.document.frameCount,
                    frameDuration: widget
                        .document
                        .frameDurations[widget.document.activeFrameIndex],
                    playing: playback != null,
                    onPlayPause: _togglePlayback,
                    onSelectFrame: controller.selectFrame,
                    onAddFrame: controller.addFrame,
                    onRemoveFrame: controller.canRemoveFrame
                        ? controller.removeFrame
                        : null,
                    onDurationChanged: controller.previewFrameDuration,
                    onDurationChangeEnd: controller.setFrameDuration,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: NumericValueRange(
                  label: 'Zoom:',
                  value: controller.zoom,
                  minimum: 1,
                  maximum: 100,
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
