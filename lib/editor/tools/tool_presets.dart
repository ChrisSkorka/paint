import 'package:collection/collection.dart';

import 'tool_preset.dart';

class ToolPresets {
  const ToolPresets({this.locked = const [], this.recent = const []});

  factory ToolPresets.limited({
    required List<ToolPreset> locked,
    required List<ToolPreset> recent,
  }) {
    final kept = locked.toSet().take(limit).toList();
    return ToolPresets(
      locked: kept,
      recent: recent
          .toSet()
          .where((preset) => !kept.contains(preset))
          .take(limit - kept.length)
          .toList(),
    );
  }

  static const limit = 9;

  final List<ToolPreset> locked;
  final List<ToolPreset> recent;

  List<ToolPreset> get all => [...locked, ...recent];

  bool isLocked({required int index}) => index < locked.length;

  ToolPresets use(ToolPreset preset) =>
      ToolPresets.limited(locked: locked, recent: [preset, ...recent]);

  ToolPresets lock({required int index}) {
    if (isLocked(index: index) || index >= all.length) return this;
    final preset = recent[index - locked.length];
    return ToolPresets(
      locked: [...locked, preset],
      recent: [...recent]..remove(preset),
    );
  }

  ToolPresets unlock({required int index}) {
    if (!isLocked(index: index)) return this;
    final preset = locked[index];
    return ToolPresets(
      locked: [...locked]..remove(preset),
      recent: [preset, ...recent],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ToolPresets &&
      const ListEquality<ToolPreset>().equals(other.locked, locked) &&
      const ListEquality<ToolPreset>().equals(other.recent, recent);

  @override
  int get hashCode => Object.hash(
    const ListEquality<ToolPreset>().hash(locked),
    const ListEquality<ToolPreset>().hash(recent),
  );

  @override
  String toString() => 'ToolPresets(locked: $locked, recent: $recent)';
}
