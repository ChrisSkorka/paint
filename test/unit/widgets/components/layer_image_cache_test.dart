import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/widgets/components/layer_image_cache.dart';

import '../../../support/image_probes.dart';
import '../../../support/layer_probes.dart';

void main() {
  const transparent = 0x00000000;
  const black = 0xFF000000;
  const white = 0xFFFFFFFF;
  const translucentRed = 0x80FF0000;

  group('class LayerTile', () {
    group('operator ==', () {
      group('equals', () {
        test('same area and image', () {
          final image = blankImage();
          final layerTile = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: image,
          );
          final other = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: image,
          );
          final actual = layerTile == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different area', () {
          final image = blankImage();
          final layerTile = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: image,
          );
          final other = LayerTile(
            area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            image: image,
          );
          final actual = layerTile == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different image', () {
          final layerTile = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: blankImage(),
          );
          final other = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: blankImage(),
          );
          final actual = layerTile == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('hashCode', () {
      group('equals', () {
        test('same area and image', () {
          final image = blankImage();
          final layerTile = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: image,
          );
          final other = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: image,
          );
          final actual = layerTile.hashCode == other.hashCode;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different area', () {
          final image = blankImage();
          final layerTile = LayerTile(
            area: const PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            image: image,
          );
          final other = LayerTile(
            area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            image: image,
          );
          final actual = layerTile.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('toString', () {
      group('description', () {
        test('area', () {
          final layerTile = LayerTile(
            area: const PixelRectangle(left: 1, top: 2, width: 3, height: 4),
            image: blankImage(),
          );
          final actual = layerTile.toString();
          const expected = 'LayerTile(PixelRectangle(1, 2, 3, 4))';
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class LayerImageCache', () {
    group('method tilesOf', () {
      group('layer contents', () {
        test('transparent', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final actual = layerImageCache.tilesOf(
            Layer.filled(width: 2, height: 2, color: PixelColor.transparent),
          );
          const expected = <LayerTile>[];
          expect(actual, equals(expected));
        });
        test('opaque', () async {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final tiles = layerImageCache.tilesOf(
            layerFromRows([
              [black, white],
              [white, black],
            ]),
          );
          final actual = [
            tiles.single.area,
            await imageRows(tiles.single.image),
          ];
          const expected = [
            PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            [
              [black, white],
              [white, black],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('translucent', () async {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final tiles = layerImageCache.tilesOf(
            layerFromRows([
              [translucentRed, transparent],
            ]),
          );
          final actual = await imageRows(tiles.single.image);
          const expected = [
            [translucentRed, transparent],
          ];
          expect(actual, equals(expected));
        });
        test('partially transparent tiles', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final tiles = layerImageCache.tilesOf(
            layerFromRows([
              [black, transparent, transparent, transparent],
              [transparent, transparent, transparent, transparent],
            ]),
          );
          final actual = [for (final tile in tiles) tile.area];
          const expected = [
            PixelRectangle(left: 0, top: 0, width: 2, height: 2),
          ];
          expect(actual, equals(expected));
        });
      });

      group('tiling', () {
        test('exact multiple', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final tiles = layerImageCache.tilesOf(
            Layer.filled(width: 4, height: 4, color: PixelColor.black),
          );
          final actual = [for (final tile in tiles) tile.area];
          const expected = [
            PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            PixelRectangle(left: 2, top: 0, width: 2, height: 2),
            PixelRectangle(left: 0, top: 2, width: 2, height: 2),
            PixelRectangle(left: 2, top: 2, width: 2, height: 2),
          ];
          expect(actual, equals(expected));
        });
        test('remainder edges', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final tiles = layerImageCache.tilesOf(
            Layer.filled(width: 3, height: 3, color: PixelColor.black),
          );
          final actual = [for (final tile in tiles) tile.area];
          const expected = [
            PixelRectangle(left: 0, top: 0, width: 2, height: 2),
            PixelRectangle(left: 2, top: 0, width: 1, height: 2),
            PixelRectangle(left: 0, top: 2, width: 2, height: 1),
            PixelRectangle(left: 2, top: 2, width: 1, height: 1),
          ];
          expect(actual, equals(expected));
        });
        test('default tile size', () {
          final layerImageCache = LayerImageCache();
          final tiles = layerImageCache.tilesOf(
            Layer.filled(width: 65, height: 1, color: PixelColor.black),
          );
          final actual = [for (final tile in tiles) tile.area];
          const expected = [
            PixelRectangle(left: 0, top: 0, width: 64, height: 1),
            PixelRectangle(left: 64, top: 0, width: 1, height: 1),
          ];
          expect(actual, equals(expected));
        });
      });

      group('changes', () {
        test('unchanged', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final layer = Layer.filled(
            width: 4,
            height: 2,
            color: PixelColor.black,
          );
          final before = layerImageCache.tilesOf(layer);
          final actual = layerImageCache.tilesOf(layer);
          final expected = before;
          expect(actual, equals(expected));
        });
        test('changed tile', () async {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final layer = Layer.filled(
            width: 4,
            height: 2,
            color: PixelColor.black,
          );
          final before = layerImageCache.tilesOf(layer);
          layer.setPixel(
            point: const PixelPoint(x: 3, y: 1),
            color: PixelColor.white,
          );
          final after = layerImageCache.tilesOf(layer);
          final actual = [
            after.first == before.first,
            after.last.area,
            await imageRows(after.last.image),
            before.last.image.debugDisposed,
          ];
          const expected = [
            true,
            PixelRectangle(left: 2, top: 0, width: 2, height: 2),
            [
              [black, black],
              [black, white],
            ],
            true,
          ];
          expect(actual, equals(expected));
        });
        test('cleared tile', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final layer = Layer.filled(
            width: 4,
            height: 2,
            color: PixelColor.black,
          );
          final before = layerImageCache.tilesOf(layer);
          layer.fillRectangle(
            rectangle: const PixelRectangle(
              left: 2,
              top: 0,
              width: 2,
              height: 2,
            ),
            color: PixelColor.transparent,
          );
          final after = layerImageCache.tilesOf(layer);
          final actual = [after, before.last.image.debugDisposed];
          final expected = [
            [before.first],
            true,
          ];
          expect(actual, equals(expected));
        });
        test('misaligned bytes', () async {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final layer = Layer(
            width: 1,
            height: 1,
            rgba: Uint8List.sublistView(Uint8List(5), 1),
          );
          layer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.black,
          );
          final before = await imageRows(
            layerImageCache.tilesOf(layer).single.image,
          );
          layer.setPixel(
            point: const PixelPoint(x: 0, y: 0),
            color: PixelColor.white,
          );
          final after = await imageRows(
            layerImageCache.tilesOf(layer).single.image,
          );
          final actual = [before, after];
          const expected = [
            [
              [black],
            ],
            [
              [white],
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('layers', () {
        test('equal content distinct layers', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final first = layerImageCache.tilesOf(
            Layer.filled(width: 1, height: 1, color: PixelColor.black),
          );
          final second = layerImageCache.tilesOf(
            Layer.filled(width: 1, height: 1, color: PixelColor.black),
          );
          final actual = identical(first.single.image, second.single.image);
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method retainOnly', () {
      group('layers', () {
        test('none', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final tiles = layerImageCache.tilesOf(
            Layer.filled(width: 1, height: 1, color: PixelColor.black),
          );
          layerImageCache.retainOnly(const []);
          final actual = tiles.single.image.debugDisposed;
          const expected = true;
          expect(actual, equals(expected));
        });
        test('retained', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final before = layerImageCache.tilesOf(layer);
          layerImageCache.retainOnly([layer]);
          final actual = [
            before.single.image.debugDisposed,
            layerImageCache.tilesOf(layer),
          ];
          final expected = [false, before];
          expect(actual, equals(expected));
        });
        test('dropped', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final kept = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final keptTiles = layerImageCache.tilesOf(kept);
          final droppedTiles = layerImageCache.tilesOf(
            Layer.filled(width: 1, height: 1, color: PixelColor.white),
          );
          layerImageCache.retainOnly([kept]);
          final actual = [
            keptTiles.single.image.debugDisposed,
            droppedTiles.single.image.debugDisposed,
          ];
          const expected = [false, true];
          expect(actual, equals(expected));
        });
      });
    });

    group('method dispose', () {
      group('images', () {
        test('all disposed', () {
          final layerImageCache = LayerImageCache(tileSize: 2);
          final first = layerImageCache.tilesOf(
            Layer.filled(width: 1, height: 1, color: PixelColor.black),
          );
          final second = layerImageCache.tilesOf(
            Layer.filled(width: 1, height: 1, color: PixelColor.white),
          );
          layerImageCache.dispose();
          final actual = [
            first.single.image.debugDisposed,
            second.single.image.debugDisposed,
          ];
          const expected = [true, true];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
