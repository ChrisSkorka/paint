import 'package:flutter/foundation.dart';
import 'package:super_clipboard/super_clipboard.dart';

class StubSystemClipboard implements SystemClipboard {
  StubSystemClipboard({required this.reader});

  final ClipboardReader reader;
  final written = <DataWriterItem>[];

  @override
  Future<void> write(Iterable<DataWriterItem> items) async {
    written.addAll(items);
  }

  @override
  Future<ClipboardReader> read() async => reader;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class StubClipboardReader implements ClipboardReader {
  StubClipboardReader({
    this.files = const {},
    this.providesProgress = true,
    this.error,
  });

  final Map<FileFormat, Uint8List> files;
  final bool providesProgress;
  final Object? error;

  @override
  bool canProvide(DataFormat format) => files.containsKey(format);

  @override
  ReadProgress? getFile(
    FileFormat? format,
    AsyncValueChanged<DataReaderFile> onFile, {
    ValueChanged<Object>? onError,
    bool allowVirtualFiles = true,
    bool synthesizeFilesFromURIs = true,
  }) {
    if (!providesProgress) return null;
    final error = this.error;
    if (error != null) {
      onError?.call(error);
    } else {
      onFile(StubDataReaderFile(bytes: files[format]!));
    }
    return StubReadProgress();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class StubDataReaderFile implements DataReaderFile {
  StubDataReaderFile({required this.bytes});

  final Uint8List bytes;

  @override
  Future<Uint8List> readAll() async => bytes;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class StubReadProgress implements ReadProgress {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Uint8List writtenBytes(DataWriterItem item) =>
    ((item.data.single as EncodedData).representations.single.serialize()
            as Map)['data']
        as Uint8List;
