enum LayerTimeframe {
  constant(label: 'Constant image'),
  perFrame(label: 'Image per frame');

  const LayerTimeframe({required this.label});

  final String label;
}
