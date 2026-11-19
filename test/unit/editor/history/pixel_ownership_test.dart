import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/history/layer_snapshot.dart';
import 'package:paint/editor/history/pixel_ownership.dart';

import '../../../support/history_entries.dart';
import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const red = 0xffff0000;
  const blue = 0xff0000ff;
  const green = 0xff00ff00;
  const halfRed = 0x80ff0000;
  const pixel = PixelRectangle(left: 0, top: 0, width: 1, height: 1);

  group('class PixelOwnership', () {
    group('factory resolved', () {
      group('edits', () {
        test('nothing checked', () {
          final image = layerFromRows([
            [red],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent],
                after: [red],
              ),
            ],
            checkedEntries: {},
          );
          final expected = PixelOwnership(
            image: image,
            area: const PixelRectangle(left: 0, top: 0, width: 0, height: 0),
            owned: const [],
            fallback: rgbaOf([]),
          );
          expect(actual, equals(expected));
        });
        test('one checked', () {
          final image = layerFromRows([
            [red],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent],
                after: [red],
              ),
            ],
            checkedEntries: {0},
          );
          final expected = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([transparent]),
          );
          expect(actual, equals(expected));
        });
        test('checked then unchecked', () {
          final image = layerFromRows([
            [blue],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent],
                after: [red],
              ),
              rowEdit(
                entryIndex: 1,
                image: image,
                before: [red],
                after: [blue],
              ),
            ],
            checkedEntries: {0},
          );
          final expected = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [false],
            fallback: rgbaOf([transparent]),
          );
          expect(actual, equals(expected));
        });
        test('unchecked then checked', () {
          final image = layerFromRows([
            [blue],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent],
                after: [red],
              ),
              rowEdit(
                entryIndex: 1,
                image: image,
                before: [red],
                after: [blue],
              ),
            ],
            checkedEntries: {1},
          );
          final expected = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([red]),
          );
          expect(actual, equals(expected));
        });
        test('checked, unchecked, checked', () {
          final image = layerFromRows([
            [green],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent],
                after: [red],
              ),
              rowEdit(
                entryIndex: 1,
                image: image,
                before: [red],
                after: [blue],
              ),
              rowEdit(
                entryIndex: 2,
                image: image,
                before: [blue],
                after: [green],
              ),
            ],
            checkedEntries: {0, 2},
          );
          final expected = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          expect(actual, equals(expected));
        });
        test('two checked in a row', () {
          final image = layerFromRows([
            [blue],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent],
                after: [red],
              ),
              rowEdit(
                entryIndex: 1,
                image: image,
                before: [red],
                after: [blue],
              ),
            ],
            checkedEntries: {0, 1},
          );
          final expected = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([transparent]),
          );
          expect(actual, equals(expected));
        });
      });

      group('images', () {
        test('edit on other image', () {
          final image = layerFromRows([
            [red],
          ]);
          final otherImage = layerFromRows([
            [red],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: otherImage,
                before: [transparent],
                after: [red],
              ),
            ],
            checkedEntries: {0},
          );
          final expected = PixelOwnership(
            image: image,
            area: const PixelRectangle(left: 0, top: 0, width: 0, height: 0),
            owned: const [],
            fallback: rgbaOf([]),
          );
          expect(actual, equals(expected));
        });
      });

      group('pixels', () {
        test('unchanged pixel inside snapshot area', () {
          final image = layerFromRows([
            [blue, red],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent, red],
                after: [blue, red],
              ),
            ],
            checkedEntries: {0},
          );
          final expected = PixelOwnership(
            image: image,
            area: const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
            owned: const [true, false],
            fallback: rgbaOf([transparent, transparent]),
          );
          expect(actual, equals(expected));
        });
        test('net-zero change', () {
          final image = layerFromRows([
            [blue],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [blue],
                after: [red],
              ),
              rowEdit(
                entryIndex: 1,
                image: image,
                before: [red],
                after: [blue],
              ),
            ],
            checkedEntries: {0, 1},
          );
          final expected = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [false],
            fallback: rgbaOf([transparent]),
          );
          expect(actual, equals(expected));
        });
        test('union of checked edits', () {
          final image = layerFromRows([
            [red, transparent, blue],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                before: [transparent],
                after: [red],
              ),
              rowEdit(
                entryIndex: 1,
                image: image,
                left: 2,
                before: [transparent],
                after: [blue],
              ),
            ],
            checkedEntries: {0, 1},
          );
          final expected = PixelOwnership(
            image: image,
            area: const PixelRectangle(left: 0, top: 0, width: 3, height: 1),
            owned: const [true, false, true],
            fallback: rgbaOf([transparent, transparent, transparent]),
          );
          expect(actual, equals(expected));
        });
        test('unchecked edit partially outside area', () {
          final image = layerFromRows([
            [blue, green],
          ]);
          final actual = PixelOwnership.resolved(
            image: image,
            edits: [
              rowEdit(
                entryIndex: 0,
                image: image,
                left: 1,
                before: [transparent],
                after: [red],
              ),
              rowEdit(
                entryIndex: 1,
                image: image,
                before: [transparent, red],
                after: [blue, green],
              ),
            ],
            checkedEntries: {0},
          );
          final expected = PixelOwnership(
            image: image,
            area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            owned: const [false],
            fallback: rgbaOf([transparent]),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('getter isEmpty', () {
      group('ownership', () {
        test('owned pixel', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [red],
            ]),
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([transparent]),
          );
          final actual = pixelOwnership.isEmpty;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('no owned pixel', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [red],
            ]),
            area: pixel,
            owned: const [false],
            fallback: rgbaOf([transparent]),
          );
          final actual = pixelOwnership.isEmpty;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });

    group('method reverted', () {
      group('ownership', () {
        test('owned pixel', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [red],
            ]),
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership.reverted();
          final expected = LayerSnapshot(area: pixel, rgba: rgbaOf([blue]));
          expect(actual, equals(expected));
        });
        test('unowned pixel', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [red],
            ]),
            area: pixel,
            owned: const [false],
            fallback: rgbaOf([transparent]),
          );
          final actual = pixelOwnership.reverted();
          final expected = LayerSnapshot(area: pixel, rgba: rgbaOf([red]));
          expect(actual, equals(expected));
        });
      });
    });

    group('method layerized', () {
      group('pixels', () {
        test('opaque pixel', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [red],
            ]),
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership.layerized();
          final expected = (
            source: LayerSnapshot(area: pixel, rgba: rgbaOf([blue])),
            lifted: LayerSnapshot(area: pixel, rgba: rgbaOf([red])),
          );
          expect(actual, equals(expected));
        });
        test('transparent fallback', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [halfRed],
            ]),
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([transparent]),
          );
          final actual = pixelOwnership.layerized();
          final expected = (
            source: LayerSnapshot(area: pixel, rgba: rgbaOf([transparent])),
            lifted: LayerSnapshot(area: pixel, rgba: rgbaOf([halfRed])),
          );
          expect(actual, equals(expected));
        });
        test('erasure', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [transparent],
            ]),
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership.layerized();
          final expected = (
            source: LayerSnapshot(area: pixel, rgba: rgbaOf([transparent])),
            lifted: LayerSnapshot(area: pixel, rgba: rgbaOf([transparent])),
          );
          expect(actual, equals(expected));
        });
        test('semi-transparent over content', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [halfRed],
            ]),
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership.layerized();
          final expected = (
            source: LayerSnapshot(area: pixel, rgba: rgbaOf([halfRed])),
            lifted: LayerSnapshot(area: pixel, rgba: rgbaOf([transparent])),
          );
          expect(actual, equals(expected));
        });
        test('unowned pixel', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [red],
            ]),
            area: pixel,
            owned: const [false],
            fallback: rgbaOf([transparent]),
          );
          final actual = pixelOwnership.layerized();
          final expected = (
            source: LayerSnapshot(area: pixel, rgba: rgbaOf([red])),
            lifted: LayerSnapshot(area: pixel, rgba: rgbaOf([transparent])),
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same fields', () {
          final image = layerFromRows([
            [red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final other = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });

      group('not equals', () {
        test('equal but different image', () {
          final image = layerFromRows([
            [red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final other = PixelOwnership(
            image: layerFromRows([
              [red],
            ]),
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different area', () {
          final image = layerFromRows([
            [red, red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final other = PixelOwnership(
            image: image,
            area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different owned', () {
          final image = layerFromRows([
            [red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final other = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [false],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different fallback', () {
          final image = layerFromRows([
            [red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final other = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([green]),
          );
          final actual = pixelOwnership == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          final image = layerFromRows([
            [red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final Object other = image;
          final actual = pixelOwnership == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same fields', () {
          final image = layerFromRows([
            [red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final other = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final actual = pixelOwnership.hashCode;
          final expected = other.hashCode;
          expect(actual, equals(expected));
        });
      });

      group('not equals', () {
        test('different fallback', () {
          final image = layerFromRows([
            [red],
          ]);
          final pixelOwnership = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([blue]),
          );
          final other = PixelOwnership(
            image: image,
            area: pixel,
            owned: const [true],
            fallback: rgbaOf([green]),
          );
          final actual = pixelOwnership.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('format', () {
        test('area and owned count', () {
          final pixelOwnership = PixelOwnership(
            image: layerFromRows([
              [red, red],
            ]),
            area: const PixelRectangle(left: 0, top: 0, width: 2, height: 1),
            owned: const [true, false],
            fallback: rgbaOf([blue, transparent]),
          );
          final actual = pixelOwnership.toString();
          const expected =
              'PixelOwnership(PixelRectangle(0, 0, 2, 1), owned: 1)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
