import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/views/paint_app.dart';

import '../../../support/desktop_view.dart';
import '../../../support/view_probes.dart';

void main() {
  group('class PaintApp', () {
    group('render', () {
      group('launch', () {
        testWidgets('new document tab', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(const PaintApp());
          final actual = [
            tabIndex(tester),
            find.text('Create new').evaluate().length,
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
          await tester.pumpWidget(const PaintApp());
          await tester.tap(find.byTooltip('Create'));
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
    });
  });
}
