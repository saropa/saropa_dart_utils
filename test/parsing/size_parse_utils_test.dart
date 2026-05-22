import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/size_parse_utils.dart';

void main() {
  group('parseSizeToBytes', () {
    test('1.5 MB with space', () => expect(parseSizeToBytes('1.5 MB'), 1572864));
    test('512K no B suffix', () => expect(parseSizeToBytes('512K'), 524288));
    test('1KB equals 1024', () => expect(parseSizeToBytes('1KB'), 1024));
    test('plain number is bytes', () => expect(parseSizeToBytes('100'), 100));
    test('plain B suffix is bytes', () => expect(parseSizeToBytes('100B'), 100));
    test('1GB', () => expect(parseSizeToBytes('1GB'), 1073741824));
    test('case insensitive unit', () => expect(parseSizeToBytes('1mb'), 1048576));
    test('surrounding whitespace tolerated', () => expect(parseSizeToBytes('  2 KB  '), 2048));
    test('rounds to nearest byte', () => expect(parseSizeToBytes('1.5K'), 1536));
    test('zero is valid', () => expect(parseSizeToBytes('0'), 0));
    test('malformed text returns null', () => expect(parseSizeToBytes('big'), isNull));
    test('empty string returns null', () => expect(parseSizeToBytes(''), isNull));
    test('negative value returns null', () => expect(parseSizeToBytes('-5MB'), isNull));
    test('unknown unit letter returns null', () => expect(parseSizeToBytes('5X'), isNull));
  });

  group('formatBytesToHuman', () {
    test('1024 is 1 KB', () => expect(formatBytesToHuman(1024), '1 KB'));
    test('0 is 0 B', () => expect(formatBytesToHuman(0), '0 B'));
    test('under 1024 stays bytes', () => expect(formatBytesToHuman(512), '512 B'));
    test('1023 stays bytes', () => expect(formatBytesToHuman(1023), '1023 B'));
    test('1.5 MB', () => expect(formatBytesToHuman(1572864), '1.5 MB'));
    test('1.5 KB', () => expect(formatBytesToHuman(1536), '1.5 KB'));
    test('value over 10 has no decimals', () => expect(formatBytesToHuman(10240), '10 KB'));
    test('whole value has no decimals', () => expect(formatBytesToHuman(2048), '2 KB'));
    test('1 GB', () => expect(formatBytesToHuman(1073741824), '1 GB'));
    test('negative prefixed with minus', () => expect(formatBytesToHuman(-1024), '-1 KB'));
    test('decimals param controls precision', () {
      // 1126 / 1024 = 1.0996..., two decimals -> 1.1 after trailing-zero trim.
      expect(formatBytesToHuman(1126, decimals: 2), '1.1 KB');
    });
  });
}
