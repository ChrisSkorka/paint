// coverage:ignore-file

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

import 'editor/files/document_library.dart';
import 'editor/files/platform_document_store.dart';
import 'editor/files/selector_file_access.dart';
import 'editor/files/system_image_clipboard.dart';
import 'widgets/views/paint_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    PaintApp(
      clipboard: SystemImageClipboard(clipboard: SystemClipboard.instance),
      files: SelectorFileAccess(
        platform: FileSelectorPlatform.instance,
        web: kIsWeb,
      ),
      library: DocumentLibrary(
        store: await createPlatformDocumentStore(),
        now: DateTime.now,
      ),
    ),
  );
}
