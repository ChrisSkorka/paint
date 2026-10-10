import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../editor/canvas/layer.dart';
import '../../editor/canvas/pixel_rectangle.dart';
import '../../editor/history/layer_snapshot.dart';

class LayerTileCache extends ChangeNotifier {
  LayerTileCache({required this.tileSize});

  static const defaultTileSize = 256;

  final int tileSize;
  final _tiles = Map<Layer, _LayerTiles>.identity();

  bool get loading => _tiles.values.any((tiles) => tiles.loading.isNotEmpty);

  void paint({
    required Canvas canvas,
    required List<Layer> layers,
    required int zoom,
  }) {
    _forgetLayersOtherThan(layers);
    final imagePaint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    canvas
      ..save()
      ..scale(zoom.toDouble());
    for (final layer in layers) {
      final tiles = _sync(layer);
      for (var index = 0; index < tiles.images.length; index++) {
        final image = tiles.images[index];
        if (image == null) continue;
        final area = tiles.area(index);
        canvas.drawImage(
          image,
          Offset(area.left.toDouble(), area.top.toDouble()),
          imagePaint,
        );
      }
    }
    canvas.restore();
  }

  @override
  void dispose() {
    _forgetLayersOtherThan(const []);
    super.dispose();
  }

  void _forgetLayersOtherThan(List<Layer> layers) {
    final forgotten = _tiles.keys
        .where((layer) => !layers.any((kept) => identical(kept, layer)))
        .toList();
    for (final layer in forgotten) {
      _tiles.remove(layer)!.dispose();
    }
  }

  _LayerTiles _sync(Layer layer) {
    final tiles = _tiles.putIfAbsent(
      layer,
      () => _LayerTiles.forLayer(layer: layer, tileSize: tileSize),
    );
    tiles.markDamaged(layer.takeDamage());
    for (final index in tiles.dirty.difference(tiles.loading)) {
      _load(tiles: tiles, index: index);
    }
    return tiles;
  }

  void _load({required _LayerTiles tiles, required int index}) {
    tiles.dirty.remove(index);
    final area = tiles.area(index);
    final pixels = LayerSnapshot.capture(layer: tiles.layer, area: area).rgba;
    if (_isTransparent(pixels)) {
      tiles.replace(index: index, image: null);
      return;
    }
    _premultiply(pixels);
    tiles.loading.add(index);
    _decode(pixels: pixels, width: area.width, height: area.height).then((
      image,
    ) {
      tiles.loading.remove(index);
      if (!identical(_tiles[tiles.layer], tiles)) {
        image.dispose();
        return;
      }
      tiles.replace(index: index, image: image);
      if (tiles.dirty.contains(index)) _load(tiles: tiles, index: index);
      notifyListeners();
    });
  }

  static bool _isTransparent(Uint8List pixels) {
    for (var alpha = 3; alpha < pixels.length; alpha += 4) {
      if (pixels[alpha] != 0) return false;
    }
    return true;
  }

  static void _premultiply(Uint8List pixels) {
    for (var alpha = 3; alpha < pixels.length; alpha += 4) {
      if (pixels[alpha] == 255) continue;
      for (var channel = alpha - 3; channel < alpha; channel++) {
        pixels[channel] = (pixels[channel] * pixels[alpha] + 127) ~/ 255;
      }
    }
  }

  static Future<ui.Image> _decode({
    required Uint8List pixels,
    required int width,
    required int height,
  }) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }
}

class _LayerTiles {
  _LayerTiles({
    required this.layer,
    required this.tileSize,
    required this.columns,
    required this.images,
    required this.dirty,
    required this.loading,
  });

  factory _LayerTiles.forLayer({required Layer layer, required int tileSize}) {
    final columns = (layer.width + tileSize - 1) ~/ tileSize;
    final rows = (layer.height + tileSize - 1) ~/ tileSize;
    return _LayerTiles(
      layer: layer,
      tileSize: tileSize,
      columns: columns,
      images: List<ui.Image?>.filled(columns * rows, null),
      dirty: {for (var index = 0; index < columns * rows; index++) index},
      loading: {},
    );
  }

  final Layer layer;
  final int tileSize;
  final int columns;
  final List<ui.Image?> images;
  final Set<int> dirty;
  final Set<int> loading;

  PixelRectangle area(int index) => PixelRectangle(
    left: index % columns * tileSize,
    top: index ~/ columns * tileSize,
    width: tileSize,
    height: tileSize,
  ).intersection(layer.bounds);

  void markDamaged(PixelRectangle damage) {
    if (damage.isEmpty) return;
    for (
      var row = damage.top ~/ tileSize;
      row * tileSize < damage.bottom;
      row++
    ) {
      for (
        var column = damage.left ~/ tileSize;
        column * tileSize < damage.right;
        column++
      ) {
        dirty.add(row * columns + column);
      }
    }
  }

  void replace({required int index, required ui.Image? image}) {
    images[index]?.dispose();
    images[index] = image;
  }

  void dispose() {
    for (var index = 0; index < images.length; index++) {
      replace(index: index, image: null);
    }
  }
}
