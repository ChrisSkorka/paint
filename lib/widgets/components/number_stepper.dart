import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'paint_icon_button.dart';

class NumberStepper extends StatefulWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    required this.onChanged,
    this.editable = true,
  });

  final int value;
  final int minimum;
  final int maximum;
  final String decreaseTooltip;
  final String increaseTooltip;
  final ValueChanged<int> onChanged;
  final bool editable;

  static const valueWidth = 44.0;
  static const fieldPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 8);

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late final textController = TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(NumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    textController.text = '${widget.value}';
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _commit(int value) {
    final clamped = value.clamp(widget.minimum, widget.maximum);
    textController.text = '$clamped';
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  void _submit() => _commit(int.tryParse(textController.text) ?? widget.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PaintIconButton(
          icon: FontAwesomeIcons.minus,
          tooltip: widget.decreaseTooltip,
          onPressed: widget.value > widget.minimum
              ? () => _commit(widget.value - 1)
              : null,
        ),
        SizedBox(
          width: NumberStepper.valueWidth,
          child: widget.editable
              ? TextField(
                  controller: textController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding: NumberStepper.fieldPadding,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (_) => _submit(),
                  onTapOutside: (_) {
                    _submit();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                )
              : Text('${widget.value}', textAlign: TextAlign.center),
        ),
        PaintIconButton(
          icon: FontAwesomeIcons.plus,
          tooltip: widget.increaseTooltip,
          onPressed: widget.value < widget.maximum
              ? () => _commit(widget.value + 1)
              : null,
        ),
      ],
    );
  }
}
