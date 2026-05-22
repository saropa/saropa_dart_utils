import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/parse_bool_utils.dart';

void main() {
  group('parseBool', () {
    test('true', () => expect(parseBool('true'), isTrue));
    test('1', () => expect(parseBool('1'), isTrue));
    test('yes', () => expect(parseBool('yes'), isTrue));
    test('on', () => expect(parseBool('on'), isTrue));

    test('false', () => expect(parseBool('false'), isFalse));
    test('0', () => expect(parseBool('0'), isFalse));
    test('no', () => expect(parseBool('no'), isFalse));
    test('off', () => expect(parseBool('off'), isFalse));

    test('uppercase normalized', () => expect(parseBool('TRUE'), isTrue));
    test('mixed case normalized', () => expect(parseBool('Yes'), isTrue));
    test('surrounding whitespace trimmed', () => expect(parseBool('  on  '), isTrue));

    test('unknown token returns null', () => expect(parseBool('maybe'), isNull));
    test('empty string returns null', () => expect(parseBool(''), isNull));
    test('numeric other than 0/1 returns null', () => expect(parseBool('2'), isNull));
  });
}
