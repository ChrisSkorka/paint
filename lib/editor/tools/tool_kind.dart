enum ToolKind {
  pen(
    label: 'Pen',
    usesColor: true,
    hasSize: true,
    hasTip: true,
    hasFill: false,
    presettable: true,
  ),
  eraser(
    label: 'Eraser',
    usesColor: false,
    hasSize: true,
    hasTip: true,
    hasFill: false,
    presettable: true,
  ),
  bucketFill(
    label: 'Fill',
    usesColor: true,
    hasSize: false,
    hasTip: false,
    hasFill: false,
    presettable: true,
  ),
  line(
    label: 'Line',
    usesColor: true,
    hasSize: true,
    hasTip: true,
    hasFill: false,
    presettable: true,
  ),
  rectangle(
    label: 'Rectangle',
    usesColor: true,
    hasSize: true,
    hasTip: true,
    hasFill: true,
    presettable: true,
  ),
  circle(
    label: 'Circle',
    usesColor: true,
    hasSize: true,
    hasTip: false,
    hasFill: true,
    presettable: true,
  ),
  arrow(
    label: 'Arrow',
    usesColor: true,
    hasSize: true,
    hasTip: true,
    hasFill: false,
    presettable: true,
  ),
  colorPicker(
    label: 'Color picker',
    usesColor: false,
    hasSize: false,
    hasTip: false,
    hasFill: false,
    presettable: false,
  ),
  select(
    label: 'Select',
    usesColor: false,
    hasSize: false,
    hasTip: false,
    hasFill: false,
    presettable: false,
  );

  const ToolKind({
    required this.label,
    required this.usesColor,
    required this.hasSize,
    required this.hasTip,
    required this.hasFill,
    required this.presettable,
  });

  final String label;
  final bool usesColor;
  final bool hasSize;
  final bool hasTip;
  final bool hasFill;
  final bool presettable;
}
