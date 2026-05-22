import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/retention_utils.dart';

void main() {
  group('retentionByDay', () {
    test('counts events per relative day from each user first event', () {
      // user a: Jan 1 (day 0) and Jan 3 (day 2).
      // user b: Jan 1 (day 0).
      final Map<int, int> result = retentionByDay(<(Object, DateTime)>[
        ('a', DateTime(2024)),
        ('a', DateTime(2024, 1, 3)),
        ('b', DateTime(2024)),
      ]);
      expect(result, <int, int>{0: 2, 2: 1});
    });

    test('out-of-order events are sorted so day0 is the earliest', () {
      // Later event listed first; difference is still measured from the earliest.
      final Map<int, int> result = retentionByDay(<(Object, DateTime)>[
        ('a', DateTime(2024, 1, 5)),
        ('a', DateTime(2024)),
      ]);
      expect(result, <int, int>{0: 1, 4: 1});
    });

    test('single user single event -> day 0 count 1', () {
      final Map<int, int> result = retentionByDay(<(Object, DateTime)>[
        ('a', DateTime(2024, 6, 15)),
      ]);
      expect(result, <int, int>{0: 1});
    });

    test('empty events returns empty map', () {
      expect(retentionByDay(<(Object, DateTime)>[]), isEmpty);
    });
  });
}
