import '../selection/selection_clip.dart';
import 'image_clipboard.dart';

class FrameClipboard {
  SelectionClip? _clip;

  Future<void> write({
    required ImageClipboard system,
    required SelectionClip clip,
  }) async {
    _clip = clip.frames == null ? null : clip;
    await system.write(clip.image);
  }

  Future<SelectionClip?> read({required ImageClipboard system}) async {
    final image = await system.read();
    if (image == null) return null;
    final clip = _clip;
    if (clip != null && clip.image == image) return clip;
    _clip = null;
    return SelectionClip(image: image);
  }
}
