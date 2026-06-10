import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_format_preset_utils.dart';

void main() {
  final DateTime d = DateTime(2026, 6, 10); // a Wednesday

  group('formatDateShort', () {
    test('renders zero-padded ISO yyyy-MM-dd', () {
      expect(formatDateShort(d), '2026-06-10');
      expect(formatDateShort(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('is locale-independent (no names)', () {
      expect(formatDateShort(DateTime(999, 12, 31)), '0999-12-31');
    });
  });

  group('formatDateMedium', () {
    test('renders abbreviated month, day, year', () {
      expect(formatDateMedium(d), 'Jun 10, 2026');
    });

    test('uses supplied localized names', () {
      const DateFormatNames fr = DateFormatNames(
        months: <String>['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'],
        monthsShort: <String>['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'],
        weekdays: <String>['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'],
      );
      expect(formatDateMedium(d, names: fr), 'juin 10, 2026');
    });
  });

  group('formatDateLong', () {
    test('renders weekday, full month, day, year', () {
      expect(formatDateLong(d), 'Wednesday, June 10, 2026');
    });

    test('weekday index aligns with DateTime.weekday (Mon=1..Sun=7)', () {
      expect(formatDateLong(DateTime(2026, 6, 8)), startsWith('Monday')); // 8th is Monday
      expect(formatDateLong(DateTime(2026, 6, 14)), startsWith('Sunday')); // 14th is Sunday
    });
  });
}
