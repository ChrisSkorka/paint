import 'package:flutter_test/flutter_test.dart';
import 'package:paint/editor/files/file_location.dart';

void main() {
  group('standalone', () {
    group('function directoryOf', () {
      group('separators', () {
        test('slash', () {
          final actual = directoryOf(path: '/home/pictures/cat.png');
          const expected = '/home/pictures/';
          expect(actual, equals(expected));
        });
        test('backslash', () {
          final actual = directoryOf(path: r'C:\pictures\cat.png');
          const expected = r'C:\pictures\';
          expect(actual, equals(expected));
        });
        test('root', () {
          final actual = directoryOf(path: '/cat.png');
          const expected = '/';
          expect(actual, equals(expected));
        });
        test('none', () {
          final actual = directoryOf(path: 'cat.png');
          const expected = null;
          expect(actual, equals(expected));
        });
      });
    });

    group('function fileNameOf', () {
      group('separators', () {
        test('slash', () {
          final actual = fileNameOf(path: '/home/pictures/cat.png');
          const expected = 'cat.png';
          expect(actual, equals(expected));
        });
        test('backslash', () {
          final actual = fileNameOf(path: r'C:\pictures\cat.png');
          const expected = 'cat.png';
          expect(actual, equals(expected));
        });
        test('none', () {
          final actual = fileNameOf(path: 'cat.png');
          const expected = 'cat.png';
          expect(actual, equals(expected));
        });
      });
    });
  });
}
