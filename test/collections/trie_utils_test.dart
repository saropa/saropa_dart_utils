// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/trie_utils.dart';

void main() {
  group('TrieUtils', () {
    group('insert / search', () {
      test('should find an inserted complete word', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        expect(trie.search('cat'), isTrue);
      });

      test('should not match a prefix that is not a complete word', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        expect(trie.search('ca'), isFalse);
      });

      test('should not match an unknown word', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        expect(trie.search('dog'), isFalse);
      });

      test('should ignore inserting an empty key', () {
        final TrieUtils trie = TrieUtils()..insert('');
        expect(trie.search(''), isFalse);
      });

      test('should store overlapping words independently', () {
        final TrieUtils trie = TrieUtils()
          ..insert('car')
          ..insert('card');
        expect(trie.search('car'), isTrue);
        expect(trie.search('card'), isTrue);
        expect(trie.search('ca'), isFalse);
      });
    });

    group('startsWith', () {
      test('should return true for an existing prefix', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        expect(trie.startsWith('ca'), isTrue);
        expect(trie.startsWith('cat'), isTrue);
      });

      test('should return false for a non-existent prefix', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        expect(trie.startsWith('do'), isFalse);
      });

      test('should return true for empty prefix when trie has content', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        expect(trie.startsWith(''), isTrue);
      });
    });

    group('delete', () {
      test('should remove a word so search fails', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        trie.delete('cat');
        expect(trie.search('cat'), isFalse);
      });

      test('should keep a longer word when deleting a shorter prefix word', () {
        final TrieUtils trie = TrieUtils()
          ..insert('car')
          ..insert('card');
        trie.delete('car');
        expect(trie.search('car'), isFalse);
        expect(trie.search('card'), isTrue);
      });

      test('should keep a shorter word when deleting a longer word', () {
        final TrieUtils trie = TrieUtils()
          ..insert('car')
          ..insert('card');
        trie.delete('card');
        expect(trie.search('card'), isFalse);
        expect(trie.search('car'), isTrue);
      });

      test('should be a no-op for an empty key', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        trie.delete('');
        expect(trie.search('cat'), isTrue);
      });

      test('should be a no-op for a non-existent word', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        trie.delete('dog');
        expect(trie.search('cat'), isTrue);
      });
    });

    group('keysWithPrefix', () {
      test('should return all words sharing a prefix', () {
        final TrieUtils trie = TrieUtils()
          ..insert('car')
          ..insert('card')
          ..insert('care')
          ..insert('dog');
        expect(trie.keysWithPrefix('car').toSet(), {'car', 'card', 'care'});
      });

      test('should return empty list for a missing prefix', () {
        final TrieUtils trie = TrieUtils()..insert('cat');
        expect(trie.keysWithPrefix('zzz'), <String>[]);
      });

      test('should return all words for an empty prefix', () {
        final TrieUtils trie = TrieUtils()
          ..insert('a')
          ..insert('b');
        expect(trie.keysWithPrefix('').toSet(), {'a', 'b'});
      });

      test('should return the exact word when prefix is a complete word', () {
        final TrieUtils trie = TrieUtils()..insert('car');
        expect(trie.keysWithPrefix('car'), ['car']);
      });
    });

    group('toString', () {
      test('should return the fixed label', () {
        expect(TrieUtils().toString(), 'TrieUtils()');
      });
    });
  });
}
