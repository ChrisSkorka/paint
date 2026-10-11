import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/scroll_probes.dart';

void main() {
  group('class PaintScrollBehavior', () {
    group('render', () {
      group('scrollbars', () {
        testWidgets('vertical', (tester) async {
          await tester.pumpWidget(scrollBehaviorApp(axis: Axis.vertical));
          final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
          final actual = [
            scrollbar.thumbVisibility,
            scrollbar.interactive,
            scrollbar.thickness,
          ];
          const expected = [null, true, 12.0];
          expect(actual, equals(expected));
        });
        testWidgets('horizontal', (tester) async {
          await tester.pumpWidget(scrollBehaviorApp(axis: Axis.horizontal));
          final actual = tester.widgetList(find.byType(Scrollbar)).length;
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
