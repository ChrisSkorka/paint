class PixelColor {
  const PixelColor({required this.argb});

  factory PixelColor.fromChannels({
    required int red,
    required int green,
    required int blue,
    int alpha = 0xff,
  }) {
    return PixelColor(
      argb:
          (alpha & 0xff) << 24 |
          (red & 0xff) << 16 |
          (green & 0xff) << 8 |
          (blue & 0xff),
    );
  }

  factory PixelColor.composited({
    required PixelColor source,
    required PixelColor destination,
  }) {
    final covered = source.alpha * 0xff;
    final remaining = destination.alpha * (0xff - source.alpha);
    final total = covered + remaining;
    if (total == 0) return transparent;
    int channel({required int source, required int destination}) =>
        ((source * covered + destination * remaining) / total).round();
    return PixelColor.fromChannels(
      red: channel(source: source.red, destination: destination.red),
      green: channel(source: source.green, destination: destination.green),
      blue: channel(source: source.blue, destination: destination.blue),
      alpha: (total / 0xff).round(),
    );
  }

  static PixelColor? tryParseHex(String text) {
    final digits = text.startsWith('#') ? text.substring(1) : text;
    if (!_hexDigits.hasMatch(digits)) return null;
    final value = int.parse(digits, radix: 16);
    return switch (digits.length) {
      6 => PixelColor(argb: 0xff000000 | value),
      8 => PixelColor(argb: (value & 0xff) << 24 | value >> 8),
      _ => null,
    };
  }

  static final _hexDigits = RegExp(r'^[0-9a-fA-F]+$');

  static const transparent = PixelColor(argb: 0x00000000);
  static const black = PixelColor(argb: 0xff000000);
  static const white = PixelColor(argb: 0xffffffff);

  final int argb;

  int get alpha => argb >> 24 & 0xff;
  int get red => argb >> 16 & 0xff;
  int get green => argb >> 8 & 0xff;
  int get blue => argb & 0xff;

  String get hex =>
      '#${[red, green, blue, alpha].map((channel) => channel.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  @override
  bool operator ==(Object other) => other is PixelColor && other.argb == argb;

  @override
  int get hashCode => argb.hashCode;

  @override
  String toString() =>
      'PixelColor(0x${argb.toRadixString(16).padLeft(8, '0')})';
}
