import 'dart:math';

import 'package:flutter/material.dart';

class StableText extends StatelessWidget {
  const StableText({super.key, required this.text, required this.alternatives});

  final String text;
  final List<String> alternatives;

  double _measure(BuildContext context, String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: DefaultTextStyle.of(context).style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = textPainter.width;
    textPainter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final width = [
      text,
      ...alternatives,
    ].map((candidate) => _measure(context, candidate)).reduce(max);
    return SizedBox(
      width: width.ceilToDouble(),
      child: Text(text, maxLines: 1, softWrap: false),
    );
  }
}
