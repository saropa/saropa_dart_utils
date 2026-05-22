import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/slug_dedup_utils.dart';

void main() {
  // cspell: disable
  group('deduplicateSlug', () {
    test('should return base slug unchanged when not taken', () {
      expect(deduplicateSlug('my-post', <String>{}), 'my-post');
    });

    test('should append -1 when base slug is taken', () {
      expect(deduplicateSlug('my-post', <String>{'my-post'}), 'my-post-1');
    });

    test('should skip to the first free numeric suffix', () {
      expect(
        deduplicateSlug('my-post', <String>{'my-post', 'my-post-1', 'my-post-2'}),
        'my-post-3',
      );
    });

    test('should trim surrounding whitespace from the base slug', () {
      expect(deduplicateSlug('  my-post  ', <String>{}), 'my-post');
    });

    test('should fall back to -1 for an empty base slug', () {
      expect(deduplicateSlug('', <String>{}), '-1');
    });

    test('should skip taken numeric fallbacks for an empty base slug', () {
      expect(deduplicateSlug('', <String>{'-1', '-2'}), '-3');
    });

    test('should treat a whitespace-only base slug as empty', () {
      expect(deduplicateSlug('   ', <String>{}), '-1');
    });
  });
}
