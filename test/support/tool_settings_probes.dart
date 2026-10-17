import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/editor_controller.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/text_format.dart';
import 'package:paint/editor/tools/tool_kind.dart';

List<Object> toolSettings(EditorController editorController) => [
  editorController.toolKind,
  editorController.primaryColor,
  editorController.secondaryColor,
  editorController.penSize,
  editorController.penTip,
  editorController.shapeOutlined,
  editorController.shapeFilled,
  editorController.textFormat,
];

const defaultToolSettings = <Object>[
  ToolKind.pen,
  PixelColor.black,
  PixelColor.white,
  1,
  BrushTip.square,
  true,
  false,
  TextFormat(),
];
