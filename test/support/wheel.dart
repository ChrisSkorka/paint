import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> scrollWheel(
  WidgetTester tester, {
  required Offset at,
  required Offset delta,
}) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.sendEventToBinding(pointer.scroll(delta));
  await tester.pump();
}

Future<void> scaleWheel(
  WidgetTester tester, {
  required Offset at,
  required double scale,
}) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.sendEventToBinding(pointer.scale(scale));
  await tester.pump();
}
