import 'package:collection/collection.dart';

import 'document.dart';

class FrameTiming {
  const FrameTiming({required this.fps, required this.holds});

  factory FrameTiming.fromDurations({required List<int> centiseconds}) {
    final positive = [
      for (final duration in centiseconds)
        duration > 0 ? duration : defaultCentiseconds,
    ];
    final unit = positive.fold(0, (unit, duration) => unit.gcd(duration));
    return FrameTiming(
      fps: (centisecondsPerSecond / unit).round().clamp(
        Document.minimumFps,
        Document.maximumFps,
      ),
      holds: [
        for (final duration in positive)
          (duration / unit).round().clamp(1, Document.maximumHolds),
      ],
    );
  }

  static const centisecondsPerSecond = 100;
  static const millisecondsPerCentisecond = 10;
  static const defaultCentiseconds = 10;

  final int fps;
  final List<int> holds;

  @override
  bool operator ==(Object other) =>
      other is FrameTiming &&
      other.fps == fps &&
      const ListEquality<int>().equals(other.holds, holds);

  @override
  int get hashCode => Object.hash(fps, const ListEquality<int>().hash(holds));

  @override
  String toString() => 'FrameTiming($fps fps, holds: $holds)';
}
