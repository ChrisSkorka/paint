// ignore_for_file: avoid_print

const canvasSizes = [512, 1024, 2048, 4096];
const frameSampleCount = 10;
const strokeSampleCount = 5;

Future<Duration> measure(Future<void> Function() action) async {
  final stopwatch = Stopwatch()..start();
  await action();
  return stopwatch.elapsed;
}

Duration measureSync(void Function() action) {
  final stopwatch = Stopwatch()..start();
  action();
  return stopwatch.elapsed;
}

void report({required String name, required List<Duration> samples}) {
  final milliseconds = [
    for (final sample in samples) sample.inMicroseconds / 1000,
  ]..sort();
  final median = milliseconds[milliseconds.length ~/ 2];
  final mean =
      milliseconds.reduce((sum, value) => sum + value) / milliseconds.length;
  final perSecond = median == 0 ? double.infinity : 1000 / median;
  print(
    'BENCHMARK ${name.padRight(48)} '
    'median ${median.toStringAsFixed(2).padLeft(9)} ms  '
    'mean ${mean.toStringAsFixed(2).padLeft(9)} ms  '
    'min ${milliseconds.first.toStringAsFixed(2).padLeft(9)} ms  '
    'max ${milliseconds.last.toStringAsFixed(2).padLeft(9)} ms  '
    '${perSecond.toStringAsFixed(1).padLeft(8)} /s  '
    '(n=${milliseconds.length})',
  );
}
