import 'package:flutter/material.dart';

import '../components/paint_style.dart';
import 'home_view.dart';

class PaintApp extends StatelessWidget {
  const PaintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint',
      debugShowCheckedModeBanner: false,
      theme: PaintStyle.theme(),
      home: const HomeView(),
    );
  }
}
