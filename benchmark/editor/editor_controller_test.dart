import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/canvas/document.dart';
import 'package:paint/editor/canvas/pixel_point.dart';
import 'package:paint/editor/editor_controller.dart';
import 'package:paint/editor/pointer_button.dart';

import '../support/samples.dart';

const _timeout = Timeout(Duration(minutes: 5));

EditorController _controller({required int size}) =>
    EditorController.forDocument(
      document: Document.blank(width: size, height: size),
    );

PixelPoint _point(int index) => PixelPoint(x: 5 + index * 2, y: 5 + index);

void main() {
  group('class EditorController', () {
    for (final size in canvasSizes) {
      group('method pointerMove', () {
        group('${size}x$size canvas', () {
          test('hover', timeout: _timeout, () {
            final editorController = _controller(size: size);
            final samples = [
              for (var index = 0; index < frameSampleCount; index++)
                measureSync(
                  () => editorController.pointerMove(point: _point(index)),
                ),
            ];
            report(name: 'EditorController $size hover', samples: samples);
          });

          test('stroke', timeout: _timeout, () {
            final editorController = _controller(size: size);
            editorController.pointerDown(
              point: _point(0),
              button: PointerButton.primary,
            );
            final samples = [
              for (var index = 1; index <= frameSampleCount; index++)
                measureSync(
                  () => editorController.pointerMove(point: _point(index)),
                ),
            ];
            report(
              name: 'EditorController $size stroke move',
              samples: samples,
            );
          });
        });
      });

      group('method pointerDown', () {
        group('${size}x$size canvas', () {
          test('stroke start', timeout: _timeout, () {
            final editorController = _controller(size: size);
            final samples = <Duration>[];
            for (var index = 0; index < strokeSampleCount; index++) {
              samples.add(
                measureSync(
                  () => editorController.pointerDown(
                    point: _point(index),
                    button: PointerButton.primary,
                  ),
                ),
              );
              editorController.pointerUp(point: _point(index));
            }
            report(
              name: 'EditorController $size stroke start',
              samples: samples,
            );
          });
        });
      });

      group('method pointerUp', () {
        group('${size}x$size canvas', () {
          test('stroke end', timeout: _timeout, () {
            final editorController = _controller(size: size);
            final samples = <Duration>[];
            for (var index = 0; index < strokeSampleCount; index++) {
              editorController.pointerDown(
                point: _point(index),
                button: PointerButton.primary,
              );
              samples.add(
                measureSync(
                  () => editorController.pointerUp(point: _point(index)),
                ),
              );
            }
            report(name: 'EditorController $size stroke end', samples: samples);
          });
        });
      });
    }
  });
}
