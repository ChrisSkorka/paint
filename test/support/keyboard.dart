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
