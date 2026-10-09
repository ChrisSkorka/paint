import 'package:flutter/material.dart';
import 'package:paint/widgets/components/paint_style.dart';

bool isHoverSwatch(Widget widget) =>
    widget is Container &&
    widget.decoration ==
        BoxDecoration(
          color: const Color(0xFF112233),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: PaintStyle.focusShadow,
        );
