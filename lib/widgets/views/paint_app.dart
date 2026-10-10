import 'package:flutter/material.dart';

import '../../editor/files/document_library.dart';
import '../../editor/files/file_access.dart';
import '../../editor/files/image_clipboard.dart';
import '../components/paint_style.dart';
import 'home_view.dart';

class PaintApp extends StatelessWidget {
  const PaintApp({
    super.key,
    required this.clipboard,
    required this.files,
    required this.library,
  });

  final ImageClipboard clipboard;
  final FileAccess files;
  final DocumentLibrary library;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint',
      debugShowCheckedModeBanner: false,
      theme: PaintStyle.theme(),
      home: HomeView(clipboard: clipboard, files: files, library: library),
    );
  }
}
