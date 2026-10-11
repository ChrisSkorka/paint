import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/horizontal_scroll_view.dart';

import '../../../support/scroll_probes.dart';
import '../../../support/wheel.dart';

void main() {
  group('class HorizontalScrollView', () {
    group('render', () {
      group('scroll view', () {
        testWidgets('direction and padding', (tester) async {
          await tester.pumpWidget(horizontalScrollApp(contentWidth: 2000));
          final scrollView = tester.widget<SingleChildScrollView>(
            find.descendant(
              of: find.byType(HorizontalScrollView),
              matching: find.byType(SingleChildScrollView),
            ),
          );
          final actual = [scrollView.scrollDirection, scrollView.padding];
          const expected = [Axis.horizontal, EdgeInsets.all(4)];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('mouse wheel', () {
        testWidgets('vertical wheel', (tester) async {
          await tester.pumpWidget(horizontalScrollApp(contentWidth: 2000));
          await scrollWheel(
            tester,
            at: tester.getCenter(find.byType(HorizontalScrollView)),
            delta: const Offset(0, 50),
          );
          final actual = scrollOffsets(tester);
          const expected = [0.0, 50.0];
          expect(actual, equals(expected));
        });
        testWidgets('horizontal wheel', (tester) async {
          await tester.pumpWidget(horizontalScrollApp(contentWidth: 2000));
          await scrollWheel(
            tester,
            at: tester.getCenter(find.byType(HorizontalScrollView)),
            delta: const Offset(50, 0),
          );
          final actual = scrollOffsets(tester);
          const expected = [0.0, 50.0];
          expect(actual, equals(expected));
        });
        testWidgets('vertical wheel at start', (tester) async {
          await tester.pumpWidget(horizontalScrollApp(contentWidth: 2000));
          await scrollWheel(
            tester,
            at: tester.getCenter(find.byType(HorizontalScrollView)),
            delta: const Offset(0, -50),
          );
          final actual = scrollOffsets(tester);
          const expected = [0.0, 0.0];
          expect(actual, equals(expected));
        });
        testWidgets('content fits', (tester) async {
          await tester.pumpWidget(horizontalScrollApp(contentWidth: 100));
          await scrollWheel(
            tester,
            at: tester.getCenter(find.byType(HorizontalScrollView)),
            delta: const Offset(0, 50),
          );
          final actual = scrollOffsets(tester);
          const expected = [50.0, 0.0];
          expect(actual, equals(expected));
        });
        testWidgets('scale signal', (tester) async {
          await tester.pumpWidget(horizontalScrollApp(contentWidth: 2000));
          await scaleWheel(
            tester,
            at: tester.getCenter(find.byType(HorizontalScrollView)),
            scale: 2,
          );
          final actual = scrollOffsets(tester);
          const expected = [0.0, 0.0];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
