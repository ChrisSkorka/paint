class Zoom {
  const Zoom({required this.step});

  factory Zoom.nearest({required double scale}) =>
      Zoom(step: scale >= 1 ? scale.round() - 1 : 1 - (1 / scale).round());

  factory Zoom.fitting({required double scale}) => Zoom(
    step: switch (scale) {
      >= 1 => scale.floor() - 1,
      > 0 => 1 - (1 / scale).ceil(),
      _ => minimum.step,
    }.clamp(minimum.step, maximum.step),
  );

  final int step;

  static const minimum = Zoom(step: -7);
  static const maximum = Zoom(step: 99);
  static const standard = Zoom(step: 3);

  static Zoom? tryParse(String text) {
    final parts = text.split('/');
    final numbers = parts.map(int.tryParse).toList();
    return switch (numbers) {
      [final factor?] when factor >= 1 => Zoom(step: factor - 1),
      [1, final divisor?] when divisor >= 1 => Zoom(step: 1 - divisor),
      _ => null,
    };
  }

  double get scale => step >= 0 ? step + 1.0 : 1 / (1 - step);

  String get label => step >= 0 ? '${step + 1}' : '1/${1 - step}';

  Zoom stepped({required bool larger}) =>
      Zoom(step: (step + (larger ? 1 : -1)).clamp(minimum.step, maximum.step));

  @override
  bool operator ==(Object other) => other is Zoom && other.step == step;

  @override
  int get hashCode => step.hashCode;

  @override
  String toString() => 'Zoom($label)';
}
