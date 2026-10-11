import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/stable_text.dart';

void main() {
  group('class StableText', () {
    group('render', () {
      group('alternatives', () {
        testWidgets('none', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Row(
                  children: [StableText(text: 'ab', alternatives: [])],
                ),
              ),
            ),
          );
          final actual = [
            find.text('ab').evaluate().length,
            tester.getSize(find.byType(StableText)).width,
          ];
          const expected = [1, 29.0];
          expect(actual, equals(expected));
        });
        testWidgets('one wider', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Row(
                  children: [
                    StableText(text: 'ab', alternatives: ['abcd']),
                  ],
                ),
              ),
            ),
          );
          final actual = [
            find.text('ab').evaluate().length,
            find.text('abcd').evaluate().length,
            tester.getSize(find.byType(StableText)).width,
          ];
          const expected = [1, 0, 57.0];
          expect(actual, equals(expected));
        });
        testWidgets('multiple', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Row(
                  children: [
                    StableText(text: 'ab', alternatives: ['a', 'abc', 'ab']),
                  ],
                ),
              ),
            ),
          );
          final actual = tester.getSize(find.byType(StableText)).width;
          const expected = 43.0;
          expect(actual, equals(expected));
        });
        testWidgets('text widest', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Row(
                  children: [
                    StableText(text: 'abcde', alternatives: ['a']),
                  ],
                ),
              ),
            ),
          );
          final actual = tester.getSize(find.byType(StableText)).width;
          const expected = 72.0;
          expect(actual, equals(expected));
        });
      });
      group('text scale', () {
        testWidgets('doubled', (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                  body: Row(
                    children: [
                      StableText(text: 'a', alternatives: ['abc']),
                    ],
                  ),
                ),
              ),
            ),
          );
          final actual = tester.getSize(find.byType(StableText)).width;
          const expected = 85.0;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
