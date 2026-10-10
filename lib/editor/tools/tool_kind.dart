enum ToolKind {
  pen(label: 'Pen'),
  eraser(label: 'Eraser'),
  bucketFill(label: 'Fill'),
  line(label: 'Line'),
  rectangle(label: 'Rectangle'),
  circle(label: 'Circle'),
  arrow(label: 'Arrow'),
  colorPicker(label: 'Color picker');

  const ToolKind({required this.label});

  final String label;
}
