import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_icon_button.dart';
import 'paint_style.dart';

Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  required String label,
  required String initialText,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        TextInputDialog(title: title, label: label, initialText: initialText),
  );
}

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    super.key,
    required this.title,
    required this.label,
    required this.initialText,
  });

  static const fieldWidth = 240.0;

  final String title;
  final String label;
  final String initialText;

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final textController = TextEditingController(text: widget.initialText)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialText.length,
    );

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  String get _text => textController.text.trim();

  void _submit() {
    if (_text.isNotEmpty) Navigator.of(context).pop(_text);
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
        child: ListenableBuilder(
          listenable: textController,
          builder: (context, _) {
            final valid = _text.isNotEmpty;
            return IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: PaintStyle.titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: TextInputDialog.fieldWidth,
                    child: TextField(
                      key: Key(widget.label),
                      controller: textController,
                      autofocus: true,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: widget.label,
                        errorText: valid ? null : 'Cannot be empty',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
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
                          onPressed: valid ? _submit : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
