import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/files/image_clipboard.dart';
import '../components/paint_icon_button.dart';
import '../components/paint_style.dart';

class NewDocumentView extends StatefulWidget {
  const NewDocumentView({
    super.key,
    required this.clipboard,
    required this.onCreate,
  });

  final ImageClipboard clipboard;
  final ValueChanged<Document> onCreate;

  @override
  State<NewDocumentView> createState() => _NewDocumentViewState();
}

class _NewDocumentViewState extends State<NewDocumentView> {
  final widthController = TextEditingController(text: '64');
  final heightController = TextEditingController(text: '64');
  String? clipboardError;

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  int? _parseSize(String text) {
    final size = int.tryParse(text);
    if (size == null ||
        size < Document.minimumSize ||
        size > Document.maximumSize) {
      return null;
    }
    return size;
  }

  String? _validate(String text) => _parseSize(text) == null
      ? '${Document.minimumSize} to ${Document.maximumSize}'
      : null;

  void _create() {
    final width = _parseSize(widthController.text);
    final height = _parseSize(heightController.text);
    if (width == null || height == null) return;
    widget.onCreate(Document.blank(width: width, height: height));
  }

  Future<void> _createFromClipboard() async {
    final image = await widget.clipboard.read();
    if (!mounted) return;
    final error = switch (image) {
      null => 'Clipboard has no image',
      _
          when image.width > Document.maximumSize ||
              image.height > Document.maximumSize =>
        'Image is larger than ${Document.maximumSize} × ${Document.maximumSize}',
      _ => null,
    };
    setState(() => clipboardError = error);
    if (image != null && error == null) {
      widget.onCreate(Document.fromImage(image: image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: PaintStyle.radius,
          border: Border.fromBorderSide(
            BorderSide(color: PaintStyle.dialogBorder),
          ),
          boxShadow: PaintStyle.faintShadow,
        ),
        child: ListenableBuilder(
          listenable: Listenable.merge([widthController, heightController]),
          builder: (context, _) {
            final valid =
                _parseSize(widthController.text) != null &&
                _parseSize(heightController.text) != null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                const Text(
                  'Create new',
                  style: TextStyle(
                    color: PaintStyle.titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _SizeField(
                  key: const Key('width'),
                  label: 'Width (px)',
                  controller: widthController,
                  validate: _validate,
                  onSubmitted: _create,
                ),
                _SizeField(
                  key: const Key('height'),
                  label: 'Height (px)',
                  controller: heightController,
                  validate: _validate,
                  onSubmitted: _create,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: PaintIconButton(
                    icon: FontAwesomeIcons.plus,
                    tooltip: 'Create',
                    onPressed: valid ? _create : null,
                  ),
                ),
                const Divider(height: 1, color: PaintStyle.separatorColor),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'From clipboard',
                        style: TextStyle(
                          color: PaintStyle.titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PaintIconButton(
                      icon: FontAwesomeIcons.paste,
                      tooltip: 'Create from clipboard',
                      onPressed: _createFromClipboard,
                    ),
                  ],
                ),
                if (clipboardError case final error?)
                  Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SizeField extends StatelessWidget {
  const _SizeField({
    super.key,
    required this.label,
    required this.controller,
    required this.validate,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String text) validate;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        labelText: label,
        errorText: validate(controller.text),
      ),
    );
  }
}
