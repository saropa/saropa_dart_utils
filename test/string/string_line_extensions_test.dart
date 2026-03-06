import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_line_extensions.dart';

void main() {
  group('normalizeLineBreaks', () {
    test('CRLF to LF', () => expect('a\r\nb'.normalizeLineBreaks(), 'a\nb'));
    test('CR to LF', () => expect('a\rb'.normalizeLineBreaks(), 'a\nb'));
    test('mixed', () => expect('a\r\nb\rc\n'.normalizeLineBreaks(), 'a\nb\nc\n'));
    test('empty', () => expect(''.normalizeLineBreaks(), ''));
    test(
      'empty target throws',
      () => expect(() => 'a'.normalizeLineBreaks(''), throwsArgumentError),
    );
  });

  group('stripBom', () {
    test('with BOM', () => expect('\uFEFFhello'.stripBom(), 'hello'));
    test('without BOM', () => expect('hello'.stripBom(), 'hello'));
    test('empty', () => expect(''.stripBom(), ''));
  });

  group('splitIntoLines', () {
    test('LF', () => expect('a\nb\nc'.splitIntoLines(), ['a', 'b', 'c']));
    test('CRLF', () => expect('a\r\nb'.splitIntoLines(), ['a', 'b']));
    test('empty', () => expect(''.splitIntoLines(), ['']));
  });
}
