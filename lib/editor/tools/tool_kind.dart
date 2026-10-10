enum ToolKind {
  pen(label: 'Pen'),
  eraser(label: 'Eraser'),
  colorPicker(label: 'Color picker');

  const ToolKind({required this.label});

  final String label;
}
