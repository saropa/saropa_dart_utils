import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_split_extensions.dart';

void main() {
  test('splitKeepingDelimiter', () {
    expect('a-b-c'.splitKeepingDelimiter('-', includeDelimiters: true), ['a', '-', 'b', '-', 'c']);
  });
  test('empty pattern throws', () {
    expect(() => 'a'.splitKeepingDelimiter('', includeDelimiters: true), throwsArgumentError);
  });
}
