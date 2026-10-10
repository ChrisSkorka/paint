import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/files/gif_codec.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';
import 'package:paint/widgets/components/stored_document_list.dart';
import 'package:paint/widgets/views/paint_app.dart';

import '../../../support/color_dialog_probes.dart';
import '../../../support/desktop_view.dart';
import '../../../support/document_probes.dart';
import '../../../support/editor_view_probes.dart';
import '../../../support/keyboard.dart';
import '../../../support/view_probes.dart';
import '../../../support/stub_document_store.dart';
import '../../../support/stub_file_access.dart';
import '../../../support/stub_image_clipboard.dart';

void main() {
  group('class PaintApp', () {
    group('render', () {
      group('launch', () {
        testWidgets('new document tab', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(),
              library: stubDocumentLibrary(),
              clipboard: StubImageClipboard(),
            ),
          );
          final actual = [
            tabIndex(tester),
            find.text('Open').evaluate().length,
          ];
          const expected = [0, 1];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('documents', () {
        testWidgets('create document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(),
              library: stubDocumentLibrary(),
              clipboard: StubImageClipboard(),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            find.text('64 × 64').evaluate().length,
            canvasSize(tester),
          ];
          const expected = [1, 1, Size(256, 256)];
          expect(actual, equals(expected));
        });
      });
      group('drawing', () {
        testWidgets('stroke on new document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(),
              library: stubDocumentLibrary(),
              clipboard: StubImageClipboard(),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          final gesture = await tester.startGesture(
            topLeft + const Offset(1, 1),
          );
          await gesture.moveTo(topLeft + const Offset(9, 1));
          await gesture.up();
          await tester.pump();
          final documentLayer = canvasLayers(tester).first.images.first;
          final actual = [
            for (var x = 0; x < 4; x++)
              documentLayer.getPixel(PixelPoint(x: x, y: 0)),
          ];
          const expected = [
            PixelColor.black,
            PixelColor.black,
            PixelColor.black,
            PixelColor.transparent,
          ];
          expect(actual, equals(expected));
        });
      });
      group('clipboard', () {
        testWidgets('copy into new document', (tester) async {
          useDesktopView(tester);
          final stubClipboard = StubImageClipboard();
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(),
              library: stubDocumentLibrary(),
              clipboard: stubClipboard,
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.enterText(find.byKey(const Key('height')), '2');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Select all'));
          await tester.pump();
          await tester.tap(find.byTooltip('Copy'));
          await tester.pump();
          await tester.tap(find.text('New document'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('From clipboard'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            find.text('3 × 2').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
      });
      group('files', () {
        testWidgets('save and reopen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(),
              library: stubDocumentLibrary(),
              clipboard: StubImageClipboard(),
            ),
          );
          await tester.enterText(find.byKey(const Key('name')), 'Cat');
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.enterText(find.byKey(const Key('height')), '2');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyS);
          await tester.pump();
          await tester.tap(find.text('New document'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byType(StoredDocumentList),
              matching: find.text('Cat'),
            ),
          );
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            find.text('3 × 2').evaluate().length,
            find.text('Saved').evaluate().length,
            canvasLayers(
              tester,
            ).first.images.first.getPixel(const PixelPoint(x: 0, y: 0)),
          ];
          const expected = [1, 1, 1, PixelColor.black];
          expect(actual, equals(expected));
        });
      });

      group('animation', () {
        testWidgets('open gif, add frame, save and reopen', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(
                file: (
                  name: 'walk.gif',
                  bytes: GifCodec.encode(
                    document: animatedDocument(
                      spriteColors: [0xFF000000, 0xFFFF0000],
                      activeFrameIndex: 0,
                    ),
                  ),
                ),
              ),
              library: stubDocumentLibrary(),
              clipboard: StubImageClipboard(),
            ),
          );
          await tester.tap(find.text('From file'));
          await tester.pumpAndSettle();
          final opened = timelineState(tester);
          await tester.tap(find.byTooltip('Add frame'));
          await tester.pump();
          await pressControlShortcut(tester, key: LogicalKeyboardKey.keyS);
          await tester.pump();
          await tester.tap(find.text('New document'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byType(StoredDocumentList),
              matching: find.text('walk'),
            ),
          );
          await tester.pumpAndSettle();
          final reopened = timelineState(tester);
          final actual = [opened, reopened];
          const expected = [
            [0, 2, 100, false, 0],
            [0, 3, 100, false, 0],
          ];
          expect(actual, equals(expected));
        });
      });

      group('history', () {
        testWidgets('undo and redo after typed size', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(),
              library: stubDocumentLibrary(),
              clipboard: StubImageClipboard(),
            ),
          );
          await tester.enterText(find.byKey(const Key('width')), '4');
          await tester.enterText(find.byKey(const Key('height')), '4');
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final documentLayer = canvasLayers(tester).first.images.first;
          final drawn = documentLayer.getPixel(const PixelPoint(x: 0, y: 0));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final undone = documentLayer.getPixel(const PixelPoint(x: 0, y: 0));
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyY);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pump();
          final redone = documentLayer.getPixel(const PixelPoint(x: 0, y: 0));
          final actual = [drawn, undone, redone];
          const expected = [
            PixelColor.black,
            PixelColor.transparent,
            PixelColor.black,
          ];
          expect(actual, equals(expected));
        });
      });
      group('colors', () {
        testWidgets('edit color and draw', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            PaintApp(
              key: UniqueKey(),
              files: StubFileAccess(),
              library: stubDocumentLibrary(),
              clipboard: StubImageClipboard(),
            ),
          );
          await tester.tap(find.text('Create new'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Edit colors'));
          await tester.pumpAndSettle();
          await tester.enterText(channelField('Red:'), '255');
          await tester.pump();
          await tester.enterText(channelField('Alpha:'), '128');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final topLeft = tester.getTopLeft(find.byType(PixelCanvas));
          await tester.tapAt(topLeft + const Offset(1, 1));
          await tester.pump();
          final documentLayer = canvasLayers(tester).first.images.first;
          final actual = documentLayer.getPixel(const PixelPoint(x: 0, y: 0));
          const expected = PixelColor(argb: 0x80FF0000);
          expect(actual, equals(expected));
        });
      });
    });
  });
}
