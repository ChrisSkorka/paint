import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_icon_button.dart';
import 'paint_style.dart';

class NumericValueRange extends StatefulWidget {
  const NumericValueRange({
    super.key,
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
    this.onChangeEnd,
    this.rangeMinimum,
    this.rangeMaximum,
    this.valueToRange = _toDouble,
    this.rangeToValue = _round,
    this.decrement = _decrement,
    this.increment = _increment,
  });

  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onChanged;
  final ValueChanged<int>? onChangeEnd;
  final double? rangeMinimum;
  final double? rangeMaximum;
  final double Function(int value) valueToRange;
  final int Function(double range) rangeToValue;
  final int Function(int value) decrement;
  final int Function(int value) increment;

  static double _toDouble(int value) => value.toDouble();
  static int _round(double range) => range.round();
  static int _decrement(int value) => value - 1;
  static int _increment(int value) => value + 1;

  @override
  State<NumericValueRange> createState() => _NumericValueRangeState();
}

class _NumericValueRangeState extends State<NumericValueRange> {
  late final textController = TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(NumericValueRange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (int.tryParse(textController.text) != widget.value) {
      textController.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _change(int value) {
    final clamped = value.clamp(widget.minimum, widget.maximum);
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  void _end(int value) =>
      widget.onChangeEnd?.call(value.clamp(widget.minimum, widget.maximum));

  void _commit(int value) {
    _change(value);
    _end(value);
  }

  void _submit(String text) {
    final clamped = (int.tryParse(text) ?? widget.value).clamp(
      widget.minimum,
      widget.maximum,
    );
    textController.text = '$clamped';
    _commit(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final rangeMinimum =
        widget.rangeMinimum ?? widget.valueToRange(widget.minimum);
    final rangeMaximum =
        widget.rangeMaximum ?? widget.valueToRange(widget.maximum);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: TextField(
            controller: textController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: _submit,
            onChanged: (text) {
              final value = int.tryParse(text);
              if (value != null &&
                  value >= widget.minimum &&
                  value <= widget.maximum) {
                _change(value);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        PaintIconButton(
          icon: FontAwesomeIcons.minus,
          tooltip: 'Decrease',
          onPressed: widget.value > widget.minimum
              ? () => _commit(widget.decrement(widget.value))
              : null,
        ),
        SizedBox(
          width: 120,
          child: SliderTheme(
            data: PaintStyle.sliderTheme,
            child: Slider(
              value: widget
                  .valueToRange(widget.value)
                  .clamp(rangeMinimum, rangeMaximum),
              min: rangeMinimum,
              max: rangeMaximum,
              onChanged: (range) => _change(widget.rangeToValue(range)),
              onChangeEnd: (range) => _end(widget.rangeToValue(range)),
            ),
          ),
        ),
        PaintIconButton(
          icon: FontAwesomeIcons.plus,
          tooltip: 'Increase',
          onPressed: widget.value < widget.maximum
              ? () => _commit(widget.increment(widget.value))
              : null,
        ),
      ],
    );
  }
}
