import 'package:flutter_test/flutter_test.dart';

Future<void> settleTextCommit(WidgetTester tester) async {
  for (var round = 0; round < 4; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}
