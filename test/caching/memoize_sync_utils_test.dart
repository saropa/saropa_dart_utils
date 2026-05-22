import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/memoize_sync_utils.dart';

void main() {
  group('memoize1', () {
    test('computes once per distinct argument', () {
      int calls = 0;
      final int Function(int) fn = memoize1<int, int>((int x) {
        calls++;
        return x * 2;
      });
      expect(fn(2), 4);
      expect(fn(2), 4); // cached, no recompute
      expect(calls, 1);
    });

    test('computes separately for different arguments', () {
      int calls = 0;
      final int Function(int) fn = memoize1<int, int>((int x) {
        calls++;
        return x * 2;
      });
      expect(fn(2), 4);
      expect(fn(3), 6);
      expect(calls, 2);
    });

    test('caches a null result (does not recompute)', () {
      int calls = 0;
      final String? Function(int) fn = memoize1<int, String?>((int x) {
        calls++;
        return null;
      });
      expect(fn(1), isNull);
      expect(fn(1), isNull);
      // putIfAbsent stores the null value, so the function runs only once.
      expect(calls, 1);
    });

    test('uses argument equality (records as keys)', () {
      int calls = 0;
      final int Function(String) fn = memoize1<String, int>((String s) {
        calls++;
        return s.length;
      });
      expect(fn('ab'), 2);
      expect(fn('ab'), 2);
      expect(calls, 1);
    });
  });

  group('singleValueCache', () {
    test('computes once and reuses the cached non-null value', () {
      int calls = 0;
      final int Function() get = singleValueCache<int>(() => ++calls);
      expect(get(), 1);
      expect(get(), 1); // cached
      expect(calls, 1);
    });

    test(
      'caches a null result and computes only once',
      () {
        int calls = 0;
        final String? Function() get = singleValueCache<String?>(() {
          calls++;
          return null;
        });
        expect(get(), isNull);
        expect(get(), isNull);
        expect(calls, 1);
      },
    );
  });
}
