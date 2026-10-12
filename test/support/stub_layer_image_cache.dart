import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/widgets/components/layer_image_cache.dart';

class StubLayerImageCache implements LayerImageCache {
  StubLayerImageCache({required this.tiles});

  final Map<Layer, List<LayerTile>> tiles;
  final retainedLayers = <List<Layer>>[];

  @override
  int get tileSize => LayerImageCache.defaultTileSize;

  @override
  List<LayerTile> tilesOf(Layer layer) => tiles[layer] ?? const [];

  @override
  void retainOnly(Iterable<Layer> layers) => retainedLayers.add([...layers]);

  @override
  void dispose() {}
}
