import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/tools/tool_kind.dart';
import 'package:paint/editor/tools/tool_preset.dart';
import 'package:paint/editor/tools/tool_presets.dart';

void main() {
  ToolPreset eraser(int size) => ToolPreset(kind: ToolKind.eraser, size: size);

  group('class ToolPresets', () {
    group('factory limited', () {
      group('locked', () {
        test('none', () {
          final actual = ToolPresets.limited(
            locked: const [],
            recent: [eraser(1)],
          );
          final expected = ToolPresets(recent: [eraser(1)]);
          expect(actual, equals(expected));
        });
        test('duplicates', () {
          final actual = ToolPresets.limited(
            locked: [eraser(1), eraser(1)],
            recent: const [],
          );
          final expected = ToolPresets(locked: [eraser(1)]);
          expect(actual, equals(expected));
        });
        test('over limit', () {
          final actual = ToolPresets.limited(
            locked: [for (var size = 1; size <= 10; size++) eraser(size)],
            recent: [eraser(11)],
          );
          final expected = ToolPresets(
            locked: [for (var size = 1; size <= 9; size++) eraser(size)],
          );
          expect(actual, equals(expected));
        });
      });
      group('recent', () {
        test('duplicates', () {
          final actual = ToolPresets.limited(
            locked: const [],
            recent: [eraser(1), eraser(2), eraser(1)],
          );
          final expected = ToolPresets(recent: [eraser(1), eraser(2)]);
          expect(actual, equals(expected));
        });
        test('locked preset', () {
          final actual = ToolPresets.limited(
            locked: [eraser(1)],
            recent: [eraser(2), eraser(1)],
          );
          final expected = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2)],
          );
          expect(actual, equals(expected));
        });
        test('over limit', () {
          final actual = ToolPresets.limited(
            locked: [eraser(1), eraser(2)],
            recent: [for (var size = 3; size <= 12; size++) eraser(size)],
          );
          final expected = ToolPresets(
            locked: [eraser(1), eraser(2)],
            recent: [for (var size = 3; size <= 9; size++) eraser(size)],
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('getter all', () {
      group('order', () {
        test('empty', () {
          final actual = const ToolPresets().all;
          const expected = <ToolPreset>[];
          expect(actual, equals(expected));
        });
        test('locked then recent', () {
          final actual = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2)],
          ).all;
          final expected = [eraser(1), eraser(2)];
          expect(actual, equals(expected));
        });
      });
    });

    group('method isLocked', () {
      group('index', () {
        final toolPresets = ToolPresets(
          locked: [eraser(1)],
          recent: [eraser(2)],
        );
        test('locked', () {
          final actual = toolPresets.isLocked(index: 0);
          const expected = true;
          expect(actual, equals(expected));
        });
        test('recent', () {
          final actual = toolPresets.isLocked(index: 1);
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method use', () {
      group('preset', () {
        test('new', () {
          final toolPresets = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2)],
          );
          final actual = toolPresets.use(eraser(3));
          final expected = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(3), eraser(2)],
          );
          expect(actual, equals(expected));
        });
        test('recent', () {
          final toolPresets = ToolPresets(recent: [eraser(1), eraser(2)]);
          final actual = toolPresets.use(eraser(2));
          final expected = ToolPresets(recent: [eraser(2), eraser(1)]);
          expect(actual, equals(expected));
        });
        test('locked', () {
          final toolPresets = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2)],
          );
          final actual = toolPresets.use(eraser(1));
          final expected = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2)],
          );
          expect(actual, equals(expected));
        });
      });
      group('limit', () {
        test('full recent', () {
          final toolPresets = ToolPresets(
            recent: [for (var size = 1; size <= 9; size++) eraser(size)],
          );
          final actual = toolPresets.use(eraser(10));
          final expected = ToolPresets(
            recent: [
              eraser(10),
              for (var size = 1; size <= 8; size++) eraser(size),
            ],
          );
          expect(actual, equals(expected));
        });
        test('full locked', () {
          final toolPresets = ToolPresets(
            locked: [for (var size = 1; size <= 9; size++) eraser(size)],
          );
          final actual = toolPresets.use(eraser(10));
          final expected = ToolPresets(
            locked: [for (var size = 1; size <= 9; size++) eraser(size)],
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('method lock', () {
      group('index', () {
        final toolPresets = ToolPresets(
          locked: [eraser(1)],
          recent: [eraser(2), eraser(3)],
        );
        test('recent', () {
          final actual = toolPresets.lock(index: 2);
          final expected = ToolPresets(
            locked: [eraser(1), eraser(3)],
            recent: [eraser(2)],
          );
          expect(actual, equals(expected));
        });
        test('locked', () {
          final actual = toolPresets.lock(index: 0);
          final expected = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2), eraser(3)],
          );
          expect(actual, equals(expected));
        });
        test('out of range', () {
          final actual = toolPresets.lock(index: 3);
          final expected = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2), eraser(3)],
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('method unlock', () {
      group('index', () {
        final toolPresets = ToolPresets(
          locked: [eraser(1), eraser(2)],
          recent: [eraser(3)],
        );
        test('locked', () {
          final actual = toolPresets.unlock(index: 0);
          final expected = ToolPresets(
            locked: [eraser(2)],
            recent: [eraser(1), eraser(3)],
          );
          expect(actual, equals(expected));
        });
        test('recent', () {
          final actual = toolPresets.unlock(index: 2);
          final expected = ToolPresets(
            locked: [eraser(1), eraser(2)],
            recent: [eraser(3)],
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same values', () {
          final toolPresets = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2)],
          );
          final other = ToolPresets(locked: [eraser(1)], recent: [eraser(2)]);
          final actual = toolPresets == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        final toolPresets = ToolPresets(
          locked: [eraser(1)],
          recent: [eraser(2)],
        );
        test('locked', () {
          final other = ToolPresets(locked: [eraser(3)], recent: [eraser(2)]);
          final actual = toolPresets == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('recent', () {
          final other = ToolPresets(locked: [eraser(1)], recent: [eraser(3)]);
          final actual = toolPresets == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          final actual = toolPresets == Object();
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('hashCode', () {
      group('equals', () {
        test('same values', () {
          final toolPresets = ToolPresets(recent: [eraser(1)]);
          final other = ToolPresets(recent: [eraser(1)]);
          final actual = toolPresets.hashCode;
          final expected = other.hashCode;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('locked instead of recent', () {
          final toolPresets = ToolPresets(recent: [eraser(1)]);
          final other = ToolPresets(locked: [eraser(1)]);
          final actual = toolPresets.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('toString', () {
      group('values', () {
        test('locked and recent', () {
          final toolPresets = ToolPresets(
            locked: [eraser(1)],
            recent: [eraser(2)],
          );
          final actual = toolPresets.toString();
          const expected =
              'ToolPresets(locked: [ToolPreset(eraser, null, null, 1, null, null)], '
              'recent: [ToolPreset(eraser, null, null, 2, null, null)])';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
