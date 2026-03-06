import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_indent_extensions.dart';

void main() {
  group('indentLines', () {
    test('two lines', () => expect('a\nb'.indentLines('  '), '  a\n  b'));
    test('empty', () => expect(''.indentLines('  '), ''));
  });
  group('dedent', () {
    test('removes common leading', () => expect('  a\n  b'.dedent(), 'a\nb'));
    test('mixed', () => expect('  a\n    b'.dedent(), 'a\n  b'));
  });
}
