typedef CanvasMargin = ({double leading, double trailing, bool reverse});

CanvasMargin canvasMargin({
  required double available,
  required double extent,
  required double edge,
  required double scrollbar,
}) {
  final free = available - scrollbar - extent - 2 * edge;
  return free > 0
      ? (leading: edge + free, trailing: edge + free + scrollbar, reverse: true)
      : (leading: edge, trailing: edge + scrollbar, reverse: false);
}
