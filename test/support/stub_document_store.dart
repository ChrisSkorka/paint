import 'dart:async';
import 'dart:typed_data';

import 'package:paint/editor/files/document_library.dart';
import 'package:paint/editor/files/document_store.dart';
import 'package:paint/editor/files/stored_document.dart';

class StubDocumentStore implements DocumentStore {
  StubDocumentStore({this.saveError, this.holdSaves = false});

  final Exception? saveError;
  final bool holdSaves;
  final pendingSaves = <Completer<void>>[];
  final entries = <String, StoredDocument>{};
  final files = <String, Uint8List>{};

  @override
  Future<List<StoredDocument>> list() async => entries.values.toList();

  @override
  Future<Uint8List?> load({required String id}) async => files[id];

  @override
  Future<void> save({
    required StoredDocument entry,
    required Uint8List bytes,
  }) async {
    if (holdSaves) {
      final completer = Completer<void>();
      pendingSaves.add(completer);
      await completer.future;
    }
    if (saveError case final error?) throw error;
    entries[entry.id] = entry;
    files[entry.id] = bytes;
  }

  @override
  Future<void> delete({required String id}) async {
    entries.remove(id);
    files.remove(id);
  }
}

class StubClock {
  StubClock({required this.start});

  final DateTime start;
  var ticks = 0;

  DateTime call() => start.add(Duration(minutes: ticks++));
}

DocumentLibrary stubDocumentLibrary({DocumentStore? store}) {
  return DocumentLibrary(
    store: store ?? StubDocumentStore(),
    now: StubClock(start: DateTime(2026, 10, 10, 12)).call,
  );
}
