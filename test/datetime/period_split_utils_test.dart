// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/period_split_utils.dart';

void main() {
  group('splitByMonth', () {
    test('splits a multi-month span into per-month segments', () {
      final List<(DateTime, DateTime)> result = splitByMonth(
        DateTime(2023, 1, 10),
        DateTime(2023, 3, 5),
      );
      expect(result, <(DateTime, DateTime)>[
        (DateTime(2023), DateTime(2023, 1, 31)),
        (DateTime(2023, 2), DateTime(2023, 2, 28)),
        (DateTime(2023, 3), DateTime(2023, 3, 5)),
      ]);
    });

    test('start and end in the same month produces one segment', () {
      final List<(DateTime, DateTime)> result = splitByMonth(
        DateTime(2023, 6, 5),
        DateTime(2023, 6, 20),
      );
      expect(result, <(DateTime, DateTime)>[
        (DateTime(2023, 6), DateTime(2023, 6, 20)),
      ]);
    });

    test('leap February uses 29 as the segment end', () {
      final List<(DateTime, DateTime)> result = splitByMonth(
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 10),
      );
      expect(result, <(DateTime, DateTime)>[
        (DateTime(2024, 2), DateTime(2024, 2, 29)),
        (DateTime(2024, 3), DateTime(2024, 3, 10)),
      ]);
    });

    test('crosses a year boundary', () {
      final List<(DateTime, DateTime)> result = splitByMonth(
        DateTime(2023, 12, 15),
        DateTime(2024, 1, 10),
      );
      expect(result, <(DateTime, DateTime)>[
        (DateTime(2023, 12), DateTime(2023, 12, 31)),
        (DateTime(2024), DateTime(2024, 1, 10)),
      ]);
    });
  });
}
