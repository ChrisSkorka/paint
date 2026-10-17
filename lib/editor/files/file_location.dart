final _separator = RegExp(r'[/\\]');

String? directoryOf({required String path}) {
  final index = path.lastIndexOf(_separator);
  return index < 0 ? null : path.substring(0, index + 1);
}

String fileNameOf({required String path}) =>
    path.substring(path.lastIndexOf(_separator) + 1);
