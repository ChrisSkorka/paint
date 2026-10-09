import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/widgets/views/editor_view.dart';
import 'package:paint/widgets/views/home_view.dart';

import '../../../support/desktop_view.dart';
import '../../../support/view_probes.dart';

void main() {
  group('class HomeView', () {
    group('render', () {
      group('initial tab', () {
        testWidgets('new document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(const MaterialApp(home: HomeView()));
          final actual = tabIndex(tester);
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('tabs', () {
        testWidgets('no document placeholder', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(const MaterialApp(home: HomeView()));
          await tester.tap(find.text('Editor'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            find.text('No document open').evaluate().length,
          ];
          const expected = [1, 1];
          expect(actual, equals(expected));
        });
        testWidgets('back to new document', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(const MaterialApp(home: HomeView()));
          await tester.tap(find.byTooltip('Create'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('New document'));
          await tester.pumpAndSettle();
          final actual = tabIndex(tester);
          const expected = 0;
          expect(actual, equals(expected));
        });
      });
      group('documents', () {
        testWidgets('create', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(const MaterialApp(home: HomeView()));
          await tester.tap(find.byTooltip('Create'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            tester.widget<EditorView>(find.byType(EditorView)).document,
          ];
          final expected = [1, Document.blank(width: 64, height: 64)];
          expect(actual, equals(expected));
        });
        testWidgets('second create', (tester) async {
          useDesktopView(tester);
          await tester.pumpWidget(const MaterialApp(home: HomeView()));
          await tester.tap(find.byTooltip('Create'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('New document'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('width')), '3');
          await tester.pump();
          await tester.tap(find.byTooltip('Create'));
          await tester.pumpAndSettle();
          final actual = [
            tabIndex(tester),
            tester.widget<EditorView>(find.byType(EditorView)).document,
          ];
          final expected = [1, Document.blank(width: 3, height: 64)];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
