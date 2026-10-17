import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/zoom.dart';

void main() {
  group('standalone', () {
    group('function zoomStep', () {
      group('magnitudes', () {
        test('below 4', () {
          final actual = [
            for (final magnitude in [1, 2, 3]) zoomStep(magnitude),
          ];
          const expected = [1, 1, 1];
          expect(actual, equals(expected));
        });
        test('doubling ranges', () {
          final actual = [
            for (final magnitude in [4, 7, 8, 15, 16, 31, 32, 64])
              zoomStep(magnitude),
          ];
          const expected = [2, 2, 4, 4, 8, 8, 16, 32];
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class Zoom', () {
    group('factory nearest', () {
      group('scales', () {
        test('whole', () {
          final actual = Zoom.nearest(scale: 3.4);
          const expected = Zoom(factor: 3);
          expect(actual, equals(expected));
        });
        test('fraction', () {
          final actual = Zoom.nearest(scale: 0.3);
          const expected = Zoom(factor: -3);
          expect(actual, equals(expected));
        });
        test('near one', () {
          final actual = Zoom.nearest(scale: 0.7);
          const expected = Zoom(factor: 1);
          expect(actual, equals(expected));
        });
      });
    });

    group('factory fitting', () {
      group('scales', () {
        test('whole', () {
          final actual = Zoom.fitting(scale: 3.7);
          const expected = Zoom(factor: 3);
          expect(actual, equals(expected));
        });
        test('fraction', () {
          final actual = Zoom.fitting(scale: 0.4);
          const expected = Zoom(factor: -3);
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
          final actual = Zoom.fitting(scale: 0.001);
          const expected = Zoom.minimum;
          expect(actual, equals(expected));
        });
      });
    });

    group('method tryParse', () {
      group('texts', () {
        test('whole', () {
          final actual = Zoom.tryParse('4');
          const expected = Zoom(factor: 4);
          expect(actual, equals(expected));
        });
        test('negative', () {
          final actual = Zoom.tryParse('-3');
          const expected = Zoom(factor: -3);
          expect(actual, equals(expected));
        });
        test('fraction', () {
          final actual = Zoom.tryParse('1/3');
          const expected = Zoom(factor: -3);
          expect(actual, equals(expected));
        });
        test('zero divisor', () {
          final actual = Zoom.tryParse('1/0');
          expect(actual, isNull);
        });
        test('incomplete fraction', () {
          final actual = Zoom.tryParse('1/');
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
      });
    });

    group('getter label', () {
      group('factors', () {
        test('magnified', () {
          final actual = const Zoom(factor: 4).label;
          const expected = '4';
          expect(actual, equals(expected));
        });
        test('reduced', () {
          final actual = const Zoom(factor: -4).label;
          const expected = '1/4';
          expect(actual, equals(expected));
        });
        test('unnormalized', () {
          final actual = const Zoom(factor: -1).label;
          const expected = '-1';
          expect(actual, equals(expected));
        });
      });
    });

    group('getter normalized', () {
      group('factors', () {
        test('zero', () {
          final actual = const Zoom(factor: 0).normalized;
          const expected = Zoom(factor: 1);
          expect(actual, equals(expected));
        });
        test('minus one', () {
          final actual = const Zoom(factor: -1).normalized;
          const expected = Zoom(factor: 1);
          expect(actual, equals(expected));
        });
        test('valid', () {
          final actual = [
            const Zoom(factor: 3).normalized,
            const Zoom(factor: -2).normalized,
          ];
          const expected = [Zoom(factor: 3), Zoom(factor: -2)];
          expect(actual, equals(expected));
        });
      });
    });

    group('getter scale', () {
      group('factors', () {
        test('positive', () {
          final actual = const Zoom(factor: 4).scale;
          const expected = 4.0;
          expect(actual, equals(expected));
        });
        test('negative', () {
          final actual = const Zoom(factor: -4).scale;
          const expected = 0.25;
          expect(actual, equals(expected));
        });
        test('zero', () {
          final actual = const Zoom(factor: 0).scale;
          const expected = 1.0;
          expect(actual, equals(expected));
        });
      });
    });

    group('method stepped', () {
      group('larger', () {
        test('magnified', () {
          final actual = [
            for (final factor in [1, 3, 4, 6, 8, 12, 16, 17])
              Zoom(factor: factor).stepped(larger: true).factor,
          ];
          const expected = [2, 4, 6, 8, 12, 16, 24, 24];
          expect(actual, equals(expected));
        });
        test('reduced', () {
          final actual = [
            for (final factor in [-2, -3, -4, -6, -8, -12, -17])
              Zoom(factor: factor).stepped(larger: true).factor,
          ];
          const expected = [1, -2, -3, -4, -6, -8, -16];
          expect(actual, equals(expected));
        });
        test('unnormalized', () {
          final actual = const Zoom(factor: 0).stepped(larger: true);
          const expected = Zoom(factor: 2);
          expect(actual, equals(expected));
        });
      });
      group('smaller', () {
        test('magnified', () {
          final actual = [
            for (final factor in [1, 2, 4, 5, 6, 8, 9, 16, 17])
              Zoom(factor: factor).stepped(larger: false).factor,
          ];
          const expected = [-2, 1, 3, 4, 4, 6, 8, 12, 16];
          expect(actual, equals(expected));
        });
        test('reduced', () {
          final actual = [
            for (final factor in [-2, -3, -4, -6, -8, -12])
              Zoom(factor: factor).stepped(larger: false).factor,
          ];
          const expected = [-3, -4, -6, -8, -12, -16];
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
            const Zoom(factor: 2) == const Zoom(factor: 2),
            const Zoom(factor: 2).hashCode == const Zoom(factor: 2).hashCode,
          ];
          const expected = [true, true];
          expect(actual, equals(expected));
        });
        test('different', () {
          final actual = const Zoom(factor: 2) == const Zoom(factor: 3);
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('factors', () {
        test('negative', () {
          final actual = const Zoom(factor: -2).toString();
          const expected = 'Zoom(-2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
