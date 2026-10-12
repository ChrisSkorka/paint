import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../editor/canvas/layer.dart';
import '../../editor/canvas/pixel_point.dart';
import '../../editor/canvas/pixel_rectangle.dart';

class LayerTile {
  const LayerTile({required this.area, required this.image});

  final PixelRectangle area;
  final ui.Image image;

  @override
  bool operator ==(Object other) =>
      other is LayerTile && other.area == area && other.image == image;

  @override
  int get hashCode => Object.hash(area, image);

  @override
  String toString() => 'LayerTile($area)';
}

class LayerImageCache {
  LayerImageCache({this.tileSize = defaultTileSize});

  static const defaultTileSize = 64;

  final int tileSize;
  final _cachedLayers = Map<Layer, _CachedLayer>.identity();

  List<LayerTile> tilesOf(Layer layer) {
    final cached = _cachedLayers[layer];
    if (cached == null) {
      final rendered = _CachedLayer.rendered(layer: layer, tileSize: tileSize);
      _cachedLayers[layer] = rendered;
      return rendered.tiles;
    }
    cached.update(layer);
    return cached.tiles;
  }

  void retainOnly(Iterable<Layer> layers) {
    final retained = Set<Layer>.identity()..addAll(layers);
    _cachedLayers.removeWhere((layer, cached) {
      if (retained.contains(layer)) return false;
      cached.dispose();
      return true;
    });
  }

  void dispose() => retainOnly(const []);
}

class _CachedLayer {
  _CachedLayer({
    required this.width,
    required this.areas,
    required this.images,
    required this.words,
  });

  factory _CachedLayer.rendered({required Layer layer, required int tileSize}) {
    final areas = [
      for (var top = 0; top < layer.height; top += tileSize)
        for (var left = 0; left < layer.width; left += tileSize)
          PixelRectangle(
            left: left,
            top: top,
            width: min(tileSize, layer.width - left),
            height: min(tileSize, layer.height - top),
          ),
    ];
    final words = Uint32List.fromList(_wordsOf(layer));
    return _CachedLayer(
      width: layer.width,
      areas: areas,
      images: [
        for (final area in areas)
          _render(layer: layer, words: words, area: area),
      ],
      words: words,
    );
  }

  final int width;
  final List<PixelRectangle> areas;
  final List<ui.Image?> images;
  final Uint32List words;

  List<LayerTile> get tiles => [
    for (var index = 0; index < areas.length; index++)
      if (images[index] case final image?)
        LayerTile(area: areas[index], image: image),
  ];

  void update(Layer layer) {
    final current = _wordsOf(layer);
    for (var index = 0; index < areas.length; index++) {
      final area = areas[index];
      if (_matches(current: current, area: area)) continue;
      for (var y = area.top; y < area.bottom; y++) {
        final start = y * width + area.left;
        words.setRange(start, start + area.width, current, start);
      }
      images[index]?.dispose();
      images[index] = _render(layer: layer, words: words, area: area);
    }
  }

  void dispose() {
    for (final image in images) {
      image?.dispose();
    }
  }

  bool _matches({required Uint32List current, required PixelRectangle area}) {
    for (var y = area.top; y < area.bottom; y++) {
      final start = y * width + area.left;
      for (var offset = start; offset < start + area.width; offset++) {
        if (current[offset] != words[offset]) return false;
      }
    }
    return true;
  }

  static Uint32List _wordsOf(Layer layer) => layer.rgba.offsetInBytes % 4 == 0
      ? Uint32List.sublistView(layer.rgba)
      : Uint32List.sublistView(Uint8List.fromList(layer.rgba));

  static ui.Image? _render({
    required Layer layer,
    required Uint32List words,
    required PixelRectangle area,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    var drawn = false;
    for (var y = area.top; y < area.bottom; y++) {
      final rowStart = y * layer.width;
      var runStart = area.left;
      for (var x = area.left + 1; x <= area.right; x++) {
        if (x < area.right &&
            words[rowStart + x] == words[rowStart + runStart]) {
          continue;
        }
        final color = layer.getPixel(PixelPoint(x: runStart, y: y));
        if (color.alpha > 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              (runStart - area.left).toDouble(),
              (y - area.top).toDouble(),
              (x - runStart).toDouble(),
              1,
            ),
            Paint()
              ..color = Color(color.argb)
              ..isAntiAlias = false,
          );
          drawn = true;
        }
        runStart = x;
      }
    }
    final picture = recorder.endRecording();
    final image = drawn ? picture.toImageSync(area.width, area.height) : null;
    picture.dispose();
    return image;
  }
}
