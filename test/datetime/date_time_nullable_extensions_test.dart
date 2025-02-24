import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_nullable_extensions.dart';

void main() {
  group('DateTimeNullableExtensions', () {
    group('isBeforeNullable', () {
      test('Both dates are null', () {
        const DateTime? dt1 = null;
        const DateTime? dt2 = null;
        expect(dt1.isBeforeNullable(dt2), false);
      });

      test('This date is null, other is not null', () {
        const DateTime? dt1 = null;
        final DateTime dt2 = DateTime.now();
        expect(dt1.isBeforeNullable(dt2), true);
      });

      test('This date is not null, other is null', () {
        final DateTime dt1 = DateTime.now();
        const DateTime? dt2 = null;
        expect(dt1.isBeforeNullable(dt2), false);
      });

      test('Both dates are the same (not null)', () {
        final DateTime dt = DateTime.now();
        final DateTime dt1 = dt;
        final DateTime dt2 = dt;
        expect(dt1.isBeforeNullable(dt2), false);
      });

      test('This date is before other date (not null)', () {
        final DateTime dt1 = DateTime.now();
        final DateTime dt2 = dt1.add(const Duration(days: 1));
        expect(dt1.isBeforeNullable(dt2), true);
      });

      test('This date is after other date (not null)', () {
        final DateTime dt1 = DateTime.now();
        final DateTime dt2 = dt1.subtract(const Duration(days: 1));
        expect(dt1.isBeforeNullable(dt2), false);
      });

      test('This date is the same as other date but different instances (not null)', () {
        final DateTime dt1 = DateTime.now();
        final DateTime dt2 = DateTime.now();
        expect(dt1.isBeforeNullable(dt2), false);
      });

      test('This date is null, other is future date (not null)', () {
        const DateTime? dt1 = null;
        final DateTime dt2 = DateTime.now().add(const Duration(days: 1));
        expect(dt1.isBeforeNullable(dt2), true);
      });

      test('This date is past date (not null), other is null', () {
        final DateTime dt1 = DateTime.now().subtract(const Duration(days: 1));
        const DateTime? dt2 = null;
        expect(dt1.isBeforeNullable(dt2), false);
      });

      test('This date is null, other is past date (not null)', () {
        const DateTime? dt1 = null;
        final DateTime dt2 = DateTime.now().subtract(const Duration(days: 1));
        expect(dt1.isBeforeNullable(dt2), true);
      });
    });

    group('compareDateTimeNullable', () {
      test('Both dates are null', () {
        const DateTime? dt1 = null;
        const DateTime? dt2 = null;
        expect(dt1.compareDateTimeNullable(dt2), 0);
      });

      test('This date is null, other is not null', () {
        const DateTime? dt1 = null;
        final DateTime dt2 = DateTime.now();
        expect(dt1.compareDateTimeNullable(dt2), -1);
      });

      test('This date is not null, other is null', () {
        final DateTime dt1 = DateTime.now();
        const DateTime? dt2 = null;
        expect(dt1.compareDateTimeNullable(dt2), 1);
      });

      test('Both dates are the same (not null)', () {
        final DateTime dt = DateTime.now();
        final DateTime dt1 = dt;
        final DateTime dt2 = dt;
        expect(dt1.compareDateTimeNullable(dt2), 0);
      });

      test('This date is before other date (not null)', () {
        final DateTime dt1 = DateTime.now();
        final DateTime dt2 = dt1.add(const Duration(days: 1));
        expect(dt1.compareDateTimeNullable(dt2), -1);
      });

      test('This date is after other date (not null)', () {
        final DateTime dt1 = DateTime.now();
        final DateTime dt2 = dt1.subtract(const Duration(days: 1));
        expect(dt1.compareDateTimeNullable(dt2), 1);
      });

      test('This date is the same as other date but different instances (not null)', () {
        final DateTime dt1 = DateTime.now();
        final DateTime dt2 = DateTime.now();
        expect(dt1.compareDateTimeNullable(dt2), 0);
      });

      test('This date is null, other is future date (not null)', () {
        const DateTime? dt1 = null;
        final DateTime dt2 = DateTime.now().add(const Duration(days: 1));
        expect(dt1.compareDateTimeNullable(dt2), -1);
      });

      test('This date is past date (not null), other is null', () {
        final DateTime dt1 = DateTime.now().subtract(const Duration(days: 1));
        const DateTime? dt2 = null;
        expect(dt1.compareDateTimeNullable(dt2), 1);
      });

      test('This date is null, other is past date (not null)', () {
        const DateTime? dt1 = null;
        final DateTime dt2 = DateTime.now().subtract(const Duration(days: 1));
        expect(dt1.compareDateTimeNullable(dt2), -1);
      });
    });
  });
}
