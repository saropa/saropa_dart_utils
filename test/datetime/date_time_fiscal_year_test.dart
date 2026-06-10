import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_fiscal_extensions.dart';

void main() {
  // January 2026: before an April fiscal-year start, so it belongs to FY2025.
  final DateTime jan2026 = DateTime(2026, 1, 15);

  group('startOfFiscalYear', () {
    test('default (startMonth 1) is the calendar year start', () {
      final DateTime start = jan2026.startOfFiscalYear();
      expect(start.year, 2026);
      expect(start.month, 1);
      expect(start.day, 1);
    });

    test('April fiscal year: January falls in the prior FY', () {
      final DateTime start = jan2026.startOfFiscalYear(startMonth: 4);
      expect(start.year, 2025);
      expect(start.month, 4);
      expect(start.day, 1);
    });
  });

  group('endOfFiscalYear', () {
    test('default ends on 31 December', () {
      final DateTime end = jan2026.endOfFiscalYear();
      expect(end.year, 2026);
      expect(end.month, 12);
      expect(end.day, 31);
    });

    test('April fiscal year ends on 31 March of the next calendar year', () {
      final DateTime end = jan2026.endOfFiscalYear(startMonth: 4);
      expect(end.year, 2026);
      expect(end.month, 3);
      expect(end.day, 31);
    });
  });
}
