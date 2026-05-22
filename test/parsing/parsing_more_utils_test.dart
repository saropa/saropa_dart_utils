import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/parsing_more_utils.dart';

void main() {
  group('parseIntBase', () {
    test('binary', () => expect(parseIntBase('1010', 2), 10));
    test('hex', () => expect(parseIntBase('ff', 16), 255));
    test('decimal', () => expect(parseIntBase('42', 10), 42));
    test('base 36', () => expect(parseIntBase('z', 36), 35));
    test('radix below 2 returns null', () => expect(parseIntBase('1', 1), isNull));
    test('radix above 36 returns null', () => expect(parseIntBase('1', 37), isNull));
    test('invalid digits for radix returns null', () => expect(parseIntBase('2', 2), isNull));
    test('non-numeric returns null', () => expect(parseIntBase('xyz', 10), isNull));
  });

  group('isValidUrlLoose', () {
    test('http valid', () => expect(isValidUrlLoose('http://example.com'), isTrue));
    test('https valid', () => expect(isValidUrlLoose('https://example.com'), isTrue));
    test('uppercase scheme valid', () => expect(isValidUrlLoose('HTTPS://example.com'), isTrue));
    test('ftp invalid', () => expect(isValidUrlLoose('ftp://example.com'), isFalse));
    test('no scheme invalid', () => expect(isValidUrlLoose('example.com'), isFalse));
    test('empty invalid', () => expect(isValidUrlLoose(''), isFalse));
    test('scheme not at start invalid', () => expect(isValidUrlLoose('x http://y'), isFalse));
  });

  group('isValidIpv4', () {
    test('valid address', () => expect(isValidIpv4('192.168.0.1'), isTrue));
    test('all zeros valid', () => expect(isValidIpv4('0.0.0.0'), isTrue));
    test('max octets valid', () => expect(isValidIpv4('255.255.255.255'), isTrue));
    test('octet over 255 invalid', () => expect(isValidIpv4('256.0.0.1'), isFalse));
    test('too few parts invalid', () => expect(isValidIpv4('1.2.3'), isFalse));
    test('too many parts invalid', () => expect(isValidIpv4('1.2.3.4.5'), isFalse));
    test('non-numeric octet invalid', () => expect(isValidIpv4('1.2.x.4'), isFalse));
    test('empty invalid', () => expect(isValidIpv4(''), isFalse));
    test('negative octet invalid', () => expect(isValidIpv4('1.-2.3.4'), isFalse));
  });

  group('parsePortFromHostPort', () {
    test('host with port', () => expect(parsePortFromHostPort('example.com:8080'), 8080));
    test('no colon returns null', () => expect(parsePortFromHostPort('example.com'), isNull));
    test('non-numeric port returns null', () => expect(parsePortFromHostPort('host:abc'), isNull));
    test('splits on last colon', () => expect(parsePortFromHostPort('a:b:1234'), 1234));
    test('empty port returns null', () => expect(parsePortFromHostPort('host:'), isNull));
  });

  group('parseKeyValueLines', () {
    test('basic key value lines', () {
      expect(parseKeyValueLines('a=1\nb=2'), <String, String>{'a': '1', 'b': '2'});
    });
    test('whitespace trimmed around key and value', () {
      expect(parseKeyValueLines('a = 1'), <String, String>{'a': '1'});
    });
    test('comment lines skipped', () {
      expect(parseKeyValueLines('a=1\n# note\nb=2'), <String, String>{'a': '1', 'b': '2'});
    });
    test('blank lines skipped', () {
      expect(parseKeyValueLines('a=1\n\nb=2'), <String, String>{'a': '1', 'b': '2'});
    });
    test('line without separator skipped', () {
      expect(parseKeyValueLines('a=1\nnope\nb=2'), <String, String>{'a': '1', 'b': '2'});
    });
    test('later duplicate key wins', () {
      expect(parseKeyValueLines('a=1\na=2'), <String, String>{'a': '2'});
    });
    test('value containing separator keeps remainder', () {
      expect(parseKeyValueLines('a=1=2'), <String, String>{'a': '1=2'});
    });
    test('custom separator', () {
      expect(parseKeyValueLines('a:1', separator: ':'), <String, String>{'a': '1'});
    });
    test('empty input yields empty map', () {
      expect(parseKeyValueLines(''), <String, String>{});
    });
  });

  group('isValidHexString', () {
    test('mixed case hex valid', () => expect(isValidHexString('1aF'), isTrue));
    test('all decimal digits valid', () => expect(isValidHexString('1234'), isTrue));
    test('non-hex letter invalid', () => expect(isValidHexString('1g'), isFalse));
    test('empty string invalid', () => expect(isValidHexString(''), isFalse));
    test('length match valid', () => expect(isValidHexString('ab', length: 2), isTrue));
    test('length mismatch invalid', () => expect(isValidHexString('1aF', length: 2), isFalse));
  });

  group('parseDottedDecimal', () {
    test('all numeric segments', () => expect(parseDottedDecimal('1.20.3'), <int>[1, 20, 3]));
    test('non-numeric segments dropped', () => expect(parseDottedDecimal('1.x.3'), <int>[1, 3]));
    test('single number', () => expect(parseDottedDecimal('42'), <int>[42]));
    test('empty string yields empty list', () => expect(parseDottedDecimal(''), <int>[]));
    test('all non-numeric yields empty list', () => expect(parseDottedDecimal('a.b.c'), <int>[]));
  });
}
