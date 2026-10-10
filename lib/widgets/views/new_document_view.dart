import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/files/document_codec.dart';
import '../../editor/files/document_format_exception.dart';
import '../../editor/files/document_library.dart';
import '../../editor/files/file_access.dart';
import '../../editor/files/image_clipboard.dart';
import '../../editor/files/stored_document.dart';
import '../components/paint_style.dart';
import '../components/paint_wide_button.dart';
import '../components/stored_document_list.dart';

class NewDocumentView extends StatefulWidget {
  const NewDocumentView({
    super.key,
    required this.clipboard,
    required this.files,
    required this.library,
    required this.onCreate,
  });

  final ImageClipboard clipboard;
  final FileAccess files;
  final DocumentLibrary library;
  final ValueChanged<Document> onCreate;

  @override
  State<NewDocumentView> createState() => _NewDocumentViewState();
}

class _NewDocumentViewState extends State<NewDocumentView> {
  final nameController = TextEditingController(text: Document.untitledName);
  final widthController = TextEditingController(text: '64');
  final heightController = TextEditingController(text: '64');
  String? error;

  @override
  void initState() {
    super.initState();
    widget.library.refresh();
  }

  @override
  void dispose() {
    nameController.dispose();
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

  String _name() {
    final name = nameController.text.trim();
    return name.isEmpty ? Document.untitledName : name;
  }

  void _create() {
    final width = _parseSize(widthController.text);
    final height = _parseSize(heightController.text);
    if (width == null || height == null) return;
    widget.onCreate(
      Document.blank(name: _name(), width: width, height: height),
    );
  }

  Future<void> _createFromClipboard() async {
    await _openWith(() async {
      final image = await widget.clipboard.read();
      if (image == null) {
        throw const DocumentFormatException(message: 'Clipboard has no image');
      }
      DocumentFormatException.checkSize(
        width: image.width,
        height: image.height,
      );
      return Document.fromImage(name: _name(), image: image);
    });
  }

  Future<void> _openFile() async {
    await _openWith(() async {
      final file = await widget.files.open();
      if (file == null) return null;
      return DocumentCodec.decode(fileName: file.name, bytes: file.bytes);
    });
  }

  Future<void> _openStored(StoredDocument entry) async {
    await _openWith(() => widget.library.open(entry: entry));
  }

  Future<void> _openWith(Future<Document?> Function() load) async {
    try {
      final document = await load();
      if (!mounted) return;
      setState(() => error = null);
      if (document != null) widget.onCreate(document);
    } on DocumentFormatException catch (exception) {
      if (mounted) setState(() => error = exception.message);
    }
  }

  Future<void> _deleteStored(StoredDocument entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${entry.name}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.library.delete(entry: entry);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            _Card(width: 280, child: _buildCreate(context)),
            _Card(
              width: 320,
              child: ListenableBuilder(
                listenable: widget.library,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    const _Heading(text: 'Saved documents'),
                    StoredDocumentList(
                      documents: widget.library.documents,
                      onOpen: _openStored,
                      onDelete: _deleteStored,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreate(BuildContext context) {
    return ListenableBuilder(
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
            const _Heading(text: 'Open'),
            TextField(
              key: const Key('name'),
              controller: nameController,
              onSubmitted: (_) => _create(),
              decoration: const InputDecoration(labelText: 'Name'),
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
            PaintWideButton(
              label: 'Create new',
              icon: FontAwesomeIcons.plus,
              onPressed: valid ? _create : null,
            ),
            const Divider(height: 1, color: PaintStyle.separatorColor),
            PaintWideButton(
              label: 'From clipboard',
              icon: FontAwesomeIcons.paste,
              onPressed: _createFromClipboard,
            ),
            PaintWideButton(
              label: 'From file',
              icon: FontAwesomeIcons.folderOpen,
              onPressed: _openFile,
            ),
            if (error case final error?)
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: PaintStyle.radius,
        border: Border.fromBorderSide(
          BorderSide(color: PaintStyle.dialogBorder),
        ),
        boxShadow: PaintStyle.faintShadow,
      ),
      child: child,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: PaintStyle.titleColor,
        fontWeight: FontWeight.bold,
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
