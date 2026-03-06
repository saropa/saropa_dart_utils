import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_wrap_extensions.dart';

void main() {
  group('wordWrap', () {
    test('wraps at space', () {
      expect('hello world'.wordWrap(5), ['hello', 'world']);
    });
    test('under width', () {
      expect('hi'.wordWrap(10), ['hi']);
    });
    test('empty', () {
      expect(''.wordWrap(5), <String>[]);
    });
    test('columnWidth 0 throws', () {
      expect(() => 'a'.wordWrap(0), throwsArgumentError);
    });
  });
  group('truncateAtGrapheme', () {
    test('basic', () {
      expect('hello'.truncateAtGrapheme(3), 'hel');
    });
    test('emoji', () {
      expect('hello👋'.truncateAtGrapheme(5), 'hello');
    });
    test('maxGraphemes negative throws', () {
      expect(() => 'a'.truncateAtGrapheme(-1), throwsArgumentError);
    });
  });
}
