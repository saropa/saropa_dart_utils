import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_highlight_extensions.dart';

void main() {
  test('highlightSubstring', () {
    expect(
      'hello world'.highlightSubstring(substring: 'o', before: '<', after: '>'),
      'hell<o> w<o>rld',
    );
  });
  test('substring empty throws', () {
    expect(
      () => 'a'.highlightSubstring(substring: '', before: '<', after: '>'),
      throwsArgumentError,
    );
  });
}
