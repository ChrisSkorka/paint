import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/pointer_button.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';

import '../../../support/hover.dart';
import '../../../support/view_probes.dart';

void main() {
  group('class PixelCanvas', () {
    group('render', () {
      group('painters', () {
        testWidgets('canvas size', (tester) async {
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: const [],
                onPointerDown: ({required point, required button}) {},
                onPointerMove: ({required point}) {},
                onPointerUp: ({required point}) {},
                onPointerExit: () {},
              ),
            ),
          );
          final actual = canvasSize(tester);
          const expected = Size(12, 8);
          expect(actual, equals(expected));
        });
        testWidgets('layers and zoom', (tester) async {
          final layer = Layer.filled(
            width: 3,
            height: 2,
            color: PixelColor.black,
          );
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: [layer],
                onPointerDown: ({required point, required button}) {},
                onPointerMove: ({required point}) {},
                onPointerUp: ({required point}) {},
                onPointerExit: () {},
              ),
            ),
          );
          final pixelLayersPainter = tester
              .widgetList<CustomPaint>(
                find.descendant(
                  of: find.byType(PixelCanvas),
                  matching: find.byType(CustomPaint),
                ),
              )
              .map((customPaint) => customPaint.foregroundPainter)
              .whereType<PixelLayersPainter>()
              .single;
          final actual = [pixelLayersPainter.layers, pixelLayersPainter.zoom];
          final expected = [
            [layer],
            4,
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('pointer down', () {
        testWidgets('primary', (tester) async {
          final events = <List<Object>>[];
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: const [],
                onPointerDown: ({required point, required button}) =>
                    events.add(['down', point, button]),
                onPointerMove: ({required point}) =>
                    events.add(['move', point]),
                onPointerUp: ({required point}) => events.add(['up', point]),
                onPointerExit: () => events.add(['exit']),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(5, 1));
          final actual = events;
          const expected = [
            ['down', PixelPoint(x: 1, y: 0), PointerButton.primary],
            ['up', PixelPoint(x: 1, y: 0)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('secondary', (tester) async {
          final events = <List<Object>>[];
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: const [],
                onPointerDown: ({required point, required button}) =>
                    events.add(['down', point, button]),
                onPointerMove: ({required point}) =>
                    events.add(['move', point]),
                onPointerUp: ({required point}) => events.add(['up', point]),
                onPointerExit: () => events.add(['exit']),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(
            topLeft + const Offset(1, 5),
            buttons: kSecondaryMouseButton,
            kind: PointerDeviceKind.mouse,
          );
          final actual = events;
          const expected = [
            ['down', PixelPoint(x: 0, y: 1), PointerButton.secondary],
            ['up', PixelPoint(x: 0, y: 1)],
          ];
          expect(actual, equals(expected));
        });
      });

      group('pointer move', () {
        testWidgets('drag', (tester) async {
          final events = <List<Object>>[];
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: const [],
                onPointerDown: ({required point, required button}) =>
                    events.add(['down', point, button]),
                onPointerMove: ({required point}) =>
                    events.add(['move', point]),
                onPointerUp: ({required point}) => events.add(['up', point]),
                onPointerExit: () => events.add(['exit']),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.moveTo(topLeft + const Offset(9, 5));
          await gesture.up();
          final actual = events;
          const expected = [
            ['down', PixelPoint(x: 0, y: 0), PointerButton.primary],
            ['move', PixelPoint(x: 2, y: 1)],
            ['up', PixelPoint(x: 2, y: 1)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('hover', (tester) async {
          final events = <List<Object>>[];
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: const [],
                onPointerDown: ({required point, required button}) =>
                    events.add(['down', point, button]),
                onPointerMove: ({required point}) =>
                    events.add(['move', point]),
                onPointerUp: ({required point}) => events.add(['up', point]),
                onPointerExit: () => events.add(['exit']),
              ),
            ),
          );
          await hoverOver(tester, find.byType(PixelCanvas));
          final actual = events;
          const expected = [
            ['move', PixelPoint(x: 1, y: 1)],
          ];
          expect(actual, equals(expected));
        });
      });

      group('pointer up', () {
        testWidgets('cancel', (tester) async {
          final events = <List<Object>>[];
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: const [],
                onPointerDown: ({required point, required button}) =>
                    events.add(['down', point, button]),
                onPointerMove: ({required point}) =>
                    events.add(['move', point]),
                onPointerUp: ({required point}) => events.add(['up', point]),
                onPointerExit: () => events.add(['exit']),
              ),
            ),
          );
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.cancel();
          final actual = events;
          const expected = [
            ['down', PixelPoint(x: 0, y: 0), PointerButton.primary],
            ['up', PixelPoint(x: 0, y: 0)],
          ];
          expect(actual, equals(expected));
        });
      });

      group('pointer exit', () {
        testWidgets('leave canvas', (tester) async {
          final events = <List<Object>>[];
          await tester.pumpWidget(
            Center(
              child: PixelCanvas(
                width: 3,
                height: 2,
                zoom: 4,
                layers: const [],
                onPointerDown: ({required point, required button}) =>
                    events.add(['down', point, button]),
                onPointerMove: ({required point}) =>
                    events.add(['move', point]),
                onPointerUp: ({required point}) => events.add(['up', point]),
                onPointerExit: () => events.add(['exit']),
              ),
            ),
          );
          final gesture = await hoverOver(tester, find.byType(PixelCanvas));
          await gesture.moveTo(Offset.zero);
          final actual = events;
          const expected = [
            ['move', PixelPoint(x: 1, y: 1)],
            ['exit'],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
