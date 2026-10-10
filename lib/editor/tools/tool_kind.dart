enum ToolKind {
  pen(label: 'Pen', usesColor: true),
  eraser(label: 'Eraser', usesColor: false),
  bucketFill(label: 'Fill', usesColor: true),
  line(label: 'Line', usesColor: true),
  rectangle(label: 'Rectangle', usesColor: true),
  circle(label: 'Circle', usesColor: true),
  arrow(label: 'Arrow', usesColor: true),
  colorPicker(label: 'Color picker', usesColor: false),
  select(label: 'Select', usesColor: false);

  const ToolKind({required this.label, required this.usesColor});

  final String label;
  final bool usesColor;
}
