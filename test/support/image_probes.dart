import 'dart:ui' as ui;

Future<List<List<int>>> imageRows(ui.Image image) async {
  final bytes = (await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  ))!;
  return [
    for (var y = 0; y < image.height; y++)
      [
        for (var x = 0; x < image.width; x++)
          bytes.getUint32((y * image.width + x) * 4) >> 8 |
              bytes.getUint8((y * image.width + x) * 4 + 3) << 24,
      ],
  ];
}

ui.Image blankImage() {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(1, 1);
  picture.dispose();
  return image;
}
