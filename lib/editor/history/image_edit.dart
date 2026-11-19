import '../canvas/layer.dart';
import 'layer_snapshot.dart';

class ImageEdit {
  const ImageEdit({
    required this.entryIndex,
    required this.image,
    required this.before,
    required this.after,
  });

  final int entryIndex;
  final Layer image;
  final LayerSnapshot before;
  final LayerSnapshot after;

  @override
  bool operator ==(Object other) =>
      other is ImageEdit &&
      other.entryIndex == entryIndex &&
      identical(other.image, image) &&
      other.before == before &&
      other.after == after;

  @override
  int get hashCode =>
      Object.hash(entryIndex, identityHashCode(image), before, after);

  @override
  String toString() => 'ImageEdit(entry: $entryIndex, ${after.area})';
}
