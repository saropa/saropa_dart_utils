import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_range_utils.dart';

void main() {
  group('DateTimeCheck extension', () {
    group('inRange', () {
      test('returns true when date is within range', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 15)), isTrue);
      });

      test('returns false when date is before range', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2024, 12, 31)), isFalse);
      });

      test('returns false when date is after range', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 2)), isFalse);
      });

      test('returns false when date is equal to start', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025)), isFalse);
      });

      test('returns false when date is equal to end', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 31)), isFalse);
      });

      test('returns true for date one millisecond after start', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 1, 0, 0, 0, 1)), isTrue);
      });

      test('returns true for date one millisecond before end', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 30, 23, 59, 59, 999)), isTrue);
      });

      test('returns true for date at midnight within range', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 15)), isTrue);
      });

      test(
          'returns true for date at last millisecond of day '
          'within range', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2025, 1, 15, 23, 59, 59, 999)), isTrue);
      });

      test('returns false for date in different year', () {
        final range = DateTimeRange(
          start: DateTime(2025),
          end: DateTime(2025, 1, 31),
        );
        expect(range.inRange(DateTime(2026, 1, 15)), isFalse);
      });
    });

    group('isNowInRange', () {
      test('returns true when current date is within range', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now.add(const Duration(days: 1)),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns false when current date is before range', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 2)),
        );
        expect(range.isNowInRange(now: now), isFalse);
      });

      test('returns false when current date is after range', () {
        final now = DateTime.now();

        final range = DateTimeRange(
          start: now.subtract(const Duration(days: 2)),
          // this time yesterday
          end: now.subtract(const Duration(days: 1)),
        );

        expect(range.isNowInRange(now: now), isFalse);
      });

      test('returns false when current date is equal to start', () {
        final now = DateTime.now();

        final range = DateTimeRange(
          start: now,
          // this time tomorrow
          end: now.add(const Duration(days: 1)),
        );

        expect(range.isNowInRange(now: now), isFalse);
      });

      test('returns false when current date is equal to end', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now,
        );
        expect(range.isNowInRange(now: now), isFalse);
      });

      test(
          'returns true when current date is one millisecond '
          'after start', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: now.subtract(const Duration(milliseconds: 1)),
          end: now.add(const Duration(days: 1)),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test(
          'returns true when current date is one millisecond '
          'before end', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: now.subtract(const Duration(days: 1)),
          end: now.add(const Duration(milliseconds: 1)),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test(
          'returns true when range spans multiple years and current '
          'date is within', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: DateTime(now.year - 1),
          end: DateTime(now.year + 1, 12, 31),
        );
        expect(range.isNowInRange(now: now), isTrue);
      });

      test('returns false when range is in the past', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: now.subtract(const Duration(days: 365)),
          end: now.subtract(const Duration(days: 364)),
        );
        expect(range.isNowInRange(now: now), isFalse);
      });

      test('returns false when range is in the future', () {
        final now = DateTime.now();
        final range = DateTimeRange(
          start: now.add(const Duration(days: 364)),
          end: now.add(const Duration(days: 365)),
        );
        expect(range.isNowInRange(now: now), isFalse);
      });
    });
  });
}
