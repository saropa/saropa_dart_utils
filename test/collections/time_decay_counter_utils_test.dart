import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/time_decay_counter_utils.dart';

void main() {
  group('TimeDecayCounter constructor', () {
    test('should reject a zero half-life', () {
      expect(() => TimeDecayCounter(halfLifeMillis: 0), throwsA(isA<AssertionError>()));
    });

    test('should reject a negative half-life', () {
      expect(() => TimeDecayCounter(halfLifeMillis: -100), throwsA(isA<AssertionError>()));
    });
  });

  group('TimeDecayCounter.value', () {
    test('should be zero before anything is added', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000);
      expect(counter.value(asOfTimeMillis: 0), 0.0);
    });

    test('should return the full weight at the instant it was added', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)..add(10, atTimeMillis: 0);
      expect(counter.value(asOfTimeMillis: 0), closeTo(10.0, 1e-9));
    });

    test('should halve the value after one half-life', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)..add(8, atTimeMillis: 0);
      expect(counter.value(asOfTimeMillis: 1000), closeTo(4.0, 1e-9));
    });

    test('should quarter the value after two half-lives', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)..add(8, atTimeMillis: 0);
      expect(counter.value(asOfTimeMillis: 2000), closeTo(2.0, 1e-9));
    });

    test('should not mutate state on read (repeated reads are consistent)', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)..add(10, atTimeMillis: 0);
      final first = counter.value(asOfTimeMillis: 1000);
      final second = counter.value(asOfTimeMillis: 1000);
      expect(first, second);
    });

    test('should clamp a read before the last update to zero elapsed decay', () {
      // dt < 0 must not amplify the value; it stays at the stored amount.
      final counter = TimeDecayCounter(halfLifeMillis: 1000)..add(5, atTimeMillis: 1000);
      expect(counter.value(asOfTimeMillis: 0), closeTo(5.0, 1e-9));
    });
  });

  group('TimeDecayCounter.add', () {
    test('should combine fresh weight with the decayed prior total', () {
      // Prior 4 decays to 2.0 after one half-life, plus a fresh 4 = 6.0.
      final counter = TimeDecayCounter(halfLifeMillis: 1000)
        ..add(4, atTimeMillis: 0)
        ..add(4, atTimeMillis: 1000);
      expect(counter.value(asOfTimeMillis: 1000), closeTo(6.0, 1e-9));
    });

    test('should accumulate multiple adds at the same instant linearly', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)
        ..add(3, atTimeMillis: 0)
        ..add(7, atTimeMillis: 0);
      expect(counter.value(asOfTimeMillis: 0), closeTo(10.0, 1e-9));
    });

    test('should handle a negative weight (decrement)', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)
        ..add(10, atTimeMillis: 0)
        ..add(-4, atTimeMillis: 0);
      expect(counter.value(asOfTimeMillis: 0), closeTo(6.0, 1e-9));
    });

    test('should not rewind the clock on an out-of-order add', () {
      // The late add at t=0 must age to the existing reference (t=1000), not
      // reset it; querying back at t=1000 reflects both contributions there.
      final counter = TimeDecayCounter(halfLifeMillis: 1000)
        ..add(8, atTimeMillis: 1000)
        ..add(2, atTimeMillis: 0);
      // Prior 8 stays at 8 (read at its own time); the late 2 is added at t=1000.
      expect(counter.value(asOfTimeMillis: 1000), closeTo(10.0, 1e-9));
    });

    test('should decay correctly across a large time gap (extreme dt)', () {
      // Twenty half-lives reduces the value to ~1/1,048,576 of the original.
      final counter = TimeDecayCounter(halfLifeMillis: 1)..add(1, atTimeMillis: 0);
      expect(counter.value(asOfTimeMillis: 20), closeTo(1.0 / 1048576, 1e-9));
    });
  });

  group('TimeDecayCounter.reset', () {
    test('should clear value and time so the counter starts fresh', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)
        ..add(5, atTimeMillis: 0)
        ..reset();
      expect(counter.value(asOfTimeMillis: 5000), 0.0);
    });

    test('should allow re-use after reset with a new baseline time', () {
      final counter = TimeDecayCounter(halfLifeMillis: 1000)
        ..add(5, atTimeMillis: 0)
        ..reset()
        ..add(8, atTimeMillis: 2000);
      expect(counter.value(asOfTimeMillis: 3000), closeTo(4.0, 1e-9));
    });
  });

  group('TimeDecayCounter.toString', () {
    test('should show none for last time before any add', () {
      expect(TimeDecayCounter(halfLifeMillis: 1000).toString(), contains('none'));
    });
  });
}
