import '../canvas/layer.dart';

class TextOrientation {
  const TextOrientation({this.quarterTurns = 0, this.mirrored = false});

  final int quarterTurns;
  final bool mirrored;

  TextOrientation rotate({required bool clockwise}) => TextOrientation(
    quarterTurns: (quarterTurns + (clockwise ? 1 : -1)) % 4,
    mirrored: mirrored,
  );

  TextOrientation mirror({required bool horizontally}) => TextOrientation(
    quarterTurns: ((horizontally ? 0 : 2) - quarterTurns) % 4,
    mirrored: !mirrored,
  );

  Layer apply(Layer layer) {
    var oriented = mirrored
        ? Layer.mirrored(layer: layer, horizontally: true)
        : layer;
    for (var turn = 0; turn < quarterTurns; turn++) {
      oriented = Layer.rotated(layer: oriented, clockwise: true);
    }
    return oriented;
  }

  @override
  bool operator ==(Object other) =>
      other is TextOrientation &&
      other.quarterTurns == quarterTurns &&
      other.mirrored == mirrored;

  @override
  int get hashCode => Object.hash(quarterTurns, mirrored);

  @override
  String toString() =>
      'TextOrientation(quarter turns: $quarterTurns, mirrored: $mirrored)';
}
