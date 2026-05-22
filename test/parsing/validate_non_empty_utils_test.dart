import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/validate_non_empty_utils.dart';

void main() {
  group('isNonEmptyAfterTrim', () {
    test('content present is true', () => expect(isNonEmptyAfterTrim(' a '), isTrue));
    test('non-trimmed content true', () => expect(isNonEmptyAfterTrim('hello'), isTrue));
    test('spaces only is false', () => expect(isNonEmptyAfterTrim('   '), isFalse));
    test('empty string is false', () => expect(isNonEmptyAfterTrim(''), isFalse));
    test('null is false', () => expect(isNonEmptyAfterTrim(null), isFalse));
    test('tabs and newlines only is false', () => expect(isNonEmptyAfterTrim('\t\n'), isFalse));
  });
}
