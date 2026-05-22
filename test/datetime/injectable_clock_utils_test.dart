// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/injectable_clock_utils.dart';

void main() {
  group('FixedClock', () {
    test('now returns the fixed instant', () {
      final DateTime fixed = DateTime(2023, 6, 15, 10, 30);
      expect(FixedClock(fixed).now(), fixed);
    });

    test('now is stable across repeated calls', () {
      final FixedClock clock = FixedClock(DateTime(2023, 6, 15));
      expect(clock.now(), clock.now());
    });

    test('toString includes the fixed time', () {
      expect(
        FixedClock(DateTime(2023, 6, 15, 10, 30)).toString(),
        'FixedClock(now: 2023-06-15 10:30:00.000)',
      );
    });
  });

  group('SystemClock', () {
    test('now returns a DateTime', () {
      expect(SystemClock().now(), isA<DateTime>());
    });

    test('toString returns the constant prefix', () {
      expect(SystemClock().toString(), 'SystemClock()');
    });
  });

  group('defaultClock', () {
    tearDown(() {
      // Restore the global so other tests are unaffected by the swap below.
      defaultClock = SystemClock();
    });

    test('defaults to a SystemClock instance', () {
      expect(defaultClock, isA<SystemClock>());
    });

    test('can be replaced with a FixedClock', () {
      final DateTime fixed = DateTime(2023, 6, 15, 10, 30);
      defaultClock = FixedClock(fixed);
      expect(defaultClock.now(), fixed);
    });
  });
}
