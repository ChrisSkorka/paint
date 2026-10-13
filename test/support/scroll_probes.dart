import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/horizontal_scroll_view.dart';
import 'package:paint/widgets/components/paint_scroll_behavior.dart';

Widget horizontalScrollApp({required double contentWidth}) => MaterialApp(
  home: Scaffold(
    body: ListView(
      children: [
        SizedBox(
          height: 100,
          child: HorizontalScrollView(
            padding: const EdgeInsets.all(4),
            child: SizedBox(width: contentWidth, height: 50),
          ),
        ),
        const SizedBox(height: 2000),
      ],
    ),
  ),
);

Widget scrollBehaviorApp({required Axis axis}) => MaterialApp(
  scrollBehavior: PaintScrollBehavior(),
  home: Scaffold(
    body: PrimaryScrollController.none(
      child: ListView(
        scrollDirection: axis,
        children: const [SizedBox(width: 5000, height: 5000)],
      ),
    ),
  ),
);

List<double> scrollOffsets(WidgetTester tester) => [
  for (final state in tester.stateList<ScrollableState>(
    find.byType(Scrollable),
  ))
    state.position.pixels,
];
