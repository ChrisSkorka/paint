import 'dart:math';

int zoomStep(int magnitude) =>
    magnitude < 4 ? 1 : 1 << (log(magnitude) / ln2).floor() - 1;

int _largerMagnitude(int magnitude) {
  final step = zoomStep(magnitude);
  return (magnitude ~/ step + 1) * step;
}

int _smallerMagnitude(int magnitude) {
  final step = zoomStep(magnitude - 1);
  return (magnitude - 1) ~/ step * step;
}

class Zoom {
  const Zoom({required this.factor});

  factory Zoom.nearest({required double scale}) => Zoom(
    factor: scale >= 1 ? scale.round() : -(1 / scale).round(),
  ).normalized;

  factory Zoom.fitting({required double scale}) => Zoom(
    factor: switch (scale) {
      >= 1 => scale.floor(),
      > 0 => -(1 / scale).ceil(),
      _ => minimum.factor,
    }.clamp(minimum.factor, maximum.factor),
  );

  final int factor;

  static const minimum = Zoom(factor: -96);
  static const maximum = Zoom(factor: 96);
  static const standard = Zoom(factor: 4);

  static Zoom? tryParse(String text) => switch (text.split('/')) {
    ['1', final divisor] => switch (int.tryParse(divisor)) {
      final reduction? when reduction >= 1 => Zoom(factor: -reduction),
      _ => null,
    },
    [final factor] => switch (int.tryParse(factor)) {
      final factor? => Zoom(factor: factor),
      null => null,
    },
    _ => null,
  };

  String get label => factor <= -2 ? '1/${-factor}' : '$factor';

  Zoom get normalized =>
      factor > -2 && factor < 1 ? const Zoom(factor: 1) : this;

  double get scale => switch (normalized.factor) {
    >= 1 && final magnified => magnified.toDouble(),
    final reduced => 1 / -reduced,
  };

  Zoom stepped({required bool larger}) {
    final current = normalized.factor;
    final next = switch ((current >= 1, larger)) {
      (true, true) => _largerMagnitude(current),
      (true, false) => current == 1 ? -2 : _smallerMagnitude(current),
      (false, true) => current == -2 ? 1 : -_smallerMagnitude(-current),
      (false, false) => -_largerMagnitude(-current),
    };
    return Zoom(factor: next.clamp(minimum.factor, maximum.factor));
  }

  @override
  bool operator ==(Object other) => other is Zoom && other.factor == factor;

  @override
  int get hashCode => factor.hashCode;

  @override
  String toString() => 'Zoom($factor)';
}
