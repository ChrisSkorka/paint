import 'dart:ui';

class StubCanvas implements Canvas {
  final drawnRectangles = <(Rect, int)>[];
  final drawnPaths = <(Rect, int)>[];
  final clippedRectangles = <Rect>[];
  final savedLayers = <(Rect?, int)>[];
  final savedLayerFilters = <ColorFilter?>[];
  var restoreCount = 0;

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    savedLayers.add((bounds, paint.color.toARGB32()));
    savedLayerFilters.add(paint.colorFilter);
  }

  @override
  void restore() => restoreCount++;

  @override
  void drawRect(Rect rect, Paint paint) =>
      drawnRectangles.add((rect, paint.color.toARGB32()));

  @override
  void drawPath(Path path, Paint paint) =>
      drawnPaths.add((path.getBounds(), paint.color.toARGB32()));

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) => clippedRectangles.add(rect);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
