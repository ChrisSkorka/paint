import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:super_clipboard/super_clipboard.dart';

import '../canvas/layer.dart';
import 'image_clipboard.dart';
import 'image_codec.dart';

class SystemImageClipboard implements ImageClipboard {
  const SystemImageClipboard({required this.clipboard});

  static const readableFormats = [
    Formats.png,
    Formats.jpeg,
    Formats.gif,
    Formats.bmp,
    Formats.tiff,
    Formats.webp,
  ];

  final SystemClipboard? clipboard;

  @override
  Future<void> write(Layer image) async {
    final item = DataWriterItem()
      ..add(Formats.png(ImageCodec.encodePng(layer: image)));
    await clipboard?.write([item]);
  }

  @override
  Future<Layer?> read() async {
    final reader = await clipboard?.read();
    if (reader == null) return null;
    final format = readableFormats.firstWhereOrNull(reader.canProvide);
    if (format == null) return null;
    final completer = Completer<Uint8List?>();
    final progress = reader.getFile(
      format,
      (file) async => completer.complete(await file.readAll()),
      onError: (_) => completer.complete(null),
    );
    if (progress == null) return null;
    final bytes = await completer.future;
    return bytes == null ? null : ImageCodec.decode(bytes: bytes);
  }
}
