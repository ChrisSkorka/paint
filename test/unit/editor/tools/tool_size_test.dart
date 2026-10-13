import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/tools/tool_size.dart';

void main() {
  group('standalone', () {
    group('function toolSizeStep', () {
      group('bands', () {
        test('below 50', () {
          final actual = toolSizeStep(49);
          const expected = 1;
          expect(actual, equals(expected));
        });
        test('from 50', () {
          final actual = toolSizeStep(50);
          const expected = 5;
          expect(actual, equals(expected));
        });
        test('below 100', () {
          final actual = toolSizeStep(99);
          const expected = 5;
          expect(actual, equals(expected));
        });
        test('from 100', () {
          final actual = toolSizeStep(100);
          const expected = 10;
          expect(actual, equals(expected));
        });
        test('below 500', () {
          final actual = toolSizeStep(499);
          const expected = 10;
          expect(actual, equals(expected));
        });
        test('from 500', () {
          final actual = toolSizeStep(500);
          const expected = 50;
          expect(actual, equals(expected));
        });
      });
    });

    group('function largerToolSize', () {
      group('bands', () {
        test('ones', () {
          final actual = largerToolSize(10);
          const expected = 11;
          expect(actual, equals(expected));
        });
        test('into fives', () {
          final actual = largerToolSize(49);
          const expected = 50;
          expect(actual, equals(expected));
        });
        test('fives', () {
          final actual = largerToolSize(50);
          const expected = 55;
          expect(actual, equals(expected));
        });
        test('off step', () {
          final actual = largerToolSize(53);
          const expected = 55;
          expect(actual, equals(expected));
        });
        test('into tens', () {
          final actual = largerToolSize(95);
          const expected = 100;
          expect(actual, equals(expected));
        });
        test('tens', () {
          final actual = largerToolSize(100);
          const expected = 110;
          expect(actual, equals(expected));
        });
        test('into fifties', () {
          final actual = largerToolSize(490);
          const expected = 500;
          expect(actual, equals(expected));
        });
        test('fifties', () {
          final actual = largerToolSize(500);
          const expected = 550;
          expect(actual, equals(expected));
        });
      });
      group('limits', () {
        test('maximum', () {
          final actual = largerToolSize(1000);
          const expected = 1000;
          expect(actual, equals(expected));
        });
      });
    });

    group('function smallerToolSize', () {
      group('bands', () {
        test('ones', () {
          final actual = smallerToolSize(10);
          const expected = 9;
          expect(actual, equals(expected));
        });
        test('out of fives', () {
          final actual = smallerToolSize(50);
          const expected = 49;
          expect(actual, equals(expected));
        });
        test('fives', () {
          final actual = smallerToolSize(55);
          const expected = 50;
          expect(actual, equals(expected));
        });
        test('off step', () {
          final actual = smallerToolSize(53);
          const expected = 50;
          expect(actual, equals(expected));
        });
        test('out of tens', () {
          final actual = smallerToolSize(100);
          const expected = 95;
          expect(actual, equals(expected));
        });
        test('tens', () {
          final actual = smallerToolSize(110);
          const expected = 100;
          expect(actual, equals(expected));
        });
        test('out of fifties', () {
          final actual = smallerToolSize(500);
          const expected = 490;
          expect(actual, equals(expected));
        });
        test('fifties', () {
          final actual = smallerToolSize(550);
          const expected = 500;
          expect(actual, equals(expected));
        });
      });
      group('limits', () {
        test('minimum', () {
          final actual = smallerToolSize(1);
          const expected = 1;
          expect(actual, equals(expected));
        });
      });
    });

    group('function roundToolSize', () {
      group('bands', () {
        test('ones', () {
          final actual = roundToolSize(7);
          const expected = 7;
          expect(actual, equals(expected));
        });
        test('fives down', () {
          final actual = roundToolSize(52);
          const expected = 50;
          expect(actual, equals(expected));
        });
        test('fives up', () {
          final actual = roundToolSize(53);
          const expected = 55;
          expect(actual, equals(expected));
        });
        test('fives into tens', () {
          final actual = roundToolSize(98);
          const expected = 100;
          expect(actual, equals(expected));
        });
        test('tens down', () {
          final actual = roundToolSize(104);
          const expected = 100;
          expect(actual, equals(expected));
        });
        test('tens up', () {
          final actual = roundToolSize(105);
          const expected = 110;
          expect(actual, equals(expected));
        });
        test('fifties down', () {
          final actual = roundToolSize(523);
          const expected = 500;
          expect(actual, equals(expected));
        });
        test('fifties up', () {
          final actual = roundToolSize(980);
          const expected = 1000;
          expect(actual, equals(expected));
        });
      });
      group('limits', () {
        test('maximum', () {
          final actual = roundToolSize(1000);
          const expected = 1000;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
