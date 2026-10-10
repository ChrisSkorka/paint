import 'dart:async';

import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/files/image_clipboard.dart';

class StubImageClipboard implements ImageClipboard {
  StubImageClipboard({this.image, this.holdReads = false});

  Layer? image;
  final bool holdReads;
  final written = <Layer>[];
  final pendingReads = <Completer<Layer?>>[];

  @override
  Future<void> write(Layer image) async {
    written.add(image);
    this.image = image;
  }

  @override
  Future<Layer?> read() {
    if (!holdReads) return Future.value(image);
    final completer = Completer<Layer?>();
    pendingReads.add(completer);
    return completer.future;
  }
}
