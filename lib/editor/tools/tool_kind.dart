enum ToolKind {
  pen(label: 'Pen', usesColor: true, hasSize: true, presettable: true),
  eraser(label: 'Eraser', usesColor: false, hasSize: true, presettable: true),
  bucketFill(label: 'Fill', usesColor: true, hasSize: false, presettable: true),
  line(label: 'Line', usesColor: true, hasSize: true, presettable: true),
  rectangle(
    label: 'Rectangle',
    usesColor: true,
    hasSize: true,
    presettable: true,
  ),
  circle(label: 'Circle', usesColor: true, hasSize: true, presettable: true),
  arrow(label: 'Arrow', usesColor: true, hasSize: true, presettable: true),
  colorPicker(
    label: 'Color picker',
    usesColor: false,
    hasSize: false,
    presettable: false,
  ),
  select(label: 'Select', usesColor: false, hasSize: false, presettable: false);

  const ToolKind({
    required this.label,
    required this.usesColor,
    required this.hasSize,
    required this.presettable,
  });

  final String label;
  final bool usesColor;
  final bool hasSize;
  final bool presettable;
}
