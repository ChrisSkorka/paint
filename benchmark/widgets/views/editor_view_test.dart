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
  return tester.getTopLeft(find.byType(PixelCanvas)) + const Offset(20, 20);
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
            final samples = <Duration>[];
            for (var index = 0; index < frameSampleCount; index++) {
              samples.add(
                await measure(() async {
                  await gesture.moveTo(origin + _step(index + 1));
                  await tester.pump();
                }),
              );
            }
            report(name: 'EditorView $size hover frame', samples: samples);
          });

          testWidgets('stroke move frame', timeout: _timeout, (tester) async {
            final origin = await _pumpEditor(tester, size: size);
            final gesture = await tester.startGesture(
              origin,
              kind: PointerDeviceKind.mouse,
            );
            await tester.pump();
            final samples = <Duration>[];
            for (var index = 0; index < frameSampleCount; index++) {
              samples.add(
                await measure(() async {
                  await gesture.moveTo(origin + _step(index + 1));
                  await tester.pump();
                }),
              );
            }
            await gesture.up();
            await tester.pump();
            report(
              name: 'EditorView $size stroke move frame',
              samples: samples,
            );
          });

          testWidgets('stroke start frame', timeout: _timeout, (tester) async {
            final origin = await _pumpEditor(tester, size: size);
            final samples = <Duration>[];
            for (var index = 0; index < strokeSampleCount; index++) {
              late TestGesture gesture;
              samples.add(
                await measure(() async {
                  gesture = await tester.startGesture(
                    origin + _step(index),
                    kind: PointerDeviceKind.mouse,
                  );
                  await tester.pump();
                }),
              );
              await gesture.up();
              await tester.pump();
            }
            report(
              name: 'EditorView $size stroke start frame',
              samples: samples,
            );
          });

          testWidgets('stroke end frame', timeout: _timeout, (tester) async {
            final origin = await _pumpEditor(tester, size: size);
            final samples = <Duration>[];
            for (var index = 0; index < strokeSampleCount; index++) {
              final gesture = await tester.startGesture(
                origin + _step(index),
                kind: PointerDeviceKind.mouse,
              );
              await tester.pump();
              samples.add(
                await measure(() async {
                  await gesture.up();
                  await tester.pump();
                }),
              );
            }
            report(name: 'EditorView $size stroke end frame', samples: samples);
          });
        });
      }
    });
  });
}
