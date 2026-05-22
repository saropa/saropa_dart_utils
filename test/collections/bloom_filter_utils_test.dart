import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/bloom_filter_utils.dart';

void main() {
  group('BloomFilterUtils', () {
    group('constructor / getters', () {
      test('should expose expectedCount and default falsePositiveRate', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 100);
        expect(filter.expectedCount, 100);
        expect(filter.falsePositiveRate, 0.01);
      });

      test('should expose custom falsePositiveRate', () {
        final BloomFilterUtils filter = BloomFilterUtils(
          expectedCount: 50,
          falsePositiveRate: 0.05,
        );
        expect(filter.expectedCount, 50);
        expect(filter.falsePositiveRate, 0.05);
      });
    });

    group('add / mightContain', () {
      test('should report no membership before any add', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 100);
        expect(filter.mightContain('absent'), isFalse);
      });

      test('should report membership after add (no false negatives)', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 100);
        filter.add('hello');
        expect(filter.mightContain('hello'), isTrue);
      });

      test('should report all added elements as present', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 1000);
        for (int i = 0; i < 50; i++) {
          filter.add('item$i');
        }
        for (int i = 0; i < 50; i++) {
          expect(filter.mightContain('item$i'), isTrue, reason: 'item$i missing');
        }
      });

      test('should be idempotent for repeated adds', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 100);
        filter.add('x');
        filter.add('x');
        expect(filter.mightContain('x'), isTrue);
      });

      test('should support int and other Object keys', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 100);
        filter.add(42);
        expect(filter.mightContain(42), isTrue);
      });

      test('should handle non-positive expectedCount without error', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 0);
        filter.add('a');
        expect(filter.mightContain('a'), isTrue);
      });
    });

    group('toString', () {
      test('should include configuration', () {
        final BloomFilterUtils filter = BloomFilterUtils(expectedCount: 10);
        expect(filter.toString(), startsWith('BloomFilterUtils(expectedCount: 10'));
      });
    });
  });
}
