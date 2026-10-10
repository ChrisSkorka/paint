import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/files/image_codec.dart';
import 'package:paint/editor/files/system_image_clipboard.dart';
import 'package:super_clipboard/super_clipboard.dart';

import '../../../support/layer_probes.dart';
import '../../../support/stub_system_clipboard.dart';

void main() {
  const red = 0xFFFF0000;
  const white = 0xFFFFFFFF;

  final stubImage = layerFromRows([
    [red, white],
  ]);
  final stubPng = ImageCodec.encodePng(layer: stubImage);

  group('class SystemImageClipboard', () {
    group('method write', () {
      group('clipboard', () {
        test('available', () async {
          final stubClipboard = StubSystemClipboard(
            reader: StubClipboardReader(),
          );
          final systemImageClipboard = SystemImageClipboard(
            clipboard: stubClipboard,
          );
          await systemImageClipboard.write(stubImage);
          final written = ImageCodec.decode(
            bytes: writtenBytes(stubClipboard.written.single),
          )!;
          final actual = pixelRows(written);
          final expected = [
            [red, white],
          ];
          expect(actual, equals(expected));
        });
        test('unavailable', () async {
          const systemImageClipboard = SystemImageClipboard(clipboard: null);
          Future<void> event() => systemImageClipboard.write(stubImage);
          expect(event(), completes);
        });
      });
    });

    group('method read', () {
      group('formats', () {
        test('png', () async {
          final systemImageClipboard = SystemImageClipboard(
            clipboard: StubSystemClipboard(
              reader: StubClipboardReader(files: {Formats.png: stubPng}),
            ),
          );
          final image = await systemImageClipboard.read();
          final actual = pixelRows(image!);
          final expected = [
            [red, white],
          ];
          expect(actual, equals(expected));
        });
        test('bmp', () async {
          final systemImageClipboard = SystemImageClipboard(
            clipboard: StubSystemClipboard(
              reader: StubClipboardReader(files: {Formats.bmp: stubPng}),
            ),
          );
          final image = await systemImageClipboard.read();
          final actual = pixelRows(image!);
          final expected = [
            [red, white],
          ];
          expect(actual, equals(expected));
        });
        test('no image', () async {
          final systemImageClipboard = SystemImageClipboard(
            clipboard: StubSystemClipboard(reader: StubClipboardReader()),
          );
          final actual = await systemImageClipboard.read();
          const expected = null;
          expect(actual, equals(expected));
        });
      });
      group('failures', () {
        test('unavailable', () async {
          const systemImageClipboard = SystemImageClipboard(clipboard: null);
          final actual = await systemImageClipboard.read();
          const expected = null;
          expect(actual, equals(expected));
        });
        test('no progress', () async {
          final systemImageClipboard = SystemImageClipboard(
            clipboard: StubSystemClipboard(
              reader: StubClipboardReader(
                files: {Formats.png: stubPng},
                providesProgress: false,
              ),
            ),
          );
          final actual = await systemImageClipboard.read();
          const expected = null;
          expect(actual, equals(expected));
        });
        test('read error', () async {
          final systemImageClipboard = SystemImageClipboard(
            clipboard: StubSystemClipboard(
              reader: StubClipboardReader(
                files: {Formats.png: stubPng},
                error: StateError('read failed'),
              ),
            ),
          );
          final actual = await systemImageClipboard.read();
          const expected = null;
          expect(actual, equals(expected));
        });
        test('undecodable', () async {
          final systemImageClipboard = SystemImageClipboard(
            clipboard: StubSystemClipboard(
              reader: StubClipboardReader(files: {Formats.png: Uint8List(64)}),
            ),
          );
          final actual = await systemImageClipboard.read();
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });
  });
}
