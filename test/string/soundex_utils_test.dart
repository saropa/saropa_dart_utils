import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/soundex_utils.dart';

void main() {
  group('SoundexUtils.encode', () {
    test('Robert', () => expect(SoundexUtils.encode('Robert'), 'R163'));
    test('Rupert', () => expect(SoundexUtils.encode('Rupert'), 'R163'));
    test('empty', () => expect(SoundexUtils.encode(''), ''));

    test('a vowel breaks adjacency so a repeated code is re-emitted', () {
      // Gauss: G, then vowels A/U reset the run, so the S after them is coded
      // again -> G200. The old code collapsed it to G000.
      expect(SoundexUtils.encode('Gauss'), 'G200');
    });

    test('H and W are transparent and do NOT break adjacency', () {
      // Ashcraft: the H between same-coded letters does not reset the run.
      // Pfister-class names also rely on H/W transparency.
      expect(SoundexUtils.encode('Tymczak'), 'T522');
    });
  });
  group('soundsLike', () {
    test('same', () => expect(SoundexUtils.soundsLike('Robert', 'Rupert'), isTrue));
  });
}
