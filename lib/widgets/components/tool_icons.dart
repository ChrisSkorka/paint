import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/tools/brush_tip.dart';
import '../../editor/tools/tool_kind.dart';

FaIconData toolIcon({required ToolKind kind}) => switch (kind) {
  ToolKind.pen => FontAwesomeIcons.pencil,
  ToolKind.eraser => FontAwesomeIcons.eraser,
  ToolKind.bucketFill => FontAwesomeIcons.fill,
  ToolKind.line => FontAwesomeIcons.slash,
  ToolKind.rectangle => FontAwesomeIcons.square,
  ToolKind.circle => FontAwesomeIcons.circle,
  ToolKind.arrow => FontAwesomeIcons.arrowRight,
  ToolKind.text => FontAwesomeIcons.font,
  ToolKind.colorPicker => FontAwesomeIcons.eyeDropper,
  ToolKind.select => FontAwesomeIcons.borderTopLeft,
};

FaIconData tipIcon({required BrushTip tip}) => switch (tip) {
  BrushTip.square => FontAwesomeIcons.square,
  BrushTip.circle => FontAwesomeIcons.circle,
};
