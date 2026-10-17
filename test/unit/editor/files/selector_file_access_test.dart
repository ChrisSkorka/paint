import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/files/export_format.dart';
import 'package:paint/editor/files/selector_file_access.dart';

import '../../../support/stub_file_selector_platform.dart';

void main() {
  Directory temporaryDirectory() {
    final directory = Directory.systemTemp.createTempSync('paint_test');
    addTearDown(() => directory.deleteSync(recursive: true));
    return directory;
  }

  group('class SelectorFileAccess', () {
    group('method open', () {
      group('selection', () {
        test('picked', () async {
          final stubPlatform = StubFileSelectorPlatform(
            openedFile: XFile.fromData(
              Uint8List.fromList([1, 2]),
              path: '/pictures/cat.png',
            ),
          );
          final fileAccess = SelectorFileAccess(
            platform: stubPlatform,
            web: false,
          );
          final file = await fileAccess.open();
          final actual = [
            file?.name,
            file?.bytes,
            file?.path,
            stubPlatform.openRequests,
          ];
          final expected = [
            'cat.png',
            [1, 2],
            '/pictures/cat.png',
            [
              [
                ['ora', 'png', 'jpg', 'jpeg', 'gif'],
                null,
              ],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('cancelled', () async {
          final fileAccess = SelectorFileAccess(
            platform: StubFileSelectorPlatform(),
            web: false,
          );
          final actual = await fileAccess.open();
          const expected = null;
          expect(actual, equals(expected));
        });
      });

      group('directory', () {
        test('initial directory', () async {
          final stubPlatform = StubFileSelectorPlatform();
          final fileAccess = SelectorFileAccess(
            platform: stubPlatform,
            web: false,
          );
          await fileAccess.open(directory: '/pictures/');
          final actual = stubPlatform.openRequests;
          final expected = [
            [
              ['ora', 'png', 'jpg', 'jpeg', 'gif'],
              '/pictures/',
            ],
          ];
          expect(actual, equals(expected));
        });
      });

      group('web', () {
        test('picked', () async {
          final fileAccess = SelectorFileAccess(
            platform: StubFileSelectorPlatform(
              openedFile: XFile.fromData(
                Uint8List.fromList([1, 2]),
                path: 'cat.png',
              ),
            ),
            web: true,
          );
          final file = await fileAccess.open();
          final actual = [file?.name, file?.path];
          const expected = ['cat.png', null];
          expect(actual, equals(expected));
        });
      });
    });

    group('method saveAs', () {
      group('desktop', () {
        test('location chosen', () async {
          final directory = temporaryDirectory();
          final stubPlatform = StubFileSelectorPlatform(
            saveLocation: FileSaveLocation('${directory.path}/dog.png'),
          );
          final fileAccess = SelectorFileAccess(
            platform: stubPlatform,
            web: false,
          );
          final path = await fileAccess.saveAs(
            fileName: 'cat.png',
            directory: '/pictures/',
            format: ExportFormat.png,
            bytes: Uint8List.fromList([1, 2]),
          );
          final actual = [
            path,
            File('${directory.path}/dog.png').readAsBytesSync(),
            stubPlatform.saveRequests,
          ];
          final expected = [
            '${directory.path}/dog.png',
            [1, 2],
            [
              [
                'PNG',
                ['png'],
                'cat.png',
                '/pictures/',
              ],
            ],
          ];
          expect(actual, equals(expected));
        });
        test('missing extension', () async {
          final directory = temporaryDirectory();
          final fileAccess = SelectorFileAccess(
            platform: StubFileSelectorPlatform(
              saveLocation: FileSaveLocation('${directory.path}/dog'),
            ),
            web: false,
          );
          final path = await fileAccess.saveAs(
            fileName: 'cat.jpg',
            directory: null,
            format: ExportFormat.jpg,
            bytes: Uint8List.fromList([1, 2]),
          );
          final actual = [
            path,
            directory
                .listSync()
                .map((entity) => entity.uri.pathSegments.last)
                .toList(),
          ];
          final expected = [
            '${directory.path}/dog.jpg',
            ['dog.jpg'],
          ];
          expect(actual, equals(expected));
        });
        test('uppercase extension', () async {
          final directory = temporaryDirectory();
          final fileAccess = SelectorFileAccess(
            platform: StubFileSelectorPlatform(
              saveLocation: FileSaveLocation('${directory.path}/dog.JPG'),
            ),
            web: false,
          );
          await fileAccess.saveAs(
            fileName: 'cat.jpg',
            directory: null,
            format: ExportFormat.jpg,
            bytes: Uint8List.fromList([1, 2]),
          );
          final actual = directory
              .listSync()
              .map((entity) => entity.uri.pathSegments.last)
              .toList();
          const expected = ['dog.JPG'];
          expect(actual, equals(expected));
        });
        test('cancelled', () async {
          final directory = temporaryDirectory();
          final fileAccess = SelectorFileAccess(
            platform: StubFileSelectorPlatform(),
            web: false,
          );
          final path = await fileAccess.saveAs(
            fileName: '${directory.path}/cat.png',
            directory: null,
            format: ExportFormat.png,
            bytes: Uint8List.fromList([1, 2]),
          );
          final actual = [path, directory.listSync()];
          const expected = [null, <FileSystemEntity>[]];
          expect(actual, equals(expected));
        });
      });

      group('web', () {
        test('download', () async {
          final directory = temporaryDirectory();
          final stubPlatform = StubFileSelectorPlatform();
          final fileAccess = SelectorFileAccess(
            platform: stubPlatform,
            web: true,
          );
          final path = await fileAccess.saveAs(
            fileName: '${directory.path}/cat.png',
            directory: '/pictures/',
            format: ExportFormat.png,
            bytes: Uint8List.fromList([1, 2]),
          );
          final actual = [
            path,
            File('${directory.path}/cat.png').readAsBytesSync(),
            stubPlatform.saveRequests,
          ];
          final expected = [
            null,
            [1, 2],
            [],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method overwrite', () {
      group('desktop', () {
        test('existing file', () async {
          final directory = temporaryDirectory();
          final file = File('${directory.path}/cat.png')..writeAsBytesSync([9]);
          final stubPlatform = StubFileSelectorPlatform();
          final fileAccess = SelectorFileAccess(
            platform: stubPlatform,
            web: false,
          );
          await fileAccess.overwrite(
            path: file.path,
            format: ExportFormat.png,
            bytes: Uint8List.fromList([1, 2]),
          );
          final actual = [file.readAsBytesSync(), stubPlatform.saveRequests];
          final expected = [
            [1, 2],
            [],
          ];
          expect(actual, equals(expected));
        });
      });
    });
  });
}
