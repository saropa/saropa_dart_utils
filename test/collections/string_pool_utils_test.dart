import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/string_pool_utils.dart';

void main() {
  group('StringPoolUtils', () {
    group('intern', () {
      test('should return an equal string', () {
        final StringPoolUtils pool = StringPoolUtils();
        expect(pool.intern('hello'), 'hello');
      });

      test('should return the same canonical instance for equal strings', () {
        final StringPoolUtils pool = StringPoolUtils();
        // Build two distinct String instances with equal content.
        final String first = pool.intern('ab');
        final String second = pool.intern(['a', 'b'].join());
        expect(identical(first, second), isTrue);
      });

      test('should keep distinct strings distinct', () {
        final StringPoolUtils pool = StringPoolUtils();
        pool.intern('a');
        pool.intern('b');
        expect(pool.size, 2);
      });

      test('should not grow size on repeated interning', () {
        final StringPoolUtils pool = StringPoolUtils()
          ..intern('x')
          ..intern('x')
          ..intern('x');
        expect(pool.size, 1);
      });
    });

    group('size', () {
      test('should start at zero', () {
        expect(StringPoolUtils().size, 0);
      });

      test('should count distinct interned strings', () {
        final StringPoolUtils pool = StringPoolUtils()
          ..intern('a')
          ..intern('b')
          ..intern('c');
        expect(pool.size, 3);
      });
    });

    group('maxSize (FIFO eviction)', () {
      test('should evict the oldest entry when full', () {
        final StringPoolUtils pool = StringPoolUtils(maxSize: 2)
          ..intern('a')
          ..intern('b')
          ..intern('c'); // evicts 'a'
        expect(pool.size, 2);
        // Re-interning 'c' should hit the existing entry, not grow the pool.
        pool.intern('c');
        expect(pool.size, 2);
      });

      test('should keep pool at or below maxSize', () {
        final StringPoolUtils pool = StringPoolUtils(maxSize: 3);
        for (int i = 0; i < 10; i++) {
          pool.intern('s$i');
        }
        expect(pool.size, lessThanOrEqualTo(3));
      });

      test('should be unbounded when maxSize is omitted', () {
        final StringPoolUtils pool = StringPoolUtils();
        for (int i = 0; i < 50; i++) {
          pool.intern('s$i');
        }
        expect(pool.size, 50);
      });
    });

    group('toString', () {
      test('should report size', () {
        final StringPoolUtils pool = StringPoolUtils()..intern('a');
        expect(pool.toString(), 'StringPoolUtils(size: 1)');
      });
    });
  });
}
