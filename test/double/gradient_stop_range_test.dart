import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/double/gradient_stop_range.dart';

void main() {
  group('StopRange.stops', () {
    group('exact values', () {
      test('easeIn returns [0, 0.5]', () {
        expect(StopRange.easeIn.stops, equals(<double>[0, 0.5]));
      });

      test('easeOut returns [0.5, 1]', () {
        expect(StopRange.easeOut.stops, equals(<double>[0.5, 1]));
      });

      test('easeInOut returns [0.25, 0.75]', () {
        expect(StopRange.easeInOut.stops, equals(<double>[0.25, 0.75]));
      });

      test('linear returns [0, 1]', () {
        expect(StopRange.linear.stops, equals(<double>[0, 1]));
      });
    });

    group('shape invariants', () {
      test('every variant returns exactly two stops', () {
        for (final StopRange range in StopRange.values) {
          expect(range.stops, hasLength(2));
        }
      });

      test('every variant is ordered ascending (start <= end)', () {
        for (final StopRange range in StopRange.values) {
          final List<double> s = range.stops;
          expect(s.first, lessThanOrEqualTo(s.last));
        }
      });

      test('every stop is within the normalized 0..1 range', () {
        for (final StopRange range in StopRange.values) {
          for (final double stop in range.stops) {
            expect(stop, inInclusiveRange(0.0, 1.0));
          }
        }
      });
    });

    // Bulletproofing gaps: structural / invariant guarantees (the enum has no
    // inputs, so these are the meaningful edge cases).
    group('bulletproofing invariants', () {
      // A newly-added variant should force an explicit test update rather than
      // ship with zero stops coverage.
      test('values has exactly 4 entries (exhaustiveness)', () {
        expect(StopRange.values, hasLength(4));
        expect(
          StopRange.values,
          equals(<StopRange>[
            StopRange.easeIn,
            StopRange.easeOut,
            StopRange.easeInOut,
            StopRange.linear,
          ]),
        );
      });

      // Guards against a future refactor that caches and returns a shared
      // mutable list: mutating one result must not affect a later read.
      test('mutating a returned list does not leak into a later read', () {
        final List<double> mutated = StopRange.easeIn.stops..add(2);
        expect(mutated, equals(<double>[0, 0.5, 2]));
        expect(StopRange.easeIn.stops, equals(<double>[0, 0.5]));
      });

      // Each call also returns a distinct list instance (no shared reference).
      test('two reads return independent list instances', () {
        final List<double> first = StopRange.linear.stops;
        final List<double> second = StopRange.linear.stops;
        expect(identical(first, second), isFalse);
        expect(first, equals(second));
      });

      // Boundary endpoints must land exactly on 0.0 / 1.0, not merely inside.
      test('easeIn starts at exactly 0.0', () {
        expect(StopRange.easeIn.stops.first, equals(0.0));
      });

      test('easeOut ends at exactly 1.0', () {
        expect(StopRange.easeOut.stops.last, equals(1.0));
      });

      test('linear spans the full boundary [0.0, 1.0]', () {
        expect(StopRange.linear.stops.first, equals(0.0));
        expect(StopRange.linear.stops.last, equals(1.0));
      });

      // A zero-width stop pair would produce a hard color edge in any consumer.
      test('every variant is strictly increasing (first < last)', () {
        for (final StopRange range in StopRange.values) {
          final List<double> s = range.stops;
          expect(s.first, lessThan(s.last));
        }
      });

      // Protects serialization consumers if the enum is persisted by name/index.
      test('values[i].index round-trips to i', () {
        for (int i = 0; i < StopRange.values.length; i++) {
          expect(StopRange.values[i].index, equals(i));
        }
      });

      test('byName round-trips to the matching variant', () {
        expect(StopRange.values.byName('easeIn'), equals(StopRange.easeIn));
        expect(StopRange.values.byName('easeOut'), equals(StopRange.easeOut));
        expect(
          StopRange.values.byName('easeInOut'),
          equals(StopRange.easeInOut),
        );
        expect(StopRange.values.byName('linear'), equals(StopRange.linear));
      });

      // Defends against a future computed-stops refactor introducing
      // double.infinity / double.nan.
      test('every stop is finite (no NaN / infinity)', () {
        for (final StopRange range in StopRange.values) {
          for (final double stop in range.stops) {
            expect(stop.isFinite, isTrue);
            expect(stop.isNaN, isFalse);
          }
        }
      });

      // Documentation parity: the dartdoc table must not drift from the switch.
      test('runtime values match the documented pairs', () {
        const Map<StopRange, List<double>> documented = <StopRange, List<double>>{
          StopRange.easeIn: <double>[0, 0.5],
          StopRange.easeOut: <double>[0.5, 1],
          StopRange.easeInOut: <double>[0.25, 0.75],
          StopRange.linear: <double>[0, 1],
        };
        for (final StopRange range in StopRange.values) {
          expect(range.stops, equals(documented[range]));
        }
      });
    });
  });
}
