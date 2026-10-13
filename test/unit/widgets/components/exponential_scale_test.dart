import 'package:flutter_test/flutter_test.dart';
import 'package:paint/widgets/components/exponential_scale.dart';

void main() {
  group('standalone', () {
    group('function exponentialPosition', () {
      group('values', () {
        test('minimum', () {
          final actual = exponentialPosition(
            value: 1,
            minimum: 1,
            maximum: 100,
          );
          const expected = 0.0;
          expect(actual, equals(expected));
        });
        test('maximum', () {
          final actual = exponentialPosition(
            value: 100,
            minimum: 1,
            maximum: 100,
          );
          const expected = 1.0;
          expect(actual, equals(expected));
        });
        test('middle', () {
          final actual = exponentialPosition(
            value: 10,
            minimum: 1,
            maximum: 100,
          );
          const expected = 0.5;
          expect(actual, equals(expected));
        });
        test('offset minimum', () {
          final actual = exponentialPosition(
            value: 20,
            minimum: 2,
            maximum: 200,
          );
          const expected = 0.5;
          expect(actual, equals(expected));
        });
      });
    });

    group('function exponentialValue', () {
      group('positions', () {
        test('start', () {
          final actual = exponentialValue(
            position: 0,
            minimum: 1,
            maximum: 100,
          );
          const expected = 1;
          expect(actual, equals(expected));
        });
        test('end', () {
          final actual = exponentialValue(
            position: 1,
            minimum: 1,
            maximum: 100,
          );
          const expected = 100;
          expect(actual, equals(expected));
        });
        test('middle', () {
          final actual = exponentialValue(
            position: 0.5,
            minimum: 1,
            maximum: 100,
          );
          const expected = 10;
          expect(actual, equals(expected));
        });
        test('offset minimum', () {
          final actual = exponentialValue(
            position: 0.5,
            minimum: 2,
            maximum: 200,
          );
          const expected = 20;
          expect(actual, equals(expected));
        });
      });
      group('limits', () {
        test('before start', () {
          final actual = exponentialValue(
            position: -0.5,
            minimum: 1,
            maximum: 100,
          );
          const expected = 1;
          expect(actual, equals(expected));
        });
        test('after end', () {
          final actual = exponentialValue(
            position: 1.5,
            minimum: 1,
            maximum: 100,
          );
          const expected = 100;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
