import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../components/paint_icon_button.dart';
import '../components/paint_style.dart';

class NewDocumentView extends StatefulWidget {
  const NewDocumentView({super.key, required this.onCreate});

  final ValueChanged<Document> onCreate;

  @override
  State<NewDocumentView> createState() => _NewDocumentViewState();
}

class _NewDocumentViewState extends State<NewDocumentView> {
  final widthController = TextEditingController(text: '64');
  final heightController = TextEditingController(text: '64');

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
