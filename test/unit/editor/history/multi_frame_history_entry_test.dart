import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/layer.dart';
import 'package:paint/editor/canvas/pixel_color.dart';
import 'package:paint/editor/history/multi_frame_history_entry.dart';

import '../../../support/document_probes.dart';
import '../../../support/history_entries.dart';

void main() {
  const transparent = 0x00000000;

  group('class MultiFrameHistoryEntry', () {
    group('getter name', () {
      group('entries', () {
        test('first entry', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [
              pixelEntry(name: 'Paste', x: 0, before: 0, after: 1),
              pixelEntry(
                name: 'Paste',
                x: 0,
                before: 0,
                after: 1,
                frameIndex: 1,
              ),
            ],
          );
          final actual = multiFrameHistoryEntry.name;
          const expected = 'Paste';
          expect(actual, equals(expected));
        });
      });
    });

    group('getter thumbnail', () {
      group('entries', () {
        test('first entry', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final actual = multiFrameHistoryEntry.thumbnail;
          final expected = Layer.filled(
            width: 1,
            height: 1,
            color: PixelColor.transparent,
          );
          expect(actual, equals(expected));
        });
      });
    });

    group('getter outline', () {
      group('entries', () {
        test('first entry', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final actual = multiFrameHistoryEntry.outline;
          const expected = Rect.zero;
          expect(actual, equals(expected));
        });
      });
    });

    group('method undo', () {
      group('frames', () {
        test('all frames', () {
          final document = filmDocument(
            frames: [
              [
                [transparent],
              ],
              [
                [transparent],
              ],
            ],
            activeFrameIndex: 0,
          );
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [
              pixelEntry(name: 'Paste', x: 0, before: 1, after: 2),
              pixelEntry(
                name: 'Paste',
                x: 0,
                before: 3,
                after: 4,
                frameIndex: 1,
              ),
            ],
          );
          multiFrameHistoryEntry.undo(document);
          final actual = framePixelRows(document);
          const expected = [
            [
              [0x01010101],
            ],
            [
              [0x03030303],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('method redo', () {
      group('frames', () {
        test('all frames', () {
          final document = filmDocument(
            frames: [
              [
                [transparent],
              ],
              [
                [transparent],
              ],
            ],
            activeFrameIndex: 0,
          );
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [
              pixelEntry(name: 'Paste', x: 0, before: 1, after: 2),
              pixelEntry(
                name: 'Paste',
                x: 0,
                before: 3,
                after: 4,
                frameIndex: 1,
              ),
            ],
          );
          multiFrameHistoryEntry.redo(document);
          final actual = framePixelRows(document);
          const expected = [
            [
              [0x02020202],
            ],
            [
              [0x04040404],
            ],
          ];
          expect(actual, equals(expected));
        });
      });
    });

    group('operator ==', () {
      group('equals', () {
        test('same entries', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final other = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final actual = multiFrameHistoryEntry == other;
          const expected = true;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different entries', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final other = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 2)],
          );
          final actual = multiFrameHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
        test('other type', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final Object other = pixelEntry(
            name: 'Paste',
            x: 0,
            before: 0,
            after: 1,
          );
          final actual = multiFrameHistoryEntry == other;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('getter hashCode', () {
      group('equals', () {
        test('same entries', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final other = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final actual = multiFrameHistoryEntry.hashCode;
          final expected = other.hashCode;
          expect(actual, equals(expected));
        });
      });
      group('not equals', () {
        test('different entries', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 1)],
          );
          final other = MultiFrameHistoryEntry(
            entries: [pixelEntry(name: 'Paste', x: 0, before: 0, after: 2)],
          );
          final actual = multiFrameHistoryEntry.hashCode == other.hashCode;
          const expected = false;
          expect(actual, equals(expected));
        });
      });
    });

    group('method toString', () {
      group('format', () {
        test('name and frames', () {
          final multiFrameHistoryEntry = MultiFrameHistoryEntry(
            entries: [
              pixelEntry(name: 'Paste', x: 0, before: 0, after: 1),
              pixelEntry(
                name: 'Paste',
                x: 0,
                before: 0,
                after: 1,
                frameIndex: 1,
              ),
            ],
          );
          final actual = multiFrameHistoryEntry.toString();
          const expected = 'MultiFrameHistoryEntry(Paste, frames: 2)';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
