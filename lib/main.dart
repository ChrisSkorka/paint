// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

import 'editor/files/system_image_clipboard.dart';
import 'widgets/views/paint_app.dart';

void main() {
  runApp(
    PaintApp(
      clipboard: SystemImageClipboard(clipboard: SystemClipboard.instance),
    ),
  );
}
