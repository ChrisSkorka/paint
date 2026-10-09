import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/pixel_color.dart';
import 'numeric_value_range.dart';
import 'paint_icon_button.dart';
import 'paint_style.dart';
import 'swatch_grid.dart';

Future<PixelColor?> showColorDialog({
  required BuildContext context,
  required PixelColor initialColor,
}) {
  return showDialog<PixelColor>(
    context: context,
    builder: (context) => ColorDialog(initialColor: initialColor),
  );
}

class ColorDialog extends StatefulWidget {
  const ColorDialog({super.key, required this.initialColor});

  final PixelColor initialColor;

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  late var color = widget.initialColor;
  late final hexController = TextEditingController(text: color.hex);

  @override
  void dispose() {
    hexController.dispose();
    super.dispose();
  }

  void _update({int? red, int? green, int? blue, int? alpha}) {
    setState(() {
      color = PixelColor.fromChannels(
        red: red ?? color.red,
        green: green ?? color.green,
        blue: blue ?? color.blue,
        alpha: alpha ?? color.alpha,
      );
      hexController.text = color.hex;
    });
  }

  void _typeHex(String text) {
    final parsed = PixelColor.tryParseHex(text);
    if (parsed != null) setState(() => color = parsed);
  }

  void _submitHex(String text) {
    _typeHex(text);
    hexController.text = color.hex;
  }

  Widget _channel({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return NumericValueRange(
      label: label,
      value: value,
      minimum: 0,
      maximum: 255,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: PaintStyle.radius,
        side: BorderSide(color: PaintStyle.dialogBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit color',
                  style: TextStyle(
                    color: PaintStyle.titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48),
                Tooltip(
                  message: 'Current color',
                  child: ColorPreview(
                    color: Color(widget.initialColor.argb),
                    width: 40,
                    height: 26,
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'New color',
                  child: ColorPreview(
                    color: Color(color.argb),
                    width: 40,
                    height: 26,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Hex:'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: hexController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    onChanged: _typeHex,
                    onSubmitted: _submitHex,
                  ),
                ),
              ],
            ),
            _channel(
              label: 'Red:',
              value: color.red,
              onChanged: (red) => _update(red: red),
            ),
            _channel(
              label: 'Green:',
              value: color.green,
              onChanged: (green) => _update(green: green),
            ),
            _channel(
              label: 'Blue:',
              value: color.blue,
              onChanged: (blue) => _update(blue: blue),
            ),
            _channel(
              label: 'Alpha:',
              value: color.alpha,
              onChanged: (alpha) => _update(alpha: alpha),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                PaintIconButton(
                  icon: FontAwesomeIcons.xmark,
                  tooltip: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                PaintIconButton(
                  icon: FontAwesomeIcons.check,
                  tooltip: 'OK',
                  onPressed: () => Navigator.of(context).pop(color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
