import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_business_days_utils.dart';

void main() {
  group('businessDaysBetween', () {
    test('excludes weekends', () {
      // Mon 10 to Fri 14 = 5 days, 4 weekdays (10,11,12,13,14 -> 5 weekdays)
      final DateTime start = DateTime(2024, 6, 10); // Mon
      final DateTime end = DateTime(2024, 6, 15); // Sat
      expect(businessDaysBetween(start, end), 5);
    });
  });
  group('addBusinessDays', () {
    test('adds 1 from Friday', () {
      final DateTime fri = DateTime(2024, 6, 14);
      expect(addBusinessDays(fri, 1), DateTime(2024, 6, 17));
    });
  });
}
