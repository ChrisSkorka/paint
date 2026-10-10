import 'package:flutter/material.dart';

import '../../editor/files/image_clipboard.dart';
import '../components/paint_style.dart';
import 'home_view.dart';

class PaintApp extends StatelessWidget {
  const PaintApp({super.key, required this.clipboard});

  final ImageClipboard clipboard;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint',
      debugShowCheckedModeBanner: false,
      theme: PaintStyle.theme(),
      home: HomeView(clipboard: clipboard),
    );
  }
}
