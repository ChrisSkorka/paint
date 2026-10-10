import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';
import 'package:paint/widgets/views/editor_view.dart';

import '../../../test/support/desktop_view.dart';
import '../../support/samples.dart';

const _timeout = Timeout(Duration(minutes: 15));

Future<Offset> _pumpEditor(WidgetTester tester, {required int size}) async {
  useDesktopView(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: EditorView(
          document: Document.blank(width: size, height: size),
        ),
      ),
    ),
  );
  await _settle(tester);
  return tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(20, 20);
}

Future<void> _settle(WidgetTester tester) async {
  final layerTilesPainter =
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(PixelCanvas),
                  matching: find.byType(CustomPaint),
                ),
              )
              .foregroundPainter
          as LayerTilesPainter;
  while (layerTilesPainter.tileCache.loading) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }
}

Offset _step(int index) => Offset(index * 7.0, index * 3.0);

void main() {
  group('class EditorView', () {
    group('interactions', () {
      for (final size in canvasSizes) {
        group('${size}x$size canvas', () {
          testWidgets('hover frame', timeout: _timeout, (tester) async {
            final origin = await _pumpEditor(tester, size: size);
            final gesture = await tester.createGesture(
              kind: PointerDeviceKind.mouse,
            );
            await gesture.addPointer(location: origin);
            addTearDown(gesture.removePointer);
            await tester.pump();
            final frames = <Duration>[];
            final settled = <Duration>[];
            for (var index = 0; index < frameSampleCount; index++) {
              final frame = await measure(() async {
                await gesture.moveTo(origin + _step(index + 1));
                await tester.pump();
              });
              final settle = await measure(() => _settle(tester));
              frames.add(frame);
              settled.add(frame + settle);
            }
            report(name: 'EditorView $size hover frame', samples: frames);
            report(
              name: 'EditorView $size hover frame settled',
              samples: settled,
            );
          });

          testWidgets('stroke move frame', timeout: _timeout, (tester) async {
            final origin = await _pumpEditor(tester, size: size);
            final gesture = await tester.startGesture(
              origin,
              kind: PointerDeviceKind.mouse,
            );
            await tester.pump();
            final frames = <Duration>[];
            final settled = <Duration>[];
            for (var index = 0; index < frameSampleCount; index++) {
              final frame = await measure(() async {
                await gesture.moveTo(origin + _step(index + 1));
                await tester.pump();
              });
              final settle = await measure(() => _settle(tester));
              frames.add(frame);
              settled.add(frame + settle);
            }
            await gesture.up();
            await tester.pump();
            report(name: 'EditorView $size stroke move frame', samples: frames);
            report(
              name: 'EditorView $size stroke move frame settled',
              samples: settled,
            );
          });

          testWidgets('stroke start frame', timeout: _timeout, (tester) async {
            final origin = await _pumpEditor(tester, size: size);
            final frames = <Duration>[];
            final settled = <Duration>[];
            for (var index = 0; index < strokeSampleCount; index++) {
              late TestGesture gesture;
              final frame = await measure(() async {
                gesture = await tester.startGesture(
                  origin + _step(index),
                  kind: PointerDeviceKind.mouse,
                );
                await tester.pump();
              });
              final settle = await measure(() => _settle(tester));
              frames.add(frame);
              settled.add(frame + settle);
              await gesture.up();
              await tester.pump();
            }
            report(
              name: 'EditorView $size stroke start frame',
              samples: frames,
            );
            report(
              name: 'EditorView $size stroke start frame settled',
              samples: settled,
            );
          });

          testWidgets('stroke end frame', timeout: _timeout, (tester) async {
            final origin = await _pumpEditor(tester, size: size);
            final frames = <Duration>[];
            final settled = <Duration>[];
            for (var index = 0; index < strokeSampleCount; index++) {
              final gesture = await tester.startGesture(
                origin + _step(index),
                kind: PointerDeviceKind.mouse,
              );
              await tester.pump();
              final frame = await measure(() async {
                await gesture.up();
                await tester.pump();
              });
              final settle = await measure(() => _settle(tester));
              frames.add(frame);
              settled.add(frame + settle);
            }
            report(name: 'EditorView $size stroke end frame', samples: frames);
            report(
              name: 'EditorView $size stroke end frame settled',
              samples: settled,
            );
          });
        });
      }
    });
  });
}
