import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/iso_interval_parse_utils.dart';

void main() {
  group('parseIsoInterval', () {
    test('should parse the start/end form', () {
      final DateTimeRange range = parseIsoInterval('2026-01-01T00:00:00Z/2026-01-02T00:00:00Z');

      expect(range.start, equals(DateTime.utc(2026)));
      expect(range.end, equals(DateTime.utc(2026, 1, 2)));
    });

    test('should parse the start/duration form with a calendar month', () {
      final DateTimeRange range = parseIsoInterval('2026-01-31T00:00:00Z/P1M');

      // One calendar month from Jan 31 normalizes via the DateTime ctor.
      expect(range.start, equals(DateTime.utc(2026, 1, 31)));
      expect(range.end, equals(DateTime.utc(2026, 2, 31))); // = Mar 3
    });

    test('should parse the duration/end form', () {
      final DateTimeRange range = parseIsoInterval('P7D/2026-01-08T00:00:00Z');

      expect(range.start, equals(DateTime.utc(2026)));
      expect(range.end, equals(DateTime.utc(2026, 1, 8)));
    });

    test('should apply a combined date and time duration', () {
      final DateTimeRange range = parseIsoInterval('2026-01-01T00:00:00Z/P1DT12H');

      expect(range.end, equals(DateTime.utc(2026, 1, 2, 12)));
    });

    test('should fold weeks into days', () {
      final DateTimeRange range = parseIsoInterval('2026-01-01T00:00:00Z/P2W');

      expect(range.end, equals(DateTime.utc(2026, 1, 15)));
    });

    test('should support a fractional time component', () {
      final DateTimeRange range = parseIsoInterval('2026-01-01T00:00:00Z/PT1.5H');

      expect(range.end, equals(DateTime.utc(2026, 1, 1, 1, 30)));
    });

    test('should preserve local (non-UTC) timestamps', () {
      final DateTimeRange range = parseIsoInterval('2026-06-01T09:00:00/PT30M');

      expect(range.start, equals(DateTime(2026, 6, 1, 9)));
      expect(range.end, equals(DateTime(2026, 6, 1, 9, 30)));
      expect(range.start.isUtc, isFalse);
    });

    test('should compute the start of a duration/end with years and months', () {
      final DateTimeRange range = parseIsoInterval('P1Y2M/2027-03-15T00:00:00Z');

      expect(range.start, equals(DateTime.utc(2026, 1, 15)));
      expect(range.end, equals(DateTime.utc(2027, 3, 15)));
    });

    group('errors', () {
      test('should throw when there is no separator', () {
        expect(() => parseIsoInterval('2026-01-01T00:00:00Z'), throwsFormatException);
      });

      test('should throw when both halves are durations', () {
        expect(() => parseIsoInterval('P1D/P2D'), throwsFormatException);
      });

      test('should throw on a malformed timestamp', () {
        expect(() => parseIsoInterval('not-a-date/P1D'), throwsFormatException);
      });

      test('should throw on an empty duration', () {
        expect(() => parseIsoInterval('2026-01-01T00:00:00Z/P'), throwsFormatException);
      });

      test('should throw on a malformed duration', () {
        expect(() => parseIsoInterval('2026-01-01T00:00:00Z/P1X'), throwsFormatException);
      });

      test('should throw when start is after end', () {
        expect(
          () => parseIsoInterval('2026-01-02T00:00:00Z/2026-01-01T00:00:00Z'),
          throwsFormatException,
        );
      });
    });
  });
}
