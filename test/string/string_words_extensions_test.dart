import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_words_extensions.dart';

void main() {
  group('wordCount', () {
    test('two words', () => expect('hello world'.wordCount(), 2));
    test('trimmed', () => expect('  a  b  '.wordCount(), 2));
    test('empty', () => expect(''.wordCount(), 0));
  });
  group('breakLongWords', () {
    test('insert separator', () {
      expect('hello'.breakLongWords(2, '\u00ad'), 'he\u00adll\u00ado');
    });
    test('charCount 0 throws', () => expect(() => 'a'.breakLongWords(0, '-'), throwsArgumentError));
  });
}
