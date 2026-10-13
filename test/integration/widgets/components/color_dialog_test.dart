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
        testWidgets('picker', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          final actual = pickerColor(tester);
          final expected = HSVColor.fromColor(const Color(0x80112233));
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
      group('picker', () {
        testWidgets('area brightest saturated', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.drag(colorArea(), const Offset(1000, -1000));
          await tester.pump();
          final actual = [hexText(tester), previewColors(tester)];
          const expected = [
            '#0080FF80',
            [Color(0x80112233), Color(0x800080FF)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('area white', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.drag(colorArea(), const Offset(-1000, -1000));
          await tester.pump();
          final actual = [hexText(tester), previewColors(tester)];
          const expected = [
            '#FFFFFF80',
            [Color(0x80112233), Color(0x80FFFFFF)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('area black', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.drag(colorArea(), const Offset(-1000, 1000));
          await tester.pump();
          final actual = [hexText(tester), previewColors(tester)];
          const expected = [
            '#00000080',
            [Color(0x80112233), Color(0x80000000)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('hue', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.drag(colorSlider('Hue'), const Offset(-1000, 0));
          await tester.pump();
          final actual = [hexText(tester), previewColors(tester)];
          const expected = [
            '#33111180',
            [Color(0x80112233), Color(0x80331111)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alpha opaque', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.drag(colorSlider('Alpha'), const Offset(1000, 0));
          await tester.pump();
          final actual = [hexText(tester), previewColors(tester)];
          const expected = [
            '#112233FF',
            [Color(0x80112233), Color(0xFF112233)],
          ];
          expect(actual, equals(expected));
        });
        testWidgets('alpha transparent', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(
            const MaterialApp(
              home: ColorDialog(initialColor: PixelColor(argb: 0x80112233)),
            ),
          );
          await tester.drag(colorSlider('Alpha'), const Offset(-1000, 0));
          await tester.pump();
          final actual = [hexText(tester), previewColors(tester)];
          const expected = [
            '#11223300',
            [Color(0x80112233), Color(0x00112233)],
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
            pickerColor(tester),
            previewColors(tester),
          ];
          final expected = [
            '#AABBCC',
            HSVColor.fromColor(const Color(0xFFAABBCC)),
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
            pickerColor(tester),
            previewColors(tester),
          ];
          final expected = [
            '#AABBCC40',
            HSVColor.fromColor(const Color(0x40AABBCC)),
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
            pickerColor(tester),
            previewColors(tester),
          ];
          final expected = [
            'aabbcc',
            HSVColor.fromColor(const Color(0xFFAABBCC)),
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
            pickerColor(tester),
            previewColors(tester),
          ];
          final expected = [
            '#AABB',
            HSVColor.fromColor(const Color(0x80112233)),
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
            pickerColor(tester),
            previewColors(tester),
          ];
          final expected = [
            '#AABBCC',
            HSVColor.fromColor(const Color(0xFFAABBCC)),
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
            pickerColor(tester),
            previewColors(tester),
          ];
          final expected = [
            '#AABBCCFF',
            HSVColor.fromColor(const Color(0xFFAABBCC)),
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
            pickerColor(tester),
            previewColors(tester),
          ];
          final expected = [
            '#11223380',
            HSVColor.fromColor(const Color(0x80112233)),
            [Color(0x80112233), Color(0x80112233)],
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
          await tester.enterText(hexField(), '#1122FF80');
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
          await tester.enterText(hexField(), '#1122FF80');
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
