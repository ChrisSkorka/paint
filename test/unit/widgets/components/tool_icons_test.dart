import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/editor/tools/brush_tip.dart';
import 'package:paint/editor/tools/tool_kind.dart';
import 'package:paint/widgets/components/tool_icons.dart';

void main() {
  group('standalone', () {
    group('function toolIcon', () {
      group('kinds', () {
        test('all kinds', () {
          final actual = [
            for (final kind in ToolKind.values) toolIcon(kind: kind).codePoint,
          ];
          final expected = [
            FontAwesomeIcons.pencil.codePoint,
            FontAwesomeIcons.eraser.codePoint,
            FontAwesomeIcons.fill.codePoint,
            FontAwesomeIcons.slash.codePoint,
            FontAwesomeIcons.square.codePoint,
            FontAwesomeIcons.circle.codePoint,
            FontAwesomeIcons.arrowRight.codePoint,
            FontAwesomeIcons.eyeDropper.codePoint,
            FontAwesomeIcons.borderTopLeft.codePoint,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('function tipIcon', () {
      group('tips', () {
        test('all tips', () {
          final actual = [
            for (final tip in BrushTip.values) tipIcon(tip: tip).codePoint,
          ];
          final expected = [
            FontAwesomeIcons.square.codePoint,
            FontAwesomeIcons.circle.codePoint,
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
