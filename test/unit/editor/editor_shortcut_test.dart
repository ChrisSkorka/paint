import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/editor_shortcut.dart';

void main() {
  group('class EditorShortcut', () {
    group('getter keys', () {
      group('activators', () {
        test('single key', () {
          final actual = EditorShortcut.pen.keys;
          const expected = 'P';
          expect(actual, equals(expected));
        });
        test('multiple activators', () {
          final actual = EditorShortcut.redo.keys;
          const expected = 'Ctrl+Y / Ctrl+Shift+Z';
          expect(actual, equals(expected));
        });
        test('held key', () {
          final actual = EditorShortcut.holdColorPicker.keys;
          const expected = 'Alt';
          expect(actual, equals(expected));
        });
        test('keys label', () {
          final actual = EditorShortcut.toolPreset.keys;
          const expected = '1–9';
          expect(actual, equals(expected));
        });
        test('all shortcuts', () {
          final actual = [
            for (final shortcut in EditorShortcut.values) shortcut.keys,
          ];
          const expected = [
            'Ctrl+S',
            'Ctrl+Shift+E',
            'Ctrl+Z',
            'Ctrl+Y / Ctrl+Shift+Z',
            'Ctrl+C',
            'Ctrl+X',
            'Ctrl+V',
            'Ctrl+A',
            'Del / Backspace',
            'Esc',
            'P',
            'E',
            'G',
            'I',
            'Alt',
            'M',
            'L',
            'R',
            'O',
            'A',
            '1–9',
            '[',
            ']',
            'X',
            'Ctrl+=',
            'Ctrl+-',
            'Ctrl+0',
            ',',
            '.',
            'Home',
            'End',
            'Enter',
            'F3',
            'Alt+N',
            'Alt+D',
            'Alt+Del',
            'Alt+,',
            'Alt+.',
            'Alt+-',
            'Alt+=',
            'Shift+N',
            'Shift+D',
            'Shift+Del',
            'PgUp',
            'PgDn',
            'Alt+PgUp',
            'Alt+PgDn',
          ];
          expect(actual, equals(expected));
        });
        test('distinct keys', () {
          final keys = [
            for (final shortcut in EditorShortcut.values)
              for (final activator in shortcut.activators)
                EditorShortcut.describe(activator),
          ];
          final actual = keys.toSet().length;
          final expected = keys.length;
          expect(actual, equals(expected));
        });
      });
    });

    group('method tooltip', () {
      group('text', () {
        test('label', () {
          final actual = EditorShortcut.addFrame.tooltip('Add frame');
          const expected = 'Add frame (Alt+N)';
          expect(actual, equals(expected));
        });
      });
    });

    group('method describe', () {
      group('modifiers', () {
        test('none', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.keyQ),
          );
          const expected = 'Q';
          expect(actual, equals(expected));
        });
        test('control', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
          );
          const expected = 'Ctrl+Q';
          expect(actual, equals(expected));
        });
        test('shift', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.keyQ, shift: true),
          );
          const expected = 'Shift+Q';
          expect(actual, equals(expected));
        });
        test('alt', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.keyQ, alt: true),
          );
          const expected = 'Alt+Q';
          expect(actual, equals(expected));
        });
        test('all', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(
              LogicalKeyboardKey.keyQ,
              control: true,
              shift: true,
              alt: true,
            ),
          );
          const expected = 'Ctrl+Shift+Alt+Q';
          expect(actual, equals(expected));
        });
      });
      group('key names', () {
        test('delete', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.delete),
          );
          const expected = 'Del';
          expect(actual, equals(expected));
        });
        test('escape', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.escape),
          );
          const expected = 'Esc';
          expect(actual, equals(expected));
        });
        test('page up', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.pageUp),
          );
          const expected = 'PgUp';
          expect(actual, equals(expected));
        });
        test('page down', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.pageDown),
          );
          const expected = 'PgDn';
          expect(actual, equals(expected));
        });
        test('symbol', () {
          final actual = EditorShortcut.describe(
            const SingleActivator(LogicalKeyboardKey.bracketLeft),
          );
          const expected = '[';
          expect(actual, equals(expected));
        });
      });
    });

    group('method activatorIndex', () {
      group('activators', () {
        testWidgets('first', (tester) async {
          int? actual;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  actual = EditorShortcut.toolPreset.activatorIndex(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
          const expected = 0;
          expect(actual, equals(expected));
        });
        testWidgets('last', (tester) async {
          int? actual;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  actual = EditorShortcut.toolPreset.activatorIndex(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
          const expected = 8;
          expect(actual, equals(expected));
        });
        testWidgets('none', (tester) async {
          int? actual;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  actual = EditorShortcut.toolPreset.activatorIndex(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
          const expected = -1;
          expect(actual, equals(expected));
        });
      });
    });

    group('method matching', () {
      group('match', () {
        testWidgets('plain key', (tester) async {
          EditorShortcut? actual;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  actual = EditorShortcut.matching(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
          const expected = EditorShortcut.pen;
          expect(actual, equals(expected));
        });
        testWidgets('modifier', (tester) async {
          EditorShortcut? actual;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.keyN) {
                  actual = EditorShortcut.matching(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          const expected = EditorShortcut.addLayer;
          expect(actual, equals(expected));
        });
        testWidgets('second activator', (tester) async {
          EditorShortcut? actual;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  actual = EditorShortcut.matching(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          const expected = EditorShortcut.deleteSelection;
          expect(actual, equals(expected));
        });
        testWidgets('digit', (tester) async {
          EditorShortcut? actual;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  actual = EditorShortcut.matching(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
          const expected = EditorShortcut.toolPreset;
          expect(actual, equals(expected));
        });
      });
      group('no match', () {
        testWidgets('unused key', (tester) async {
          EditorShortcut? actual = EditorShortcut.pen;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  actual = EditorShortcut.matching(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.keyQ);
          const expected = null;
          expect(actual, equals(expected));
        });
        testWidgets('wrong modifier', (tester) async {
          EditorShortcut? actual = EditorShortcut.pen;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.keyP) {
                  actual = EditorShortcut.matching(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          const expected = null;
          expect(actual, equals(expected));
        });
        testWidgets('repeat', (tester) async {
          EditorShortcut? actual = EditorShortcut.pen;
          await tester.pumpWidget(
            Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyRepeatEvent) {
                  actual = EditorShortcut.matching(event);
                }
                return KeyEventResult.handled;
              },
              child: const SizedBox(),
            ),
          );
          await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
          await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
