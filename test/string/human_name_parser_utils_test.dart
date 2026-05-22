import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/human_name_parser_utils.dart';

void main() {
  // cspell: disable
  group('HumanNameParserUtils', () {
    test('constructor should default all parts to null', () {
      const HumanNameParserUtils name = HumanNameParserUtils();
      expect(name.first, isNull);
      expect(name.middle, isNull);
      expect(name.last, isNull);
      expect(name.suffix, isNull);
    });

    test('constructor should store provided parts', () {
      const HumanNameParserUtils name = HumanNameParserUtils(
        first: 'John',
        middle: 'Q',
        last: 'Public',
        suffix: 'Jr.',
      );
      expect(name.first, 'John');
      expect(name.middle, 'Q');
      expect(name.last, 'Public');
      expect(name.suffix, 'Jr.');
    });

    test('toString should render present parts', () {
      const HumanNameParserUtils name = HumanNameParserUtils(first: 'John', last: 'Public');
      expect(name.toString(), 'HumanNameParserUtils(first: John, middle: , last: Public, suffix: )');
    });
  });

  group('parseHumanName', () {
    test('should parse First Last order', () {
      final HumanNameParserUtils name = parseHumanName('John Public');
      expect(name.first, 'John');
      expect(name.last, 'Public');
      expect(name.middle, isNull);
      expect(name.suffix, isNull);
    });

    test('should parse First Middle Last with middle joined', () {
      final HumanNameParserUtils name = parseHumanName('John Quincy Adams');
      expect(name.first, 'John');
      expect(name.middle, 'Quincy');
      expect(name.last, 'Adams');
    });

    test('should join multiple middle names', () {
      final HumanNameParserUtils name = parseHumanName('John A B Adams');
      expect(name.first, 'John');
      expect(name.middle, 'A B');
      expect(name.last, 'Adams');
    });

    test('should parse Last, First order', () {
      final HumanNameParserUtils name = parseHumanName('Public, John');
      expect(name.last, 'Public');
      expect(name.first, 'John');
    });

    test('should detect a trailing suffix', () {
      final HumanNameParserUtils name = parseHumanName('John Public Jr.');
      expect(name.first, 'John');
      expect(name.last, 'Public');
      expect(name.suffix, 'Jr.');
    });

    test('should detect a Roman-numeral suffix', () {
      final HumanNameParserUtils name = parseHumanName('Henry Tudor III');
      expect(name.first, 'Henry');
      expect(name.last, 'Tudor');
      expect(name.suffix, 'III');
    });

    test('should treat a single token as first name only', () {
      final HumanNameParserUtils name = parseHumanName('Cher');
      expect(name.first, 'Cher');
      expect(name.last, isNull);
      expect(name.middle, isNull);
    });

    test('should return all-null parts for empty input', () {
      final HumanNameParserUtils name = parseHumanName('');
      expect(name.first, isNull);
      expect(name.last, isNull);
    });

    test('should trim surrounding whitespace before parsing', () {
      final HumanNameParserUtils name = parseHumanName('  John Public  ');
      expect(name.first, 'John');
      expect(name.last, 'Public');
    });
  });
}
