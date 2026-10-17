import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> rightClick(WidgetTester tester, Finder finder) async {
  await tester.tap(
    finder,
    buttons: kSecondaryMouseButton,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump();
}
