import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/soundex_utils.dart';

void main() {
  group('SoundexUtils.encode', () {
    test('Robert', () => expect(SoundexUtils.encode('Robert'), 'R163'));
    test('Rupert', () => expect(SoundexUtils.encode('Rupert'), 'R163'));
    test('empty', () => expect(SoundexUtils.encode(''), ''));
  });
  group('soundsLike', () {
    test('same', () => expect(SoundexUtils.soundsLike('Robert', 'Rupert'), isTrue));
  });
}
