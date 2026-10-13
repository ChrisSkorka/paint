import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/tools/text_orientation.dart';
import 'package:paint/widgets/components/text_draft.dart';

void main() {
  group('class TextDraft', () {
    group('render', () {
      group('style', () {
        testWidgets('text style', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      style: const TextStyle(
                        color: Color(0xffff0000),
                        fontSize: 20,
                      ),
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          final textField = tester.widget<TextField>(find.byType(TextField));
          final actual = [
            textField.style,
            textField.cursorColor,
            textField.maxLines,
          ];
          const expected = [
            TextStyle(color: Color(0xffff0000), fontSize: 20),
            Color(0xffff0000),
            null,
          ];
          expect(actual, equals(expected));
        });
        testWidgets('extent', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      style: const TextStyle(fontSize: 10),
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          final actual = tester.getSize(find.byType(TextDraft));
          const expected = Size(17, 24);
          expect(actual, equals(expected));
        });
        testWidgets('extent after typing', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      style: const TextStyle(fontSize: 10),
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), 'abc');
          await tester.pump();
          final actual = tester.getSize(find.byType(TextDraft));
          const expected = Size(47, 24);
          expect(actual, equals(expected));
        });
        testWidgets('outline', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      style: const TextStyle(fontSize: 10),
                      outlineStyle: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff0000ff),
                      ),
                      cursorColor: const Color(0xffff0000),
                      padding: 3,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), 'ab');
          await tester.pump();
          final outline = find.descendant(
            of: find.byType(TextDraft),
            matching: find.byType(Text),
          );
          final actual = [
            tester.widget<Text>(outline.first).data,
            tester.widget<Text>(outline.first).style,
            tester.getTopLeft(outline.first) -
                tester.getTopLeft(find.byType(TextDraft)),
            tester.getTopLeft(find.byType(TextField)) -
                tester.getTopLeft(find.byType(TextDraft)),
          ];
          const expected = [
            'ab',
            TextStyle(fontSize: 10, color: Color(0xff0000ff)),
            Offset(9, 9),
            Offset(9, 9),
          ];
          expect(actual, equals(expected));
        });
        testWidgets('mirrored text start', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(mirrored: true),
                      extentOf: stubExtentOf,
                      style: const TextStyle(fontSize: 10),
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), 'abc');
          await tester.pump();
          final actual =
              tester.getTopLeft(find.byType(TextField)) -
              tester.getTopLeft(find.byType(TextDraft));
          const expected = Offset(41, 6);
          expect(actual, equals(expected));
        });
      });
      group('orientation', () {
        testWidgets('upright', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      style: const TextStyle(fontSize: 10),
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          final actual = [
            tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
            tester
                    .widget<Transform>(
                      find
                          .descendant(
                            of: find.byType(RotatedBox),
                            matching: find.byType(Transform),
                          )
                          .first,
                    )
                    .transform ==
                Matrix4.diagonal3Values(-1, 1, 1),
          ];
          const expected = [0, false];
          expect(actual, equals(expected));
        });
        testWidgets('rotated', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      style: const TextStyle(fontSize: 10),
                      orientation: const TextOrientation(quarterTurns: 3),
                      extentOf: stubExtentOf,
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          final actual = [
            tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
            tester
                    .widget<Transform>(
                      find
                          .descendant(
                            of: find.byType(RotatedBox),
                            matching: find.byType(Transform),
                          )
                          .first,
                    )
                    .transform ==
                Matrix4.diagonal3Values(-1, 1, 1),
          ];
          const expected = [3, false];
          expect(actual, equals(expected));
        });
        testWidgets('mirrored', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      style: const TextStyle(fontSize: 10),
                      orientation: const TextOrientation(mirrored: true),
                      extentOf: stubExtentOf,
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          final actual = [
            tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
            tester
                    .widget<Transform>(
                      find
                          .descendant(
                            of: find.byType(RotatedBox),
                            matching: find.byType(Transform),
                          )
                          .first,
                    )
                    .transform ==
                Matrix4.diagonal3Values(-1, 1, 1),
          ];
          const expected = [0, true];
          expect(actual, equals(expected));
        });
      });
    });

    group('interactions', () {
      group('typing', () {
        testWidgets('text', (tester) async {
          final changes = <String>[];
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      style: const TextStyle(fontSize: 10),
                      onChanged: changes.add,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.enterText(find.byType(TextField), 'hi');
          final actual = changes;
          const expected = ['hi'];
          expect(actual, equals(expected));
        });
      });

      group('dragging', () {
        testWidgets('frame', (tester) async {
          void stubOnChanged(String text) {}
          final moves = <Offset>[];
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      style: const TextStyle(fontSize: 10),
                      onChanged: stubOnChanged,
                      onMoved: moves.add,
                    ),
                  ],
                ),
              ),
            ),
          );
          final gesture = await tester.startGesture(
            tester.getTopLeft(find.byType(TextDraft)) + const Offset(2, 2),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.moveBy(const Offset(5, 3));
          await gesture.up();
          final actual = moves.last;
          const expected = Offset(5, 3);
          expect(actual, equals(expected));
        });
        testWidgets('text', (tester) async {
          void stubOnChanged(String text) {}
          final moves = <Offset>[];
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      style: const TextStyle(fontSize: 10),
                      onChanged: stubOnChanged,
                      onMoved: moves.add,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.dragFrom(
            tester.getCenter(find.byType(TextField)),
            const Offset(30, 0),
            kind: PointerDeviceKind.mouse,
          );
          final actual = moves;
          const expected = <Offset>[];
          expect(actual, equals(expected));
        });
      });
    });

    group('lifecycle', () {
      group('focus', () {
        testWidgets('mounted', (tester) async {
          void stubOnChanged(String text) {}
          void stubOnMoved(Offset delta) {}
          Size stubExtentOf(String text) => Size(text.length * 10 + 5, 12);
          final otherFocus = FocusNode();
          addTearDown(otherFocus.dispose);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Focus(focusNode: otherFocus, child: const SizedBox()),
              ),
            ),
          );
          otherFocus.requestFocus();
          await tester.pump();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    Focus(focusNode: otherFocus, child: const SizedBox()),
                    TextDraft(
                      outlineStyle: null,
                      cursorColor: const Color(0xffff0000),
                      padding: 0,
                      orientation: const TextOrientation(),
                      extentOf: stubExtentOf,
                      style: const TextStyle(fontSize: 10),
                      onChanged: stubOnChanged,
                      onMoved: stubOnMoved,
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();
          final actual =
              FocusManager.instance.primaryFocus?.context
                  ?.findAncestorWidgetOfExactType<TextField>() !=
              null;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
