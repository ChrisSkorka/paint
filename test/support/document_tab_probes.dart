import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/document_tab_bar.dart';

List<Object> documentTabState(WidgetTester tester) {
  final documentTabBar = tester.widget<DocumentTabBar>(
    find.byType(DocumentTabBar),
  );
  return [documentTabBar.tabs, documentTabBar.selectedIndex];
}

Decoration? documentTabDecoration(
  WidgetTester tester, {
  required String title,
}) => tester
    .widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byTooltip(title),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    )
    .decoration;

List<FontWeight?> documentTabWeights(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(
    find.descendant(
      of: find.byType(DocumentTabBar),
      matching: find.byType(Text),
    ),
  ))
    text.style!.fontWeight,
];

Future<void> closeDocumentTab(WidgetTester tester, {required int index}) async {
  await tester.tap(find.byTooltip('Close tab').at(index));
  await tester.pumpAndSettle();
}

Future<void> selectDocumentTab(
  WidgetTester tester, {
  required String title,
}) async {
  await tester.tap(
    find.descendant(
      of: find.byType(DocumentTabBar),
      matching: find.text(title),
    ),
  );
  await tester.pumpAndSettle();
}
