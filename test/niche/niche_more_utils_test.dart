import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/niche_more_utils.dart';

void main() {
  group('hexDump', () {
    test('one short line: offset, hex column, ASCII gutter', () {
      // 'Hi' = [72, 105] = 0x48 0x69.
      final String dump = hexDump(<int>[72, 105]);
      expect(dump, startsWith('00000000 48 69'));
      expect(dump, contains('Hi'));
      expect(dump, endsWith('\n'));
    });

    test('non-printable bytes render as dots in the ASCII gutter', () {
      // 0x00 and 0x1F are control bytes -> '.' in the gutter.
      final String dump = hexDump(<int>[0, 31]);
      expect(dump, startsWith('00000000 00 1f'));
      expect(dump.trimRight(), endsWith('..'));
    });

    test('respects bytesPerLine producing two lines', () {
      final String dump = hexDump(<int>[1, 2, 3], bytesPerLine: 2);
      final List<String> lines = dump.trimRight().split('\n');
      expect(lines, hasLength(2));
      expect(lines[0], startsWith('00000000 01 02'));
      expect(lines[1], startsWith('00000002 03'));
    });

    test('empty bytes produce empty output', () {
      expect(hexDump(<int>[]), '');
    });
  });

  group('parseHexToBytes', () {
    test('parses pairs, ignoring whitespace', () {
      expect(parseHexToBytes('48 69'), <int>[72, 105]);
      expect(parseHexToBytes('4869'), <int>[72, 105]);
    });

    test('odd length returns empty', () {
      expect(parseHexToBytes('486'), isEmpty);
    });

    test('non-hex content returns empty', () {
      expect(parseHexToBytes('zz'), isEmpty);
    });

    test('empty input returns empty', () {
      expect(parseHexToBytes(''), isEmpty);
    });
  });

  group('bytesToHex', () {
    test('lowercase zero-padded, no separators', () {
      expect(bytesToHex(<int>[72, 105]), '4869');
    });

    test('pads single-digit values', () {
      expect(bytesToHex(<int>[0, 15, 255]), '000fff');
    });

    test('empty bytes give empty string', () {
      expect(bytesToHex(<int>[]), '');
    });

    test('round trips with parseHexToBytes', () {
      expect(parseHexToBytes(bytesToHex(<int>[1, 16, 200])), <int>[1, 16, 200]);
    });
  });

  group('maskCreditCard', () {
    test('masks all but last four digits', () {
      expect(maskCreditCard('4111 1111 1111 1234'), '************1234');
    });

    test('strips non-digits before masking', () {
      expect(maskCreditCard('1234-5678'), '****5678');
    });

    test('digit count at or below visibleLast is returned unmasked', () {
      expect(maskCreditCard('123'), '123');
      expect(maskCreditCard('1234'), '1234');
    });

    test('custom visibleLast and maskChar', () {
      expect(maskCreditCard('123456', visibleLast: 2, maskChar: '#'), '####56');
    });
  });

  group('stripControlChars', () {
    test('removes control characters, keeps printable', () {
      expect(stripControlChars('a\tb\nc'), 'abc');
      expect(stripControlChars('hi\x00there'), 'hithere');
    });

    test('removes DEL (0x7F)', () {
      expect(stripControlChars('a\x7Fb'), 'ab');
    });

    test('leaves a clean string untouched', () {
      expect(stripControlChars('clean'), 'clean');
    });
  });

  group('isAsciiOnly', () {
    test('pure ASCII is true', () {
      expect(isAsciiOnly('abc123'), isTrue);
    });

    test('non-ASCII is false', () {
      expect(isAsciiOnly('héllo'), isFalse);
    });

    test('empty string is true', () {
      expect(isAsciiOnly(''), isTrue);
    });
  });

  group('truncateToByteLength', () {
    test('drops a multi-byte char that would overflow', () {
      // h(1) + é(2) = 3 bytes; the next char would exceed maxBytes.
      expect(truncateToByteLength('héllo', 3), 'hé');
    });

    test('returns whole string when it fits', () {
      expect(truncateToByteLength('abc', 10), 'abc');
    });

    test('cuts ASCII at the byte boundary', () {
      expect(truncateToByteLength('abcdef', 3), 'abc');
    });

    test('maxBytes too small for first multi-byte char yields empty', () {
      // é needs 2 bytes; maxBytes 1 cannot hold it.
      expect(truncateToByteLength('ément', 1), '');
    });
  });
}
