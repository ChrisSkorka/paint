import 'package:flutter/widgets.dart';

class CanvasScrollController extends ScrollController {
  CanvasScrollController({required this.restingPosition});

  final double restingPosition;
  double leading = 0;
  double? pendingOffset;
  double? _anchoredLeading;

  double anchoredOffset({required double pixels}) {
    final anchoredLeading = _anchoredLeading;
    final pending = pendingOffset;
    _anchoredLeading = leading;
    pendingOffset = null;
    return pending ??
        (anchoredLeading == null
            ? leading - restingPosition
            : pixels + leading - anchoredLeading);
  }

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => CanvasScrollPosition(
    physics: physics,
    context: context,
    oldPosition: oldPosition,
    initialPixels: initialScrollOffset,
    keepScrollOffset: keepScrollOffset,
    debugLabel: debugLabel,
    controller: this,
  );
}

class CanvasScrollPosition extends ScrollPositionWithSingleContext {
  CanvasScrollPosition({
    required super.physics,
    required super.context,
    required super.oldPosition,
    required super.initialPixels,
    required super.keepScrollOffset,
    required super.debugLabel,
    required this.controller,
  });

  final CanvasScrollController controller;

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    final target = controller
        .anchoredOffset(pixels: pixels)
        .clamp(minScrollExtent, maxScrollExtent);
    if (target != pixels) correctBy(target - pixels);
    return super.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }
}
