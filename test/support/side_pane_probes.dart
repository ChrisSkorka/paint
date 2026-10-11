import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/side_pane.dart';
import 'package:paint/widgets/components/side_panel.dart';

Widget sidePaneApp() => const MaterialApp(
  home: Row(
    children: [
      Expanded(child: SizedBox()),
      SidePane(
        panels: [
          (title: 'Layers', child: Text('layers')),
          (title: 'Frames', child: Text('frames')),
          (title: 'History', child: Text('history')),
        ],
      ),
    ],
  ),
);

List<double> panelHeights(WidgetTester tester) => [
  for (final element in find.byType(SidePanel).evaluate())
    tester.getSize(find.byElementPredicate((other) => other == element)).height,
];

double sidePaneWidth(WidgetTester tester) =>
    tester.getSize(find.byType(SidePane)).width;

Future<void> dragHandle(WidgetTester tester, {required double dx}) async {
  await tester.drag(
    find.byKey(const Key('side pane handle')),
    Offset(dx, 0),
    touchSlopX: 0,
  );
  await tester.pump();
}
