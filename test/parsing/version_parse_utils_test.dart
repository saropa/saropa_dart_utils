import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/version_parse_utils.dart';

void main() {
  group('parseVersion', () {
    test('dotted version', () => expect(parseVersion('1.2.3'), (1, 2, 3)));
    test('extra segments ignored beyond first three', () {
      expect(parseVersion('1.2.3.4'), (1, 2, 3));
    });
    test('space-separated also splits', () => expect(parseVersion('1 2 3'), (1, 2, 3)));
    test('surrounding whitespace trimmed', () => expect(parseVersion('  4.5.6  '), (4, 5, 6)));
    test('zero components', () => expect(parseVersion('0.0.0'), (0, 0, 0)));
    test('too few components returns null', () => expect(parseVersion('1.2'), isNull));
    test('non-numeric component returns null', () => expect(parseVersion('1.x.3'), isNull));
    test('empty string returns null', () => expect(parseVersion(''), isNull));
    test('leading v not stripped returns null', () => expect(parseVersion('v1.2.3'), isNull));
  });
}
