import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/canvas/document.dart';
import '../../editor/canvas/layer.dart';
import '../../editor/canvas/pixel_point.dart';
import '../../editor/canvas/pixel_rectangle.dart';
import 'chess_grid.dart';
import 'paint_icon_button.dart';
import 'paint_style.dart';
import 'pixel_canvas.dart';

typedef ImageResize = ({int width, int height, PixelPoint offset});

Future<ImageResize?> showResizeDialog({
  required BuildContext context,
  required Layer image,
}) {
  return showDialog<ImageResize>(
    context: context,
    builder: (context) => ResizeDialog(image: image),
  );
}

class ResizeDialog extends StatefulWidget {
  const ResizeDialog({super.key, required this.image});

  static const previewSize = 256.0;
  static const fieldWidth = 96.0;

  final Layer image;

  @override
  State<ResizeDialog> createState() => _ResizeDialogState();
}

class _ResizeDialogState extends State<ResizeDialog> {
  late final widthController = TextEditingController(
    text: '${widget.image.width}',
  );
  late final heightController = TextEditingController(
    text: '${widget.image.height}',
  );
  final offsetXController = TextEditingController(text: '0');
  final offsetYController = TextEditingController(text: '0');
  late final fields = Listenable.merge([
    widthController,
    heightController,
    offsetXController,
    offsetYController,
  ]);
  late Layer thumbnail;
  int? thumbnailSize;

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    offsetXController.dispose();
    offsetYController.dispose();
    super.dispose();
  }

  static int? _parseSize(String text) {
    final size = int.tryParse(text);
    if (size == null ||
        size < Document.minimumSize ||
        size > Document.maximumSize) {
      return null;
    }
    return size;
  }

  static int? _parseOffset(String text) {
    final offset = int.tryParse(text);
    if (offset == null || offset.abs() > Document.maximumSize) return null;
    return offset;
  }

  ImageResize? _resize() {
    final width = _parseSize(widthController.text);
    final height = _parseSize(heightController.text);
    final offsetX = _parseOffset(offsetXController.text);
    final offsetY = _parseOffset(offsetYController.text);
    if (width == null || height == null || offsetX == null || offsetY == null) {
      return null;
    }
    return (
      width: width,
      height: height,
      offset: PixelPoint(x: offsetX, y: offsetY),
    );
  }

  void _center({required int width, required int height}) {
    offsetXController.text = '${(width - widget.image.width) ~/ 2}';
    offsetYController.text = '${(height - widget.image.height) ~/ 2}';
  }

  void _submit() {
    final resize = _resize();
    if (resize != null) Navigator.of(context).pop(resize);
  }

  Layer _thumbnail({required int maximumSize}) {
    if (maximumSize != thumbnailSize) {
      thumbnail = Layer.thumbnail(
        layer: widget.image,
        maximumSize: maximumSize,
      );
      thumbnailSize = maximumSize;
    }
    return thumbnail;
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String allowedCharacters,
    required String? error,
  }) {
    return SizedBox(
      width: ResizeDialog.fieldWidth,
      child: TextField(
        key: Key(label),
        controller: controller,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(allowedCharacters)),
        ],
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(labelText: label, errorText: error),
      ),
    );
  }

  Widget _buildPreview({required ImageResize? resize}) {
    if (resize == null) {
      return const SizedBox.square(dimension: ResizeDialog.previewSize);
    }
    final scale = ResizeDialog.previewSize / max(resize.width, resize.height);
    final image = widget.image;
    final imageSize = max(image.width, image.height);
    final thumbnail = _thumbnail(
      maximumSize: min(imageSize, max(1, (imageSize * scale).ceil())),
    );
    return SizedBox.square(
      dimension: ResizeDialog.previewSize,
      child: Center(
        child: CustomPaint(
          painter: const ChessGridPainter(),
          foregroundPainter: ResizePreviewPainter(
            thumbnail: thumbnail,
            origin: Offset(resize.offset.x * scale, resize.offset.y * scale),
            scale: image.width * scale / thumbnail.width,
          ),
          size: Size(resize.width * scale, resize.height * scale),
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
        child: ListenableBuilder(
          listenable: fields,
          builder: (context, _) {
            final width = _parseSize(widthController.text);
            final height = _parseSize(heightController.text);
            final resize = _resize();
            const sizeError =
                '${Document.minimumSize} to ${Document.maximumSize}';
            const offsetError =
                '-${Document.maximumSize} to ${Document.maximumSize}';
            return IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Text(
                    'Resize image',
                    style: TextStyle(
                      color: PaintStyle.titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      _field(
                        label: 'Width (px)',
                        controller: widthController,
                        allowedCharacters: '[0-9]',
                        error: width == null ? sizeError : null,
                      ),
                      _field(
                        label: 'Height (px)',
                        controller: heightController,
                        allowedCharacters: '[0-9]',
                        error: height == null ? sizeError : null,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      _field(
                        label: 'Offset X (px)',
                        controller: offsetXController,
                        allowedCharacters: '[0-9-]',
                        error: _parseOffset(offsetXController.text) == null
                            ? offsetError
                            : null,
                      ),
                      _field(
                        label: 'Offset Y (px)',
                        controller: offsetYController,
                        allowedCharacters: '[0-9-]',
                        error: _parseOffset(offsetYController.text) == null
                            ? offsetError
                            : null,
                      ),
                      PaintIconButton(
                        icon: FontAwesomeIcons.crosshairs,
                        tooltip: 'Center image',
                        onPressed: width != null && height != null
                            ? () => _center(width: width, height: height)
                            : null,
                      ),
                    ],
                  ),
                  DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      border: Border.all(color: PaintStyle.dialogBorder),
                    ),
                    child: _buildPreview(resize: resize),
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
                          onPressed: resize != null ? _submit : null,
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

class ResizePreviewPainter extends CustomPainter {
  const ResizePreviewPainter({
    required this.thumbnail,
    required this.origin,
    required this.scale,
  });

  final Layer thumbnail;
  final Offset origin;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    PixelLayersPainter.paintArea(
      canvas: canvas,
      pixels: thumbnail,
      area: PixelRectangle.fromEdges(
        left: (-origin.dx / scale).floor(),
        top: (-origin.dy / scale).floor(),
        right: ((size.width - origin.dx) / scale).ceil(),
        bottom: ((size.height - origin.dy) / scale).ceil(),
      ),
      zoom: 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ResizePreviewPainter oldDelegate) =>
      !identical(oldDelegate.thumbnail, thumbnail) ||
      oldDelegate.origin != origin ||
      oldDelegate.scale != scale;
}
