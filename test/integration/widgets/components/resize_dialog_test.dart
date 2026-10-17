import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/widgets/components/resize_dialog.dart';

import '../../../support/desktop_view.dart';
import '../../../support/layer_probes.dart';
import '../../../support/resize_dialog_probes.dart';

void main() {
  const red = 0xFFFF0000;
  const green = 0xFF00FF00;

  group('class ResizeDialog', () {
    group('render', () {
      group('initial values', () {
        testWidgets('fields', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          final actual = [
            resizeFieldTexts(tester),
            resizeFieldErrors(tester),
            resizeButtonEnabled(tester, tooltip: 'OK'),
            resizeButtonEnabled(tester, tooltip: 'Center image'),
          ];
          const expected = [
            ['2', '1', '0', '0'],
            [null, null, null, null],
            true,
            true,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('preview', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          final actual = resizePreviewState(tester);
          final expected = [
            const Size(256, 128),
            layerFromRows([
              [red, green],
            ]),
            Offset.zero,
            128.0,
          ];
          expect(actual, equals(expected));
        });
      });
      group('layout', () {
        testWidgets('center button', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          final actual = tester.getCenter(find.byTooltip('Center image')).dy;
          final expected = tester.getCenter(resizeField('Offset X (px)')).dy;
          expect(actual, equals(expected));
        });
        testWidgets('dialog width', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          final actual = tester
              .getSize(
                find.descendant(
                  of: find.byType(Dialog),
                  matching: find.byType(Material),
                ),
              )
              .width;
          const expected = ResizeDialog.previewSize + 32;
          expect(actual, equals(expected));
        });
      });
      group('invalid values', () {
        testWidgets('zero width', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          await tester.enterText(resizeField('Width (px)'), '0');
          await tester.pump();
          final actual = [
            resizeFieldErrors(tester),
            resizeButtonEnabled(tester, tooltip: 'OK'),
            resizeButtonEnabled(tester, tooltip: 'Center image'),
            tester.widgetList(resizePreview()).length,
          ];
          const expected = [
            ['1 to 4096', null, null, null],
            false,
            false,
            0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('large height', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          await tester.enterText(resizeField('Height (px)'), '4097');
          await tester.pump();
          final actual = [
            resizeFieldErrors(tester),
            resizeButtonEnabled(tester, tooltip: 'OK'),
            resizeButtonEnabled(tester, tooltip: 'Center image'),
          ];
          const expected = [
            [null, '1 to 4096', null, null],
            false,
            false,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('empty offset x', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          await tester.enterText(resizeField('Offset X (px)'), '');
          await tester.pump();
          final actual = [
            resizeFieldErrors(tester),
            resizeButtonEnabled(tester, tooltip: 'OK'),
            resizeButtonEnabled(tester, tooltip: 'Center image'),
          ];
          const expected = [
            [null, null, '-4096 to 4096', null],
            false,
            true,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('large offset y', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          await tester.enterText(resizeField('Offset Y (px)'), '-4097');
          await tester.pump();
          final actual = [
            resizeFieldErrors(tester),
            resizeButtonEnabled(tester, tooltip: 'OK'),
          ];
          const expected = [
            [null, null, null, '-4096 to 4096'],
            false,
          ];
          expect(actual, equals(expected));
        });
      });
      group('preview', () {
        testWidgets('larger canvas', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          await tester.enterText(resizeField('Width (px)'), '4');
          await tester.enterText(resizeField('Height (px)'), '2');
          await tester.enterText(resizeField('Offset X (px)'), '1');
          await tester.pump();
          final actual = resizePreviewState(tester);
          final expected = [
            const Size(256, 128),
            layerFromRows([
              [red, green],
            ]),
            const Offset(64, 0),
            64.0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('larger image', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: Layer.filled(
                  width: 8,
                  height: 8,
                  color: PixelColor.black,
                ),
              ),
            ),
          );
          await tester.enterText(resizeField('Width (px)'), '512');
          await tester.enterText(resizeField('Height (px)'), '512');
          await tester.pump();
          final actual = resizePreviewState(tester);
          final expected = [
            const Size(256, 256),
            Layer.filled(width: 4, height: 4, color: PixelColor.black),
            Offset.zero,
            1.0,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('offset change', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          final before = resizePreviewState(tester)[1];
          await tester.enterText(resizeField('Offset X (px)'), '-1');
          await tester.pump();
          final after = resizePreviewState(tester)[1];
          final actual = identical(before, after);
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('center', () {
        testWidgets('larger canvas', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green],
                ]),
              ),
            ),
          );
          await tester.enterText(resizeField('Width (px)'), '5');
          await tester.enterText(resizeField('Height (px)'), '4');
          await tester.pump();
          await tester.tap(find.byTooltip('Center image'));
          await tester.pump();
          final actual = resizeFieldTexts(tester);
          const expected = ['5', '4', '1', '1'];
          expect(actual, equals(expected));
        });
        testWidgets('smaller canvas', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            MaterialApp(
              home: ResizeDialog(
                image: layerFromRows([
                  [red, green, red],
                ]),
              ),
            ),
          );
          await tester.enterText(resizeField('Width (px)'), '1');
          await tester.pump();
          await tester.tap(find.byTooltip('Center image'));
          await tester.pump();
          final actual = resizeFieldTexts(tester);
          const expected = ['1', '1', '-1', '0'];
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('standalone', () {
    group('function showResizeDialog', () {
      group('results', () {
        testWidgets('ok unchanged', (tester) async {
          useDesktopView(tester);
          final results = <ImageResize?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showResizeDialog(
                      context: context,
                      image: layerFromRows([
                        [red, green],
                      ]),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = results;
          const expected = [
            (width: 2, height: 1, offset: PixelPoint(x: 0, y: 0)),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('enter edited', (tester) async {
          useDesktopView(tester);
          final results = <ImageResize?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showResizeDialog(
                      context: context,
                      image: layerFromRows([
                        [red, green],
                      ]),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.enterText(resizeField('Width (px)'), '3');
          await tester.enterText(resizeField('Offset Y (px)'), '-2');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          final actual = results;
          const expected = [
            (width: 3, height: 1, offset: PixelPoint(x: 0, y: -2)),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('enter invalid', (tester) async {
          useDesktopView(tester);
          final results = <ImageResize?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showResizeDialog(
                      context: context,
                      image: layerFromRows([
                        [red, green],
                      ]),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.enterText(resizeField('Width (px)'), '');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          final actual = [
            results,
            tester.widgetList(find.byType(ResizeDialog)).length,
          ];
          const expected = [<ImageResize?>[], 1];
          expect(actual, equals(expected));
        });
        testWidgets('cancel', (tester) async {
          useDesktopView(tester);
          final results = <ImageResize?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showResizeDialog(
                      context: context,
                      image: layerFromRows([
                        [red, green],
                      ]),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.enterText(resizeField('Width (px)'), '3');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = results;
          const expected = [null];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
