import 'package:paint/editor/selection/selection_clip.dart';

import 'layer_probes.dart';

List<Object?> clipRows(SelectionClip? clip) => [
  if (clip case final clip?) ...[
    pixelRows(clip.image),
    clip.frames?.map((offset, image) => MapEntry(offset, pixelRows(image))),
  ],
];
