import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/onion_skin.dart';

void main() {
  group('class OnionSkin', () {
    group('method copyWith', () {
      group('fields', () {
        test('none', () {
          const onionSkin = OnionSkin(
            enabled: true,
            previous: false,
            next: false,
            frameCount: 3,
            activeLayerOnly: true,
          );
          final actual = onionSkin.copyWith();
          const expected = OnionSkin(
            enabled: true,
            previous: false,
            next: false,
            frameCount: 3,
            activeLayerOnly: true,
          );
          expect(actual, equals(expected));
        });
        test('all', () {
          const onionSkin = OnionSkin();
          final actual = onionSkin.copyWith(
            enabled: true,
            previous: false,
            next: false,
            frameCount: 3,
            activeLayerOnly: true,
          );
          const expected = OnionSkin(
            enabled: true,
            previous: false,
            next: false,
            frameCount: 3,
            activeLayerOnly: true,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('defaults', () {
          const onionSkin = OnionSkin();
          final other = OnionSkin(
            enabled: false,
            previous: true,
            next: true,
            frameCount: 1,
            activeLayerOnly: false,
          );
          final actual = onionSkin == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different enabled', () {
          const onionSkin = OnionSkin();
          const other = OnionSkin(enabled: true);
          final actual = onionSkin == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different previous', () {
          const onionSkin = OnionSkin();
          const other = OnionSkin(previous: false);
          final actual = onionSkin == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different next', () {
          const onionSkin = OnionSkin();
          const other = OnionSkin(next: false);
          final actual = onionSkin == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different frame count', () {
          const onionSkin = OnionSkin();
          const other = OnionSkin(frameCount: 2);
          final actual = onionSkin == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different active layer only', () {
          const onionSkin = OnionSkin();
          const other = OnionSkin(activeLayerOnly: true);
          final actual = onionSkin == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different type', () {
          const onionSkin = OnionSkin();
          const Object other = 1;
          final actual = onionSkin == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('defaults', () {
          const onionSkin = OnionSkin();
          final other = OnionSkin(
            enabled: false,
            previous: true,
            next: true,
            frameCount: 1,
          );
          final actual = onionSkin.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different enabled', () {
          const onionSkin = OnionSkin();
          const other = OnionSkin(enabled: true);
          final actual = onionSkin.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('fields', () {
        test('defaults', () {
          const onionSkin = OnionSkin();
          final actual = onionSkin.toString();
          const expected =
              'OnionSkin(enabled: false, previous: true, next: true, frames: 1, active layer only: false)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
