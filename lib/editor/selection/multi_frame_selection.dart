import '../canvas/document_layer.dart';
import '../canvas/layer.dart';
import '../canvas/pixel_point.dart';
import '../canvas/pixel_rectangle.dart';
import 'selection.dart';

class MultiFrameSelection {
  const MultiFrameSelection({required this.frames});

  factory MultiFrameSelection.lift({
    required DocumentLayer layer,
    required Iterable<int> frames,
    required PixelRectangle area,
  }) {
    return MultiFrameSelection(
      frames: {
        for (final frame in frames)
          frame: Selection.lift(layer: layer.imageAt(frame), area: area),
      },
    );
  }

  factory MultiFrameSelection.pasted({
    required DocumentLayer layer,
    required Map<int, Layer> contents,
    required PixelPoint at,
  }) {
    return MultiFrameSelection(
      frames: {
        for (final MapEntry(key: frame, value: content) in contents.entries)
          frame: Selection.pasted(
            layer: layer.imageAt(frame),
            content: content,
            at: at,
          ),
      },
    );
  }

  final Map<int, Selection> frames;

  PixelRectangle get area => frames.values.first.area;

  MultiFrameSelection transformed({
    required DocumentLayer layer,
    required Selection Function(Selection selection, Layer image) transform,
  }) {
    return MultiFrameSelection(
      frames: {
        for (final MapEntry(key: frame, value: selection) in frames.entries)
          frame: transform(selection, layer.imageAt(frame)),
      },
    );
  }
}
