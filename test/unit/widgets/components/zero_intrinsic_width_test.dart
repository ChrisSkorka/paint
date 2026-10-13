import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/zero_intrinsic_width.dart';

void main() {
  group('class ZeroIntrinsicWidth', () {
    group('render', () {
      group('intrinsic width', () {
        testWidgets('minimum', (tester) async {
          await tester.pumpWidget(
            const Center(
              child: ZeroIntrinsicWidth(
                child: SizedBox(width: 300, height: 10),
              ),
            ),
          );
          final actual = tester
              .renderObject<RenderBox>(find.byType(ZeroIntrinsicWidth))
              .getMinIntrinsicWidth(10);
          const expected = 0.0;
          expect(actual, equals(expected));
        });
        testWidgets('maximum', (tester) async {
          await tester.pumpWidget(
            const Center(
              child: ZeroIntrinsicWidth(
                child: SizedBox(width: 300, height: 10),
              ),
            ),
          );
          final actual = tester
              .renderObject<RenderBox>(find.byType(ZeroIntrinsicWidth))
              .getMaxIntrinsicWidth(10);
          const expected = 0.0;
          expect(actual, equals(expected));
        });
      });
      group('layout', () {
        testWidgets('sibling sets width', (tester) async {
          await tester.pumpWidget(
            const Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 100, height: 10),
                      ZeroIntrinsicWidth(
                        child: SizedBox(width: 300, height: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          final actual = tester.getSize(find.byType(ZeroIntrinsicWidth));
          const expected = Size(100, 10);
          expect(actual, equals(expected));
        });
      });
    });
  });
}
