import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_ansi_extensions.dart';

void main() {
  test('stripAnsi', () {
    expect('\x1b[31mred\x1b[0m'.stripAnsi(), 'red');
  });
  test('empty', () => expect(''.stripAnsi(), ''));
}
