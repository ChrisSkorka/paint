import 'tool_preset.dart';

int toolSizeStep(int size) => switch (size) {
  < 50 => 1,
  < 100 => 5,
  < 500 => 10,
  _ => 50,
};

int largerToolSize(int size) {
  final step = toolSizeStep(size);
  return _clamp((size ~/ step + 1) * step);
}

int smallerToolSize(int size) {
  final step = toolSizeStep(size - 1);
  return _clamp((size - 1) ~/ step * step);
}

int roundToolSize(int size) {
  final step = toolSizeStep(size);
  return _clamp((size / step).round() * step);
}

int _clamp(int size) =>
    size.clamp(ToolPreset.minimumSize, ToolPreset.maximumSize);
