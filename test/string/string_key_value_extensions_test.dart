import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_key_value_extensions.dart';

void main() {
  test('parseKeyValuePairs', () {
    expect('a=1 b=2'.parseKeyValuePairs(), {'a': '1', 'b': '2'});
  });
  test('empty', () => expect(''.parseKeyValuePairs(), <String, String>{}));
}
