import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/editor_shortcut.dart';
import 'package:paint/widgets/components/shortcut_list.dart';

import '../../../support/view_probes.dart';

void main() {
  group('class ShortcutList', () {
    group('render', () {
      group('shortcuts', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(body: ShortcutList(shortcuts: [])),
            ),
          );
          final actual = texts(tester);
          const expected = <String>[];
          expect(actual, equals(expected));
        });
        testWidgets('one', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ShortcutList(shortcuts: [EditorShortcut.pen]),
              ),
            ),
          );
          final actual = texts(tester);
          const expected = ['Tools', 'P', 'Pen'];
          expect(actual, equals(expected));
        });
        testWidgets('same group', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ShortcutList(
                  shortcuts: [EditorShortcut.pen, EditorShortcut.eraser],
                ),
              ),
            ),
          );
          final actual = texts(tester);
          const expected = ['Tools', 'P', 'Pen', 'E', 'Eraser'];
          expect(actual, equals(expected));
        });
        testWidgets('multiple groups', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ShortcutList(
                  shortcuts: [
                    EditorShortcut.addLayer,
                    EditorShortcut.pen,
                    EditorShortcut.save,
                  ],
                ),
              ),
            ),
          );
          final actual = texts(tester);
          const expected = [
            'File',
            'Ctrl+S',
            'Save',
            'Tools',
            'P',
            'Pen',
            'Layers',
            'Shift+N',
            'Add layer',
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
