import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/string_diff_utils.dart';

void main() {
  group('stringDiffLines', () {
    test('reports the single changed line with - and + entries', () {
      expect(
        stringDiffLines('a\nb\nc', 'a\nx\nc'),
        <String>['2: - b', '2: + x'],
      );
    });

    test('identical strings produce no diff', () {
      expect(stringDiffLines('same\ntext', 'same\ntext'), isEmpty);
    });

    test('extra line in b is shown as an addition', () {
      // 'a' has no second line; b's second line is 'b'.
      expect(stringDiffLines('a', 'a\nb'), <String>['2: - ', '2: + b']);
    });

    test('removed line in a is shown', () {
      expect(stringDiffLines('a\nb', 'a'), <String>['2: - b', '2: + ']);
    });

    test('multiple changed lines', () {
      expect(
        stringDiffLines('1\n2\n3', '1\nX\nY'),
        <String>['2: - 2', '2: + X', '3: - 3', '3: + Y'],
      );
    });

    test('both empty produce no diff', () {
      expect(stringDiffLines('', ''), isEmpty);
    });
  });
}
