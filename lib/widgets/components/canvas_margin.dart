import 'dart:math';

typedef CanvasMargin = ({double leading, double trailing});

CanvasMargin canvasMargin({
  required double available,
  required double extent,
  required double visible,
  required double scrollbar,
}) {
  final strip = min(extent, visible);
  return (
    leading: max(0, available - scrollbar - strip),
    trailing: max(0, available - strip),
  );
}

double canvasOffset({
  required CanvasMargin margin,
  required double available,
  required double extent,
  required double position,
}) {
  final content = margin.leading + extent + margin.trailing;
  return (margin.leading - position).clamp(0, max(0, content - available));
}

double zoomedCanvasOffset({
  required double available,
  required int length,
  required double visible,
  required double scrollbar,
  required double offset,
  required double focus,
  required double oldScale,
  required double newScale,
}) {
  final oldMargin = canvasMargin(
    available: available,
    extent: length * oldScale,
    visible: visible,
    scrollbar: scrollbar,
  );
  final focusedPixel = (focus - (oldMargin.leading - offset)) / oldScale;
  final newExtent = length * newScale;
  return canvasOffset(
    margin: canvasMargin(
      available: available,
      extent: newExtent,
      visible: visible,
      scrollbar: scrollbar,
    ),
    available: available,
    extent: newExtent,
    position: focus - focusedPixel * newScale,
  );
}

double fittingScale({
  required double available,
  required int length,
  required double edge,
  required double scrollbar,
}) => (available - scrollbar - 2 * edge) / length;

double centeredCanvasOffset({
  required double available,
  required int length,
  required double visible,
  required double scrollbar,
  required double scale,
}) {
  final extent = length * scale;
  return canvasOffset(
    margin: canvasMargin(
      available: available,
      extent: extent,
      visible: visible,
      scrollbar: scrollbar,
    ),
    available: available,
    extent: extent,
    position: (available - scrollbar - extent) / 2,
  );
}
