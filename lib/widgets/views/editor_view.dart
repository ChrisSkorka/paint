import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/canvas/pixel_color.dart';
import '../../editor/tools/color_palettes.dart';
import '../components/chess_grid.dart';
import '../components/numeric_value_range.dart';
import '../components/paint_bar.dart';
import '../components/paint_icon_button.dart';
import '../components/paint_split_button.dart';
import '../components/paint_style.dart';
import '../components/ribbon_section.dart';
import '../components/swatch_grid.dart';

enum _Tool { pen, eraser, colorPicker }

class EditorView extends StatefulWidget {
  const EditorView({super.key, required this.document});

  final Document document;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  var tool = _Tool.pen;
  var zoom = 4;
  var penSize = 1;
  var eraserSize = 1;
  var primaryColor = PixelColor.black;
  var secondaryColor = PixelColor.white;
  var editingPrimary = true;

  void _selectColor(Color color) {
    final pixelColor = PixelColor(argb: color.toARGB32());
    setState(() {
      if (editingPrimary) {
        primaryColor = pixelColor;
      } else {
        secondaryColor = pixelColor;
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PaintBar(
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
                          title: 'Tools',
                          columns: [
                            RibbonColumn(
                              children: [
                                PaintSplitButton(
                                  icon: FontAwesomeIcons.pencil,
                                  tooltip: 'Pen',
                                  color: PaintStyle.penColor,
                                  selected: tool == _Tool.pen,
                                  onPressed: () =>
                                      setState(() => tool = _Tool.pen),
                                  dropdown: _sizeDropdown(
                                    value: penSize,
                                    onChanged: (size) =>
                                        setState(() => penSize = size),
                                  ),
                                ),
                                PaintSplitButton(
                                  icon: FontAwesomeIcons.eraser,
                                  tooltip: 'Eraser',
                                  color: PaintStyle.eraserColor,
                                  selected: tool == _Tool.eraser,
                                  onPressed: () =>
                                      setState(() => tool = _Tool.eraser),
                                  dropdown: _sizeDropdown(
                                    value: eraserSize,
                                    onChanged: (size) =>
                                        setState(() => eraserSize = size),
                                  ),
                                ),
                              ],
                            ),
                            RibbonColumn(
                              children: [
                                PaintIconButton(
                                  icon: FontAwesomeIcons.eyeDropper,
                                  tooltip: 'Color picker',
                                  color: PaintStyle.colorPickerColor,
                                  selected: tool == _Tool.colorPicker,
                                  onPressed: () =>
                                      setState(() => tool = _Tool.colorPicker),
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
                                  color: Color(primaryColor.argb),
                                  tooltip: 'Primary color',
                                  selected: editingPrimary,
                                  onPressed: () =>
                                      setState(() => editingPrimary = true),
                                ),
                                ColorWell(
                                  color: Color(secondaryColor.argb),
                                  tooltip: 'Secondary color',
                                  selected: !editingPrimary,
                                  onPressed: () =>
                                      setState(() => editingPrimary = false),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: PaintStyle.canvasAreaBackground,
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: PaintStyle.faintShadow,
                  ),
                  child: CustomPaint(
                    painter: const ChessGridPainter(),
                    size: Size(
                      widget.document.width * zoom.toDouble(),
                      widget.document.height * zoom.toDouble(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        PaintBar(
          child: Row(
            children: [
              const PaintBarSection(
                child: Row(
                  spacing: 6,
                  children: [
                    FaIcon(FontAwesomeIcons.arrowPointer, size: 14),
                    Text('-'),
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
                  value: zoom,
                  minimum: 1,
                  maximum: 100,
                  rangeMinimum: 0,
                  rangeMaximum: 4,
                  valueToRange: (value) => log(value) / ln2,
                  rangeToValue: (range) => pow(2, range).round(),
                  decrement: (value) => value ~/ 2,
                  increment: (value) => value * 2,
                  onChanged: (value) => setState(() => zoom = value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
