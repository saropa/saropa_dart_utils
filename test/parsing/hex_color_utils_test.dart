import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/hex_color_utils.dart';

void main() {
  group('parseHexColor', () {
    test('#FFF expands to opaque white', () => expect(parseHexColor('#FFF'), 0xFFFFFFFF));

    test('#000 expands to opaque black', () => expect(parseHexColor('#000'), 0xFF000000));

    test('#f80 shorthand expands by nibble duplication', () {
      expect(parseHexColor('#f80'), 0xFFFF8800);
    });

    test('6-digit RRGGBB gets opaque alpha prepended', () {
      expect(parseHexColor('#FF8800'), 0xFFFF8800);
    });

    test('6-digit red', () => expect(parseHexColor('#FF0000'), 0xFFFF0000));

    test('8-digit AARRGGBB parsed as-is', () {
      expect(parseHexColor('#80FF0000'), 0x80FF0000);
    });

    test('lowercase hex digits accepted', () => expect(parseHexColor('#abcdef'), 0xFFABCDEF));

    test('surrounding whitespace trimmed', () => expect(parseHexColor('  #FFF  '), 0xFFFFFFFF));

    test('missing hash returns null', () => expect(parseHexColor('FFF'), isNull));

    test('empty string returns null', () => expect(parseHexColor(''), isNull));

    test('hash only returns null', () => expect(parseHexColor('#'), isNull));

    test('invalid length (4 hex digits) returns null', () {
      expect(parseHexColor('#FFFF'), isNull);
    });

    test('non-hex characters stripped, remaining length checked', () {
      // '#GG' -> hex stripped to '' (length 0) -> null.
      expect(parseHexColor('#GG'), isNull);
    });
  });
}
