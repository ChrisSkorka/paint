import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/zoom.dart';

void main() {
  group('class Zoom', () {
    group('factory nearest', () {
      group('scales', () {
        test('whole', () {
          final actual = Zoom.nearest(scale: 3.4);
          const expected = Zoom(step: 2);
          expect(actual, equals(expected));
        });
        test('fraction', () {
          final actual = Zoom.nearest(scale: 0.3);
          const expected = Zoom(step: -2);
          expect(actual, equals(expected));
        });
        test('one', () {
          final actual = Zoom.nearest(scale: 1);
          const expected = Zoom(step: 0);
          expect(actual, equals(expected));
        });
      });
    });

    group('factory fitting', () {
      group('scales', () {
        test('whole', () {
          final actual = Zoom.fitting(scale: 3.7);
          const expected = Zoom(step: 2);
          expect(actual, equals(expected));
        });
        test('fraction', () {
          final actual = Zoom.fitting(scale: 0.4);
          const expected = Zoom(step: -2);
          expect(actual, equals(expected));
        });
        test('none', () {
          final actual = Zoom.fitting(scale: 0);
          const expected = Zoom.minimum;
          expect(actual, equals(expected));
        });
        test('huge', () {
          final actual = Zoom.fitting(scale: 500);
          const expected = Zoom.maximum;
          expect(actual, equals(expected));
        });
        test('tiny', () {
          final actual = Zoom.fitting(scale: 0.01);
          const expected = Zoom.minimum;
          expect(actual, equals(expected));
        });
      });
    });

    group('method tryParse', () {
      group('texts', () {
        test('whole', () {
          final actual = Zoom.tryParse('4');
          const expected = Zoom(step: 3);
          expect(actual, equals(expected));
        });
        test('fraction', () {
          final actual = Zoom.tryParse('1/3');
          const expected = Zoom(step: -2);
          expect(actual, equals(expected));
        });
        test('zero', () {
          final actual = Zoom.tryParse('0');
          expect(actual, isNull);
        });
        test('zero divisor', () {
          final actual = Zoom.tryParse('1/0');
          expect(actual, isNull);
        });
        test('other numerator', () {
          final actual = Zoom.tryParse('2/3');
          expect(actual, isNull);
        });
        test('empty', () {
          final actual = Zoom.tryParse('');
          expect(actual, isNull);
        });
        test('incomplete', () {
          final actual = Zoom.tryParse('1/');
          expect(actual, isNull);
        });
      });
    });

    group('getter scale', () {
      group('steps', () {
        test('positive', () {
          final actual = const Zoom(step: 3).scale;
          const expected = 4.0;
          expect(actual, equals(expected));
        });
        test('zero', () {
          final actual = const Zoom(step: 0).scale;
          const expected = 1.0;
          expect(actual, equals(expected));
        });
        test('negative', () {
          final actual = const Zoom(step: -3).scale;
          const expected = 0.25;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter label', () {
      group('steps', () {
        test('positive', () {
          final actual = const Zoom(step: 3).label;
          const expected = '4';
          expect(actual, equals(expected));
        });
        test('negative', () {
          final actual = const Zoom(step: -3).label;
          const expected = '1/4';
          expect(actual, equals(expected));
        });
      });
    });

    group('method stepped', () {
      group('directions', () {
        test('larger', () {
          final actual = const Zoom(step: 0).stepped(larger: true);
          const expected = Zoom(step: 1);
          expect(actual, equals(expected));
        });
        test('smaller', () {
          final actual = const Zoom(step: 0).stepped(larger: false);
          const expected = Zoom(step: -1);
          expect(actual, equals(expected));
        });
      });
      group('limits', () {
        test('maximum', () {
          final actual = Zoom.maximum.stepped(larger: true);
          const expected = Zoom.maximum;
          expect(actual, equals(expected));
        });
        test('minimum', () {
          final actual = Zoom.minimum.stepped(larger: false);
          const expected = Zoom.minimum;
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('values', () {
        test('same', () {
          final actual = [
            const Zoom(step: 2) == const Zoom(step: 2),
            const Zoom(step: 2).hashCode == const Zoom(step: 2).hashCode,
          ];
          const expected = [true, true];
          expect(actual, equals(expected));
        });
        test('different', () {
          final actual = const Zoom(step: 2) == const Zoom(step: 3);
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('steps', () {
        test('negative', () {
          final actual = const Zoom(step: -1).toString();
          const expected = 'Zoom(1/2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
