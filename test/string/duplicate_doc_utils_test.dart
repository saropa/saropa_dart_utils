import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/duplicate_doc_utils.dart';

void main() {
  // cspell: disable
  group('isNearDuplicate', () {
    test('should be true for identical text', () {
      expect(isNearDuplicate('hello world', 'hello world'), isTrue);
    });

    test('should be true for reordered identical words (cosine ignores order)', () {
      expect(isNearDuplicate('hello world', 'world hello'), isTrue);
    });

    test('should be false for completely different text', () {
      expect(isNearDuplicate('the cat sat', 'quantum physics rules'), isFalse);
    });

    test('should honor a lower threshold', () {
      // Partial overlap scores below 0.85 default but above 0.4.
      expect(isNearDuplicate('alpha beta gamma', 'alpha beta delta', threshold: 0.4), isTrue);
    });

    test('should be false when overlap is below a high threshold', () {
      expect(isNearDuplicate('alpha beta gamma', 'alpha beta delta', threshold: 0.9), isFalse);
    });
  });

  group('clusterNearDuplicates', () {
    test('should group identical documents into one cluster', () {
      final List<List<int>> clusters = clusterNearDuplicates(<String>[
        'red green blue',
        'red green blue',
      ]);
      expect(clusters, <List<int>>[
        [0, 1],
      ]);
    });

    test('should keep dissimilar documents in separate clusters', () {
      final List<List<int>> clusters = clusterNearDuplicates(<String>[
        'apples and oranges',
        'rockets to the moon',
      ]);
      expect(clusters, <List<int>>[
        [0],
        [1],
      ]);
    });

    test('should cluster duplicates while leaving a unique doc alone', () {
      final List<List<int>> clusters = clusterNearDuplicates(<String>[
        'the quick fox',
        'the quick fox',
        'totally unrelated content here',
      ]);
      expect(clusters, <List<int>>[
        [0, 1],
        [2],
      ]);
    });

    test('should return empty list for empty input', () {
      expect(clusterNearDuplicates(<String>[]), <List<int>>[]);
    });

    test('should return a single singleton cluster for one document', () {
      expect(clusterNearDuplicates(<String>['only one']), <List<int>>[
        [0],
      ]);
    });
  });
}
