import '../canvas/layer.dart';

abstract interface class ImageClipboard {
  Future<void> write(Layer image);
  Future<Layer?> read();
}
