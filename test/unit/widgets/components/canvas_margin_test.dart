import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/canvas_margin.dart';

void main() {
  group('standalone', () {
    group('function canvasMargin', () {
      group('free space', () {
        test('smaller', () {
          final actual = canvasMargin(
            available: 100,
            extent: 40,
            edge: 12,
            scrollbar: 10,
          );
          const expected = (leading: 38.0, trailing: 48.0, reverse: true);
          expect(actual, equals(expected));
        });
        test('exact', () {
          final actual = canvasMargin(
            available: 100,
            extent: 66,
            edge: 12,
            scrollbar: 10,
          );
          const expected = (leading: 12.0, trailing: 22.0, reverse: false);
          expect(actual, equals(expected));
        });
        test('larger', () {
          final actual = canvasMargin(
            available: 100,
            extent: 400,
            edge: 12,
            scrollbar: 10,
          );
          const expected = (leading: 12.0, trailing: 22.0, reverse: false);
          expect(actual, equals(expected));
        });
      });
    });
  });
}
