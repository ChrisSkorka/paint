import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/canvas/pixel_color.dart';
import '../../editor/editor_controller.dart';
import '../../editor/history/history_entry.dart';
import '../../editor/tools/brush_tip.dart';
import '../../editor/tools/color_palettes.dart';
import '../../editor/tools/tool_kind.dart';
import '../components/color_dialog.dart';
import '../components/edge_shadow.dart';
import '../components/history_list.dart';
import '../components/pixel_canvas.dart';
import '../components/numeric_value_range.dart';
import '../components/paint_bar.dart';
import '../components/paint_icon_button.dart';
import '../components/paint_split_button.dart';
import '../components/paint_style.dart';
import '../components/ribbon_section.dart';
import '../components/side_panel.dart';
import '../components/swatch_grid.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key, required this.document});

  final Document document;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late final controller = EditorController.forDocument(
    document: widget.document,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return NumericValueRange(
      label: 'Size:',
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

  Rect _thumbnailOutline(HistoryEntry entry) {
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
                onPointerDown: controller.pointerDown,
                onPointerMove: controller.pointerMove,
                onPointerUp: controller.pointerUp,
                onPointerExit: controller.pointerExit,
              ),
            ),
          ),
        ),
      ),
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
                              icon: FontAwesomeIcons.rotateLeft,
                              tooltip: 'Undo',
                              onPressed: controller.history.canUndo
                                  ? controller.undo
                                  : null,
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
              SidePanel(
                title: 'History',
                child: HistoryList(
                  items: _historyItems(),
                  position: controller.history.position,
                  onSelect: controller.jumpToHistory,
                ),
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
              const Spacer(),
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
