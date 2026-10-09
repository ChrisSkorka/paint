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

  static const transparent = PixelColor(argb: 0x00000000);
  static const black = PixelColor(argb: 0xff000000);
  static const white = PixelColor(argb: 0xffffffff);

  final int argb;

  int get alpha => argb >> 24 & 0xff;
  int get red => argb >> 16 & 0xff;
  int get green => argb >> 8 & 0xff;
  int get blue => argb & 0xff;

  @override
  bool operator ==(Object other) => other is PixelColor && other.argb == argb;

  @override
  int get hashCode => argb.hashCode;

  @override
  String toString() =>
      'PixelColor(0x${argb.toRadixString(16).padLeft(8, '0')})';
}
