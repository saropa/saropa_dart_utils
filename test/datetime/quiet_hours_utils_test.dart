import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/quiet_hours_utils.dart';

void main() {
  group('QuietWindow', () {
    test('should reject a zero-length window', () {
      expect(() => QuietWindow(600, 600), throwsA(isA<AssertionError>()));
    });

    test('containsMinute should honor a same-day window', () {
      const QuietWindow w = QuietWindow(540, 1020); // 9:00–17:00
      expect(w.containsMinute(600), isTrue);
      expect(w.containsMinute(1020), isFalse); // end exclusive
      expect(w.containsMinute(500), isFalse);
    });

    test('containsMinute should honor a wrapped window', () {
      const QuietWindow w = QuietWindow(1320, 420); // 22:00–07:00
      expect(w.containsMinute(1380), isTrue); // 23:00 (evening tail)
      expect(w.containsMinute(60), isTrue); // 01:00 (morning head)
      expect(w.containsMinute(600), isFalse); // 10:00 (daytime)
      expect(w.containsMinute(420), isFalse); // 07:00 end exclusive
    });
  });

  group('QuietHours', () {
    final QuietHours overnight = QuietHours.daily(1320, 420); // 22:00–07:00

    group('isQuiet', () {
      test('should be true late at night and early morning', () {
        expect(overnight.isQuiet(DateTime(2026, 6, 1, 23)), isTrue);
        expect(overnight.isQuiet(DateTime(2026, 6, 1, 6, 30)), isTrue);
      });

      test('should be false during the day', () {
        expect(overnight.isQuiet(DateTime(2026, 6, 1, 12)), isFalse);
        expect(overnight.isQuiet(DateTime(2026, 6, 1, 7)), isFalse); // exactly end
      });
    });

    group('quietUntil', () {
      test('should return null outside quiet hours', () {
        expect(overnight.quietUntil(DateTime(2026, 6, 1, 12)), isNull);
      });

      test('should end the next morning when quiet started in the evening', () {
        // 23:00 Mon → quiet until 07:00 Tue.
        expect(
          overnight.quietUntil(DateTime(2026, 6, 1, 23)),
          equals(DateTime(2026, 6, 2, 7)),
        );
      });

      test('should end the same morning when quiet started after midnight', () {
        // 02:00 Tue → quiet until 07:00 Tue.
        expect(
          overnight.quietUntil(DateTime(2026, 6, 2, 2)),
          equals(DateTime(2026, 6, 2, 7)),
        );
      });

      test('should chain adjacent windows into one stretch', () {
        // 22:00–23:00 then 23:00–07:00 are back-to-back → ends at 07:00.
        final QuietHours chained = QuietHours(<QuietWindow>[
          QuietWindow(1320, 1380), // 22:00–23:00
          QuietWindow(1380, 420), // 23:00–07:00 (wraps)
        ]);

        expect(
          chained.quietUntil(DateTime(2026, 6, 1, 22, 30)),
          equals(DateTime(2026, 6, 2, 7)),
        );
      });
    });

    test('should support multiple independent windows', () {
      final QuietHours lunchAndNight = QuietHours(<QuietWindow>[
        QuietWindow(720, 780), // 12:00–13:00 lunch
        QuietWindow(1320, 420), // overnight
      ]);

      expect(lunchAndNight.isQuiet(DateTime(2026, 6, 1, 12, 30)), isTrue);
      expect(
        lunchAndNight.quietUntil(DateTime(2026, 6, 1, 12, 30)),
        equals(DateTime(2026, 6, 1, 13)),
      );
      expect(lunchAndNight.isQuiet(DateTime(2026, 6, 1, 15)), isFalse);
    });

    test('should preserve UTC-ness of the result', () {
      final DateTime? until = overnight.quietUntil(DateTime.utc(2026, 6, 1, 23));
      expect(until, equals(DateTime.utc(2026, 6, 2, 7)));
      expect(until!.isUtc, isTrue);
    });
  });
}
