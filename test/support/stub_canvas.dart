import 'dart:ui';

class StubCanvas implements Canvas {
  final drawnRectangles = <(Rect, int)>[];

  @override
  void drawRect(Rect rect, Paint paint) =>
      drawnRectangles.add((rect, paint.color.toARGB32()));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
