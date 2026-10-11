import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pressControlShortcut(
  WidgetTester tester, {
  required LogicalKeyboardKey key,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump();
}

Future<void> pressShortcut(
  WidgetTester tester, {
  required LogicalKeyboardKey key,
  List<LogicalKeyboardKey> modifiers = const [],
}) async {
  for (final modifier in modifiers) {
    await tester.sendKeyDownEvent(modifier);
  }
  await tester.sendKeyEvent(key);
  for (final modifier in modifiers.reversed) {
    await tester.sendKeyUpEvent(modifier);
  }
  await tester.pump();
}
