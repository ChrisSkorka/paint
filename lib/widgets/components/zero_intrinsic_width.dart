import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ZeroIntrinsicWidth extends SingleChildRenderObjectWidget {
  const ZeroIntrinsicWidth({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderZeroIntrinsicWidth();
}

class RenderZeroIntrinsicWidth extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;
}
