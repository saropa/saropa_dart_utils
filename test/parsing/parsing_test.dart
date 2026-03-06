import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/csv_parse_utils.dart';
import 'package:saropa_dart_utils/parsing/email_validation_utils.dart';
import 'package:saropa_dart_utils/parsing/hex_color_utils.dart';
import 'package:saropa_dart_utils/parsing/luhn_utils.dart';
import 'package:saropa_dart_utils/parsing/parse_bool_utils.dart';
import 'package:saropa_dart_utils/parsing/semver_utils.dart';
import 'package:saropa_dart_utils/parsing/size_parse_utils.dart';
import 'package:saropa_dart_utils/parsing/validate_non_empty_utils.dart';
import 'package:saropa_dart_utils/parsing/version_parse_utils.dart';

void main() {
  group('parseCsvLine', () {
    test('simple', () => expect(parseCsvLine('a,b,c'), <String>['a', 'b', 'c']));
    test('quoted', () => expect(parseCsvLine('"a,b",c'), <String>['a,b', 'c']));
  });
  group('isValidEmail', () {
    test('valid', () => expect(isValidEmail('u@h.com'), isTrue));
    test('invalid', () => expect(isValidEmail(''), isFalse));
  });
  group('parseSizeToBytes', () {
    test('1.5 MB', () => expect(parseSizeToBytes('1.5 MB'), 1572864));
  });
  group('formatBytesToHuman', () {
    test('1024', () => expect(formatBytesToHuman(1024), '1 KB'));
  });
  group('luhnCheck', () {
    test('valid', () => expect(luhnCheck('4532015112830366'), isTrue));
  });
  group('parseBool', () {
    test('yes', () => expect(parseBool('yes'), isTrue));
    test('no', () => expect(parseBool('no'), isFalse));
  });
  group('SemVer.parse', () {
    test('1.2.3', () {
      final SemVer? v = SemVer.parse('1.2.3');
      expect(v != null, isTrue);
      expect(v!.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
    });
  });
  group('parseVersion', () {
    test('1.2.3', () => expect(parseVersion('1.2.3'), (1, 2, 3)));
  });
  group('parseHexColor', () {
    test('#FFF', () => expect(parseHexColor('#FFF'), 0xFFFFFFFF));
  });
  group('isNonEmptyAfterTrim', () {
    test('spaces only', () => expect(isNonEmptyAfterTrim('   '), isFalse));
    test('has content', () => expect(isNonEmptyAfterTrim(' a '), isTrue));
  });
}
