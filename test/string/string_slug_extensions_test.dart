import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_slug_extensions.dart';

void main() {
  group('toSlug', () {
    test('empty', () => expect(''.toSlug(), ''));
    test('whitespace only', () => expect('   '.toSlug(), ''));
    test('simple', () => expect('Hello World!'.toSlug(), 'hello-world'));
    test('multiple spaces/hyphens', () => expect('one___two'.toSlug(), 'one-two'));
    test('leading trailing hyphens', () => expect('--hello--'.toSlug(), 'hello'));
    test('already lowercase', () => expect('hello world'.toSlug(), 'hello-world'));
  });

  group('toSlugWithMaxLength', () {
    test('under limit', () => expect('Hi'.toSlugWithMaxLength(10), 'hi'));
    test('at limit', () => expect('hello'.toSlugWithMaxLength(5), 'hello'));
    test('over limit truncate at hyphen', () {
      // Slug is 'hello-world-again'; last hyphen before index 10 is at 5 → 'hello'.
      expect('Hello World Again'.toSlugWithMaxLength(10), 'hello');
    });
    test('maxLength < 1 returns full slug', () {
      expect('a b c'.toSlugWithMaxLength(0), 'a-b-c');
    });
  });

  group('sanitizeFilename', () {
    test('empty', () => expect(''.sanitizeFilename(), ''));
    test('invalid chars', () {
      expect('file:name?.txt'.sanitizeFilename(), 'file_name_.txt');
    });
    test('replacement', () {
      expect('a/b/c'.sanitizeFilename(replacement: '-'), 'a-b-c');
    });
    test('maxLength', () {
      expect('long name'.sanitizeFilename(maxLength: 4), 'long');
    });
    test('leading dot', () {
      expect('.hidden'.sanitizeFilename(), '_hidden');
    });
  });
}
