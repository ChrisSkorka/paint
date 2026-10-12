import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/canvas_layer.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/canvas/pixel_rectangle.dart';
import 'package:paint/editor/pointer_preview.dart';
import 'package:paint/widgets/components/layer_image_cache.dart';
import 'package:paint/widgets/components/pixel_canvas.dart';

import '../../../support/image_probes.dart';
import '../../../support/stub_canvas.dart';
import '../../../support/stub_layer_image_cache.dart';
import '../../../support/stub_tool.dart';

void main() {
  group('class PixelLayersPainter', () {
    group('method paint', () {
      group('layers', () {
        test('none', () {
          final stubLayerImageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: const [],
            zoom: 1,
            imageCache: stubLayerImageCache,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(2, 2));
          final actual = stubCanvas.drawnImages;
          const expected = <(Image, Rect, Rect)>[];
          expect(actual, equals(expected));
        });
        test('without tiles', () {
          final stubLayerImageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(
                image: Layer.filled(
                  width: 2,
                  height: 2,
                  color: PixelColor.transparent,
                ),
              ),
            ],
            zoom: 1,
            imageCache: stubLayerImageCache,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(2, 2));
          final actual = stubCanvas.drawnImages;
          const expected = <(Image, Rect, Rect)>[];
          expect(actual, equals(expected));
        });
        test('stacked', () {
          final bottom = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          final top = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final bottomImage = blankImage();
          final topImage = blankImage();
          final stubLayerImageCache = StubLayerImageCache(
            tiles: {
              bottom: [
                LayerTile(
                  area: const PixelRectangle(
                    left: 0,
                    top: 0,
                    width: 1,
                    height: 1,
                  ),
                  image: bottomImage,
                ),
              ],
              top: [
                LayerTile(
                  area: const PixelRectangle(
                    left: 0,
                    top: 0,
                    width: 1,
                    height: 1,
                  ),
                  image: topImage,
                ),
              ],
            },
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(image: bottom),
              CanvasLayer(image: top),
            ],
            zoom: 1,
            imageCache: stubLayerImageCache,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = stubCanvas.drawnImages;
          final expected = [
            (
              bottomImage,
              const Rect.fromLTRB(0, 0, 1, 1),
              const Rect.fromLTRB(0, 0, 1, 1),
            ),
            (
              topImage,
              const Rect.fromLTRB(0, 0, 1, 1),
              const Rect.fromLTRB(0, 0, 1, 1),
            ),
          ];
          expect(actual, equals(expected));
        });
      });

      group('tiles', () {
        test('single tile', () {
          final layer = Layer.filled(
            width: 3,
            height: 2,
            color: PixelColor.black,
          );
          final image = blankImage();
          final stubLayerImageCache = StubLayerImageCache(
            tiles: {
              layer: [
                LayerTile(
                  area: const PixelRectangle(
                    left: 0,
                    top: 0,
                    width: 3,
                    height: 2,
                  ),
                  image: image,
                ),
              ],
            },
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: stubLayerImageCache,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(3, 2));
          final actual = stubCanvas.drawnImages;
          final expected = [
            (
              image,
              const Rect.fromLTRB(0, 0, 3, 2),
              const Rect.fromLTRB(0, 0, 3, 2),
            ),
          ];
          expect(actual, equals(expected));
        });
        test('multiple tiles', () {
          final layer = Layer.filled(
            width: 3,
            height: 2,
            color: PixelColor.black,
          );
          final leftImage = blankImage();
          final rightImage = blankImage();
          final stubLayerImageCache = StubLayerImageCache(
            tiles: {
              layer: [
                LayerTile(
                  area: const PixelRectangle(
                    left: 0,
                    top: 0,
                    width: 2,
                    height: 2,
                  ),
                  image: leftImage,
                ),
                LayerTile(
                  area: const PixelRectangle(
                    left: 2,
                    top: 0,
                    width: 1,
                    height: 2,
                  ),
                  image: rightImage,
                ),
              ],
            },
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: stubLayerImageCache,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(3, 2));
          final actual = stubCanvas.drawnImages;
          final expected = [
            (
              leftImage,
              const Rect.fromLTRB(0, 0, 2, 2),
              const Rect.fromLTRB(0, 0, 2, 2),
            ),
            (
              rightImage,
              const Rect.fromLTRB(0, 0, 1, 2),
              const Rect.fromLTRB(2, 0, 3, 2),
            ),
          ];
          expect(actual, equals(expected));
        });
      });

      group('zoom', () {
        test('scaled', () {
          final layer = Layer.filled(
            width: 2,
            height: 2,
            color: PixelColor.black,
          );
          final image = blankImage();
          final stubLayerImageCache = StubLayerImageCache(
            tiles: {
              layer: [
                LayerTile(
                  area: const PixelRectangle(
                    left: 1,
                    top: 1,
                    width: 1,
                    height: 1,
                  ),
                  image: image,
                ),
              ],
            },
          );
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 3,
            imageCache: stubLayerImageCache,
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(6, 6));
          final actual = stubCanvas.drawnImages;
          final expected = [
            (
              image,
              const Rect.fromLTRB(0, 0, 1, 1),
              const Rect.fromLTRB(3, 3, 6, 6),
            ),
          ];
          expect(actual, equals(expected));
        });
      });

      group('opacity', () {
        test('opaque', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(
                image: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
              ),
            ],
            zoom: 1,
            imageCache: StubLayerImageCache(tiles: {}),
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = [stubCanvas.savedLayers, stubCanvas.restoreCount];
          final expected = [<(Rect?, int)>[], 0];
          expect(actual, equals(expected));
        });
        test('translucent', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(
                image: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
                opacity: 50,
              ),
            ],
            zoom: 1,
            imageCache: StubLayerImageCache(tiles: {}),
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = [stubCanvas.savedLayers, stubCanvas.restoreCount];
          final expected = [
            [(const Rect.fromLTRB(0, 0, 1, 1), 0x80000000)],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('invisible opacity', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(
                image: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
                opacity: 0,
              ),
            ],
            zoom: 1,
            imageCache: StubLayerImageCache(tiles: {}),
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = [stubCanvas.savedLayers, stubCanvas.restoreCount];
          final expected = [
            [(const Rect.fromLTRB(0, 0, 1, 1), 0x00000000)],
            1,
          ];
          expect(actual, equals(expected));
        });
      });

      group('tint', () {
        test('opaque tinted', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(
                image: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
                tint: PixelColor.white,
              ),
            ],
            zoom: 1,
            imageCache: StubLayerImageCache(tiles: {}),
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = [
            stubCanvas.savedLayers,
            stubCanvas.savedLayerFilters,
            stubCanvas.restoreCount,
          ];
          final expected = [
            [(const Rect.fromLTRB(0, 0, 1, 1), 0xFF000000)],
            [PixelLayersPainter.tintFilter(PixelColor.white)],
            1,
          ];
          expect(actual, equals(expected));
        });
        test('translucent tinted', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(
                image: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
                opacity: 50,
                tint: PixelColor.white,
              ),
            ],
            zoom: 1,
            imageCache: StubLayerImageCache(tiles: {}),
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = [stubCanvas.savedLayers, stubCanvas.savedLayerFilters];
          final expected = [
            [(const Rect.fromLTRB(0, 0, 1, 1), 0x80000000)],
            [PixelLayersPainter.tintFilter(PixelColor.white)],
          ];
          expect(actual, equals(expected));
        });
        test('untinted translucent', () {
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(
                image: Layer.filled(
                  width: 1,
                  height: 1,
                  color: PixelColor.black,
                ),
                opacity: 50,
              ),
            ],
            zoom: 1,
            imageCache: StubLayerImageCache(tiles: {}),
          );
          final stubCanvas = StubCanvas();
          pixelLayersPainter.paint(stubCanvas, const Size(1, 1));
          final actual = stubCanvas.savedLayerFilters;
          const expected = [null];
          expect(actual, equals(expected));
        });
      });

      group('cache', () {
        test('retained layers', () {
          final bottom = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.white,
          );
          final top = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final stubLayerImageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [
              CanvasLayer(image: bottom),
              CanvasLayer(image: top),
            ],
            zoom: 1,
            imageCache: stubLayerImageCache,
          );
          pixelLayersPainter.paint(StubCanvas(), const Size(1, 1));
          final actual = stubLayerImageCache.retainedLayers;
          final expected = [
            [bottom, top],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method tintFilter', () {
      group('colors', () {
        test('red', () {
          final actual = PixelLayersPainter.tintFilter(
            const PixelColor(argb: 0xFFFF0000),
          );
          const expected = ColorFilter.matrix([
            0.5, 0, 0, 0, 127.5, //
            0, 0.5, 0, 0, 0, //
            0, 0, 0.5, 0, 0, //
            0, 0, 0, 1, 0, //
          ]);
          expect(actual, equals(expected));
        });
      });
    });

    group('method paintPixels', () {
      group('zoom', () {
        test('unscaled', () {
          final pixels = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          pixels.setPixel(
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.white,
          );
          final stubCanvas = StubCanvas();
          PixelLayersPainter.paintPixels(
            canvas: stubCanvas,
            pixels: pixels,
            zoom: 1,
          );
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(1, 0, 2, 1), 0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
        test('scaled', () {
          final pixels = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.transparent,
          );
          pixels.setPixel(
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.white,
          );
          final stubCanvas = StubCanvas();
          PixelLayersPainter.paintPixels(
            canvas: stubCanvas,
            pixels: pixels,
            zoom: 2,
          );
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(2, 0, 4, 2), 0xFFFFFFFF)];
          expect(actual, equals(expected));
        });
      });
    });

    group('method paintArea', () {
      group('areas', () {
        test('inside', () {
          final pixels = Layer.filled(
            width: 3,
            height: 1,
            color: PixelColor.black,
          );
          final stubCanvas = StubCanvas();
          PixelLayersPainter.paintArea(
            canvas: stubCanvas,
            pixels: pixels,
            area: const PixelRectangle(left: 1, top: 0, width: 1, height: 1),
            zoom: 2,
          );
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(2, 0, 4, 2), 0xFF000000)];
          expect(actual, equals(expected));
        });
        test('clipped to bounds', () {
          final pixels = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.black,
          );
          final stubCanvas = StubCanvas();
          PixelLayersPainter.paintArea(
            canvas: stubCanvas,
            pixels: pixels,
            area: const PixelRectangle(left: 1, top: -1, width: 4, height: 4),
            zoom: 1,
          );
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(1, 0, 2, 1), 0xFF000000)];
          expect(actual, equals(expected));
        });
        test('empty', () {
          final pixels = Layer.filled(
            width: 2,
            height: 1,
            color: PixelColor.black,
          );
          final stubCanvas = StubCanvas();
          PixelLayersPainter.paintArea(
            canvas: stubCanvas,
            pixels: pixels,
            area: const PixelRectangle(left: 0, top: 0, width: 0, height: 0),
            zoom: 1,
          );
          final actual = stubCanvas.drawnRectangles;
          const expected = <(Rect, int)>[];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('old delegate', () {
        test('same painter', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(pixelLayersPainter);
          const expected = false;
          expect(actual, equals(expected));
        });
        test('equal layer list', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(
            PixelLayersPainter(
              layers: [CanvasLayer(image: layer)],
              zoom: 1,
              imageCache: imageCache,
            ),
          );
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different zoom', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(
            PixelLayersPainter(
              layers: [CanvasLayer(image: layer)],
              zoom: 2,
              imageCache: imageCache,
            ),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different cache', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(
            PixelLayersPainter(
              layers: [CanvasLayer(image: layer)],
              zoom: 1,
              imageCache: StubLayerImageCache(tiles: {}),
            ),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different layer count', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(
            PixelLayersPainter(
              layers: const [],
              zoom: 1,
              imageCache: imageCache,
            ),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('equal content image', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(
            PixelLayersPainter(
              layers: [CanvasLayer(image: Layer.copyOf(layer))],
              zoom: 1,
              imageCache: imageCache,
            ),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different opacity', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(
            PixelLayersPainter(
              layers: [CanvasLayer(image: layer, opacity: 50)],
              zoom: 1,
              imageCache: imageCache,
            ),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different tint', () {
          final layer = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.black,
          );
          final imageCache = StubLayerImageCache(tiles: {});
          final pixelLayersPainter = PixelLayersPainter(
            layers: [CanvasLayer(image: layer)],
            zoom: 1,
            imageCache: imageCache,
          );
          final actual = pixelLayersPainter.shouldRepaint(
            PixelLayersPainter(
              layers: [CanvasLayer(image: layer, tint: PixelColor.white)],
              zoom: 1,
              imageCache: imageCache,
            ),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class PointerPreviewPainter', () {
    group('method paint', () {
      group('preview', () {
        test('cleared', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 2);
          final pointerPreviewPainter = PointerPreviewPainter(
            preview: pointerPreview,
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pointerPreviewPainter.paint(stubCanvas, const Size(2, 2));
          final actual = stubCanvas.drawnRectangles;
          const expected = <(Rect, int)>[];
          expect(actual, equals(expected));
        });
        test('drawn', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 2);
          pointerPreview.draw(
            tool: StubTool(),
            point: const PixelPoint(x: 1, y: 0),
            color: PixelColor.black,
          );
          final pointerPreviewPainter = PointerPreviewPainter(
            preview: pointerPreview,
            zoom: 1,
          );
          final stubCanvas = StubCanvas();
          pointerPreviewPainter.paint(stubCanvas, const Size(2, 2));
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(1, 0, 2, 1), 0xFF000000)];
          expect(actual, equals(expected));
        });
      });

      group('zoom', () {
        test('scaled', () {
          final pointerPreview = PointerPreview.sized(width: 2, height: 2);
          pointerPreview.draw(
            tool: StubTool(),
            point: const PixelPoint(x: 1, y: 1),
            color: PixelColor.black,
          );
          final pointerPreviewPainter = PointerPreviewPainter(
            preview: pointerPreview,
            zoom: 3,
          );
          final stubCanvas = StubCanvas();
          pointerPreviewPainter.paint(stubCanvas, const Size(6, 6));
          final actual = stubCanvas.drawnRectangles;
          const expected = [(Rect.fromLTRB(3, 3, 6, 6), 0xFF000000)];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('old delegate', () {
        test('same values', () {
          final pointerPreview = PointerPreview.sized(width: 1, height: 1);
          final pointerPreviewPainter = PointerPreviewPainter(
            preview: pointerPreview,
            zoom: 1,
          );
          final actual = pointerPreviewPainter.shouldRepaint(
            PointerPreviewPainter(preview: pointerPreview, zoom: 1),
          );
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different preview', () {
          final pointerPreviewPainter = PointerPreviewPainter(
            preview: PointerPreview.sized(width: 1, height: 1),
            zoom: 1,
          );
          final actual = pointerPreviewPainter.shouldRepaint(
            PointerPreviewPainter(
              preview: PointerPreview.sized(width: 1, height: 1),
              zoom: 1,
            ),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different zoom', () {
          final pointerPreview = PointerPreview.sized(width: 1, height: 1);
          final pointerPreviewPainter = PointerPreviewPainter(
            preview: pointerPreview,
            zoom: 1,
          );
          final actual = pointerPreviewPainter.shouldRepaint(
            PointerPreviewPainter(preview: pointerPreview, zoom: 2),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });

  group('class SelectionOutlinePainter', () {
    group('method paint', () {
      group('areas', () {
        test('none', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: null,
            zoom: 2,
          );
          final stubCanvas = StubCanvas();
          selectionOutlinePainter.paint(stubCanvas, const Size(4, 4));
          final actual = [stubCanvas.drawnRectangles, stubCanvas.drawnPaths];
          const expected = [<(Rect, int)>[], <(Rect, int)>[]];
          expect(actual, equals(expected));
        });
        test('zoomed', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: PixelRectangle(left: 1, top: 1, width: 5, height: 1),
            zoom: 2,
          );
          final stubCanvas = StubCanvas();
          selectionOutlinePainter.paint(stubCanvas, const Size(12, 4));
          final actual = [stubCanvas.drawnRectangles, stubCanvas.drawnPaths];
          const expected = [
            [(Rect.fromLTRB(2.5, 2.5, 11.5, 3.5), 0xFFFFFFFF)],
            [(Rect.fromLTRB(2.5, 2.5, 11.5, 3.5), 0xFF000000)],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method shouldRepaint', () {
      group('old delegate', () {
        test('same values', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            zoom: 1,
          );
          final actual = selectionOutlinePainter.shouldRepaint(
            const SelectionOutlinePainter(
              area: PixelRectangle(left: 0, top: 0, width: 1, height: 1),
              zoom: 1,
            ),
          );
          const expected = false;
          expect(actual, equals(expected));
        });
        test('different area', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: PixelRectangle(left: 0, top: 0, width: 1, height: 1),
            zoom: 1,
          );
          final actual = selectionOutlinePainter.shouldRepaint(
            const SelectionOutlinePainter(area: null, zoom: 1),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
        test('different zoom', () {
          const selectionOutlinePainter = SelectionOutlinePainter(
            area: null,
            zoom: 1,
          );
          final actual = selectionOutlinePainter.shouldRepaint(
            const SelectionOutlinePainter(area: null, zoom: 2),
          );
          const expected = true;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
