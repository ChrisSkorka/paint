import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/pixel_color.dart';
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
  static const pickerWidth = 256.0;

  late var color = widget.initialColor;
  late var hsvColor = HSVColor.fromColor(Color(color.argb));
  late final hexController = TextEditingController(text: color.hex);

  @override
  void dispose() {
    hexController.dispose();
    super.dispose();
  }

  void _pick(HSVColor picked) {
    setState(() {
      hsvColor = picked;
      color = PixelColor(argb: picked.toColor().toARGB32());
      hexController.text = color.hex;
    });
  }

  void _typeHex(String text) {
    final parsed = PixelColor.tryParseHex(text);
    if (parsed == null) return;
    setState(() {
      color = parsed;
      hsvColor = HSVColor.fromColor(Color(parsed.argb));
    });
  }

  void _submitHex(String text) {
    _typeHex(text);
    hexController.text = color.hex;
  }

  Widget _slider({required String tooltip, required TrackType trackType}) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: pickerWidth + 30,
        height: 36,
        child: ColorPickerSlider(
          trackType,
          hsvColor,
          _pick,
          displayThumbColor: true,
        ),
      ),
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
          spacing: 8,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(color: PaintStyle.dialogBorder),
                ),
                child: SizedBox(
                  width: pickerWidth,
                  height: pickerWidth * 3 / 4,
                  child: ColorPickerArea(
                    hsvColor,
                    _pick,
                    PaletteType.hsvWithHue,
                  ),
                ),
              ),
            ),
            _slider(tooltip: 'Hue', trackType: TrackType.hue),
            _slider(tooltip: 'Alpha', trackType: TrackType.alpha),
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
