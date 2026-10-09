import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

void useDesktopView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
