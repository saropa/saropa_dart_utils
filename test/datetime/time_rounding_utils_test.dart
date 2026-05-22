// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/time_rounding_utils.dart';

void main() {
  group('roundMinutes', () {
    group('nearest (mode 0, default)', () {
      test('rounds down when below the midpoint', () {
        expect(roundMinutes(12, 5), 10);
      });

      test('rounds up when above the midpoint', () {
        expect(roundMinutes(13, 5), 15);
      });

      test('rounds up at exactly the midpoint (ties go up)', () {
        // remainder 2, step 5: 2*2 >= 5 is false, so rounds down to 10.
        expect(roundMinutes(12, 5), 10);
      });

      test('exact midpoint of an even step rounds up', () {
        // 5 of step 10: remainder 5, 5*2 >= 10 is true, rounds up to 10.
        expect(roundMinutes(5, 10), 10);
      });

      test('already on a boundary stays put', () {
        expect(roundMinutes(15, 5), 15);
      });

      test('rounds to nearest 15', () {
        expect(roundMinutes(37, 15), 30);
      });
    });

    group('floor (mode 1)', () {
      test('always rounds down', () {
        expect(roundMinutes(14, 5, mode: 1), 10);
      });

      test('boundary value unchanged', () {
        expect(roundMinutes(15, 5, mode: 1), 15);
      });
    });

    group('ceil (mode 2)', () {
      test('rounds up any remainder', () {
        expect(roundMinutes(11, 5, mode: 2), 15);
      });

      test('exact boundary unchanged', () {
        expect(roundMinutes(10, 5, mode: 2), 10);
      });
    });

    group('edge cases', () {
      test('step less than 1 returns input unchanged', () {
        expect(roundMinutes(13, 0), 13);
      });

      test('negative step returns input unchanged', () {
        expect(roundMinutes(13, -5), 13);
      });

      test('zero minutes returns zero', () {
        expect(roundMinutes(0, 15), 0);
      });
    });
  });
}
