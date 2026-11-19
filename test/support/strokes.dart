import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/editor_controller.dart';
import 'package:paint/editor/pointer_button.dart';

void strokePixel(
  EditorController editorController, {
  required int x,
  int? color,
}) {
  if (color != null) editorController.selectColor(PixelColor(argb: color));
  editorController.pointerDown(
    point: PixelPoint(x: x, y: 0),
    button: PointerButton.primary,
  );
  editorController.pointerUp(point: PixelPoint(x: x, y: 0));
}
