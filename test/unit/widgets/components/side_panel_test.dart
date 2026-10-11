import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paint/widgets/components/paint_style.dart';
import 'package:paint/widgets/components/side_panel.dart';

void main() {
  group('class SidePanel', () {
    group('render', () {
      group('content', () {
        testWidgets('title and child', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          final actual = [
            find.text('title').evaluate().length,
            find.text('child').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
      });
      group('appearance', () {
        testWidgets('background', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          final actual = tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(SidePanel),
                  matching: find.byType(Container),
                ),
              )
              .decoration;
          const expected = BoxDecoration(color: PaintStyle.barBackground);
          expect(actual, equals(expected));
        });
        testWidgets('border', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(
                title: 'title',
                border: Border(
                  bottom: BorderSide(color: PaintStyle.separatorColor),
                ),
                child: Text('child'),
              ),
            ),
          );
          final actual = tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(SidePanel),
                  matching: find.byType(Container),
                ),
              )
              .decoration;
          const expected = BoxDecoration(
            color: PaintStyle.barBackground,
            border: Border(
              bottom: BorderSide(color: PaintStyle.separatorColor),
            ),
          );
          expect(actual, equals(expected));
        });
        testWidgets('title style', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          final actual = tester.widget<Text>(find.text('title')).style;
          const expected = PaintStyle.titleStyle;
          expect(actual, equals(expected));
        });
      });
      group('collapsed', () {
        testWidgets('expanded', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          final actual = [
            find.text('child').evaluate().length,
            tester.widget<FaIcon>(find.byType(FaIcon)).icon!.codePoint,
          ];
          final expected = [1, FontAwesomeIcons.angleDown.codePoint];
          expect(actual, equals(expected));
        });
        testWidgets('collapsed', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Column(
                children: [
                  SidePanel(
                    title: 'title',
                    collapsed: true,
                    child: Text('child'),
                  ),
                ],
              ),
            ),
          );
          final actual = [
            find.text('child').evaluate().length,
            tester.widget<FaIcon>(find.byType(FaIcon)).icon!.codePoint,
            tester.getSize(find.byType(SidePanel)).height < 40,
          ];
          final expected = [0, FontAwesomeIcons.angleRight.codePoint, true];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('toggle', () {
        testWidgets('tap title', (tester) async {
          var toggled = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: SidePanel(
                title: 'title',
                onToggle: () => toggled++,
                child: const Text('child'),
              ),
            ),
          );
          await tester.tap(find.text('title'));
          final actual = toggled;
          const expected = 1;
          expect(actual, equals(expected));
        });
        testWidgets('no callback', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: SidePanel(title: 'title', child: Text('child')),
            ),
          );
          await tester.tap(find.text('title'));
          final actual = find.text('child').evaluate().length;
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
