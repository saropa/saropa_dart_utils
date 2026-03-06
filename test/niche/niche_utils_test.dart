import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/color_utils.dart';
import 'package:saropa_dart_utils/niche/name_utils.dart';
import 'package:saropa_dart_utils/niche/pad_format_utils.dart';
import 'package:saropa_dart_utils/niche/random_string_utils.dart';

void main() {
  group('hexToRgb', () {
    test('parses', () => expect(hexToRgb(0xFF1020), <int>[0xFF, 0x10, 0x20]));
  });
  group('rgbToHex', () {
    test('encodes', () => expect(rgbToHex(255, 0, 0), 0xFFFF0000));
  });
  group('abbreviateName', () {
    test('two parts', () => expect(abbreviateName('John Doe'), 'J. Doe'));
  });
  group('initialsFromName', () {
    test('two parts', () => expect(initialsFromName('John Doe'), 'JD'));
  });
  group('padWithZeros', () {
    test('pads', () => expect(padWithZeros(5, 3), '005'));
  });
  group('formatFileSize', () {
    test('bytes', () => expect(formatFileSize(1024), '1 KB'));
  });
  group('randomAlphanumeric', () {
    test('length', () => expect(randomAlphanumeric(10), hasLength(10)));
  });
}
