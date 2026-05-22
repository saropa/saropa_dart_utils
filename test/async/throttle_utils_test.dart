import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/throttle_utils.dart';

void main() {
  // throttle mixes real DateTime.now() (for the leading-edge guard) with a
  // Timer (for the trailing call), so these tests use real wall-clock time with
  // short delays rather than fake_async, which cannot advance DateTime.now().
  group('throttle', () {
    test('fires immediately on the first call (leading edge)', () {
      int calls = 0;
      final VoidCallback fn = throttle(() => calls++, const Duration(milliseconds: 100));
      fn();
      expect(calls, 1);
    });

    test('suppresses rapid calls within the interval, then a trailing call fires', () async {
      int calls = 0;
      final VoidCallback fn = throttle(() => calls++, const Duration(milliseconds: 40));
      fn(); // leading -> 1
      fn(); // schedules trailing
      fn(); // ignored while timer is active
      expect(calls, 1);
      // Wait past the interval for the trailing timer to fire.
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(calls, 2);
    });

    test('a call after the interval fires immediately again', () async {
      int calls = 0;
      final VoidCallback fn = throttle(() => calls++, const Duration(milliseconds: 20));
      fn(); // leading -> 1
      await Future<void>.delayed(const Duration(milliseconds: 40));
      fn(); // interval elapsed -> immediate -> 2
      expect(calls, 2);
    });
  });
}
