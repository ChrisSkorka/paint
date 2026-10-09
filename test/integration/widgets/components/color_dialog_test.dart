import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/widgets/components/color_dialog.dart';

import '../../../support/color_dialog_probes.dart';
import '../../../support/desktop_view.dart';

void main() {
  group('class ColorDialog', () {
    group('render', () {
      group('initial color', () {
        testWidgets('channels', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          final actual = channelValues(tester);
          const expected = [0x11, 0x22, 0x33, 0x80];
          expect(actual, equals(expected));
        });
        testWidgets('previews', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          final actual = previewColors(tester);
          const expected = [Color(0x80112233), Color(0x80112233)];
          expect(actual, equals(expected));
        });
        testWidgets('hex', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          final actual = hexText(tester);
          const expected = '#11223380';
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('channels', () {
        testWidgets('red', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(channelField('Red:'), '255');
          await tester.pump();
          final actual = [channelValues(tester), previewColors(tester)];
          const expected = [
            [0xFF, 0x22, 0x33, 0x80],
            [Color(0x80112233), Color(0x80FF2233)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('green', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(channelField('Green:'), '255');
          await tester.pump();
          final actual = [channelValues(tester), previewColors(tester)];
          const expected = [
            [0x11, 0xFF, 0x33, 0x80],
            [Color(0x80112233), Color(0x8011FF33)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('blue', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(channelField('Blue:'), '255');
          await tester.pump();
          final actual = [channelValues(tester), previewColors(tester)];
          const expected = [
            [0x11, 0x22, 0xFF, 0x80],
            [Color(0x80112233), Color(0x801122FF)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alpha', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(channelField('Alpha:'), '0');
          await tester.pump();
          final actual = [channelValues(tester), previewColors(tester)];
          const expected = [
            [0x11, 0x22, 0x33, 0x00],
            [Color(0x80112233), Color(0x00112233)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('several', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(channelField('Red:'), '0');
          await tester.pump();
          await tester.enterText(channelField('Alpha:'), '255');
          await tester.pump();
          final actual = [channelValues(tester), previewColors(tester)];
          const expected = [
            [0x00, 0x22, 0x33, 0xFF],
            [Color(0x80112233), Color(0xFF002233)],
          ];
          expect(actual, equals(expected));
        });
      });
      group('hex', () {
        testWidgets('six digits', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(hexField(), '#AABBCC');
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            '#AABBCC',
            [0xAA, 0xBB, 0xCC, 0xFF],
            [Color(0x80112233), Color(0xFFAABBCC)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('eight digits', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(hexField(), '#AABBCC40');
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            '#AABBCC40',
            [0xAA, 0xBB, 0xCC, 0x40],
            [Color(0x80112233), Color(0x40AABBCC)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('without hash', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(hexField(), 'aabbcc');
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            'aabbcc',
            [0xAA, 0xBB, 0xCC, 0xFF],
            [Color(0x80112233), Color(0xFFAABBCC)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('incomplete', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(hexField(), '#AABB');
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            '#AABB',
            [0x11, 0x22, 0x33, 0x80],
            [Color(0x80112233), Color(0x80112233)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('filtered characters', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(hexField(), '#AAXBBCC');
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            '#AABBCC',
            [0xAA, 0xBB, 0xCC, 0xFF],
            [Color(0x80112233), Color(0xFFAABBCC)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('submit valid', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(hexField(), 'aabbcc');
          await tester.pump();
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            '#AABBCCFF',
            [0xAA, 0xBB, 0xCC, 0xFF],
            [Color(0x80112233), Color(0xFFAABBCC)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('submit incomplete', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(hexField(), '#AABB');
          await tester.pump();
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            '#11223380',
            [0x11, 0x22, 0x33, 0x80],
            [Color(0x80112233), Color(0x80112233)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('channel change', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.enterText(channelField('Red:'), '255');
          await tester.pump();
          final actual = [
            hexText(tester),
            channelValues(tester),
            previewColors(tester),
          ];
          const expected = [
            '#FF223380',
            [0xFF, 0x22, 0x33, 0x80],
            [Color(0x80112233), Color(0x80FF2233)],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('standalone', () {
    group('function showColorDialog', () {
      group('results', () {
        testWidgets('ok unchanged', (tester) async {
          useDesktopView(tester);
          final results = <PixelColor?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showColorDialog(
                      context: context,
                      initialColor: const PixelColor(argb: 0x80112233),
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
          const expected = [PixelColor(argb: 0x80112233)];
          expect(actual, equals(expected));
        });
        testWidgets('ok edited', (tester) async {
          useDesktopView(tester);
          final results = <PixelColor?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showColorDialog(
                      context: context,
                      initialColor: const PixelColor(argb: 0x80112233),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.enterText(channelField('Blue:'), '255');
          await tester.pump();
          await tester.tap(find.byTooltip('OK'));
          await tester.pumpAndSettle();
          final actual = results;
          const expected = [PixelColor(argb: 0x801122FF)];
          expect(actual, equals(expected));
        });
        testWidgets('cancel', (tester) async {
          useDesktopView(tester);
          final results = <PixelColor?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showColorDialog(
                      context: context,
                      initialColor: const PixelColor(argb: 0x80112233),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.enterText(channelField('Blue:'), '255');
          await tester.pump();
          await tester.tap(find.byTooltip('Cancel'));
          await tester.pumpAndSettle();
          final actual = results;
          const expected = [null];
          expect(actual, equals(expected));
        });
        testWidgets('dismiss', (tester) async {
          useDesktopView(tester);
          final results = <PixelColor?>[];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () async => results.add(
                    await showColorDialog(
                      context: context,
                      initialColor: const PixelColor(argb: 0x80112233),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.tapAt(const Offset(5, 5));
          await tester.pumpAndSettle();
          final actual = results;
          const expected = [null];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
