import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_compare_age_extensions.dart';

void main() {
  group('compareAges', () {
    final DateTime older = DateTime.utc(1990, 1, 1);
    final DateTime newer = DateTime.utc(2020, 6, 15);

    group('spec sample cases', () {
      test('both null -> 0', () => expect(compareAges(null, null), isZero));

      test('a null -> 1 (nulls last)', () => expect(compareAges(null, newer), 1));

      test('b null -> -1 (nulls last)', () => expect(compareAges(older, null), -1));

      test('a null ascending=false still last', () {
        expect(compareAges(null, newer, ascending: false), 1);
      });

      test('ascending: older before newer', () {
        expect(compareAges(older, newer).isNegative, isTrue);
      });

      test('descending: newer before older', () {
        expect(compareAges(older, newer, ascending: false).isNegative, isFalse);
      });

      test('equal dates -> 0 both directions', () {
        expect(compareAges(older, older), isZero);
        expect(compareAges(older, older, ascending: false), isZero);
      });
    });

    group('nulls stay last regardless of direction', () {
      // The direction multiplier must NOT touch the null branches; a regression
      // that moved `* (ascending ? 1 : -1)` ahead of the null checks would flip
      // a null to the front in descending order. These pin the correct sign.
      test('b null in descending still returns -1', () {
        expect(compareAges(older, null, ascending: false), -1);
      });

      test('a null in descending still returns 1', () {
        expect(compareAges(null, older, ascending: false), 1);
      });

      test('both null in descending still returns 0', () {
        expect(compareAges(null, null, ascending: false), isZero);
      });
    });

    group('instant-based comparison (not calendar/timezone aware)', () {
      test('UTC and local representing the same instant compare equal', () {
        // compareTo compares absolute instants, so the same moment expressed in
        // UTC vs local form is equal (0), not offset by the zone. Both values
        // must be derived from ONE instant: DateTime.utc(..) is a fixed UTC
        // moment and .toLocal() is the same moment in the machine's zone, so
        // round-tripping back to UTC yields the identical instant on any host.
        // (Constructing DateTime.utc(2020,1,1) and DateTime(2020,1,1)
        // independently would be DIFFERENT instants except at UTC+0.)
        final DateTime utc = DateTime.utc(2020, 1, 1);
        final DateTime local = utc.toLocal();
        expect(compareAges(utc, local), isZero);
        expect(compareAges(utc, local, ascending: false), isZero);
      });

      test('values straddling a DST transition order by absolute instant', () {
        // Pure DateTime.compareTo is instant-based, so a DST jump does not cause
        // an off-by-one: the later wall-clock time is the later instant here.
        final DateTime beforeDst = DateTime.utc(2020, 3, 8, 6); // ~ US DST start
        final DateTime afterDst = DateTime.utc(2020, 3, 8, 8);
        expect(compareAges(beforeDst, afterDst).isNegative, isTrue);
        expect(
          compareAges(beforeDst, afterDst, ascending: false).isNegative,
          isFalse,
        );
      });

      test('leap day orders by instant against a later date', () {
        final DateTime leapDay = DateTime.utc(2020, 2, 29);
        final DateTime nextYear = DateTime.utc(2021, 3, 1);
        expect(compareAges(leapDay, nextYear).isNegative, isTrue);
      });

      test('microsecond-level difference is not truncated', () {
        // A 1-microsecond gap must yield a non-zero result; truncating to second
        // or day granularity would wrongly report equality.
        final DateTime micro = DateTime.utc(2020, 1, 1, 0, 0, 0, 0, 1);
        final DateTime base = DateTime.utc(2020, 1, 1, 0, 0, 0, 0, 0);
        expect(compareAges(base, micro).isNegative, isTrue);
        expect(compareAges(micro, base).isNegative, isFalse);
        expect(compareAges(base, micro), isNot(isZero));
      });
    });

    group('extreme date bounds', () {
      test('far-past and far-future extremes do not overflow', () {
        // Near Dart's DateTime range bounds; compareTo must stay well-ordered.
        final DateTime farPast = DateTime.utc(-271821, 4, 20);
        final DateTime farFuture = DateTime.utc(275760, 9, 13);
        expect(compareAges(farPast, farFuture).isNegative, isTrue);
        expect(
          compareAges(farPast, farFuture, ascending: false).isNegative,
          isFalse,
        );
      });

      test('equal extreme instants return exactly 0 in both directions', () {
        final DateTime farFuture = DateTime.utc(275760, 9, 13);
        expect(compareAges(farFuture, farFuture), 0);
        expect(compareAges(farFuture, farFuture, ascending: false), 0);
      });
    });
  });
}
