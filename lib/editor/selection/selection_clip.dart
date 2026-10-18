import '../canvas/layer.dart';

class SelectionClip {
  const SelectionClip({required this.image, this.frames});

  final Layer image;
  final Map<int, Layer>? frames;
}
