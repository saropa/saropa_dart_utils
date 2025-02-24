import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_punctuation.dart';

void main() {
  group('StringPunctuation', () {
    group('removePunctuation', () {
      test('Basic punctuation removal', () {
        expect('Hello, world!'.removePunctuation(), 'Hello world');
      });

      test('Mixed punctuation', () {
        expect('Test... with?! punctuation."\''.removePunctuation(), 'Test with punctuation');
      });

      test('Accented characters are preserved', () {
        expect('café, résumé.'.removePunctuation(), 'café résumé');
      });

      test('Chinese characters are preserved', () {
        expect('你好，世界！'.removePunctuation(), '你好世界');
      });

      test('Whitespace is preserved', () {
        expect(
          'Hello   world  '.removePunctuation(),
          'Hello   world  ',
        ); // Whitespace should be kept
      });

      test('Mixed text and punctuation', () {
        expect(
          'Text with 123 punctuation marks!'.removePunctuation(),
          'Text with 123 punctuation marks',
        ); // Numbers are now kept, punctuation removed
      });

      test('Empty string', () {
        expect(''.removePunctuation(), '');
      });

      test('String with no punctuation', () {
        expect('HelloWorld'.removePunctuation(), 'HelloWorld');
      });

      test('String with only punctuation', () {
        expect(',.!?;'.removePunctuation(), '');
      });

      test('String with emojis (emojis are not letters or numbers or whitespace, so removed)', () {
        expect(
          'Hello 😊 world! 🌍'.removePunctuation(),
          'Hello  world ',
        ); // Emojis are removed as they are not letters, numbers or whitespace.
      });
    });
  });
}
