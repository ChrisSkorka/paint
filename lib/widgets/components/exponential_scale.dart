import 'dart:math';

double exponentialPosition({
  required int value,
  required int minimum,
  required int maximum,
}) => log(value / minimum) / log(maximum / minimum);

int exponentialValue({
  required double position,
  required int minimum,
  required int maximum,
}) => (minimum * pow(maximum / minimum, position)).round().clamp(
  minimum,
  maximum,
);
